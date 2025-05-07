import 'package:agrosys/domain/models/activity.dart';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Cubit for managing the list of recent activities.
class RecentActivityCubit extends Cubit<List<Activity>> {
  static const String _storageKey = 'recent_activities';
  static const int _maxActivities = 10;

  RecentActivityCubit() : super([]);

  /// Loads activities from storage and emits the loaded list.
  Future<void> loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedActivities = prefs.getString(_storageKey);
    if (storedActivities != null) {
      final List<dynamic> decoded = json.decode(storedActivities);
      final activities = decoded.map((item) => Activity.fromJson(item)).toList();
      emit(activities);
    }
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    final parts = <String>[];
    if (days > 0) parts.add('$days يوم');
    if (hours > 0) parts.add('$hours ساعة');
    if (minutes > 0) parts.add('$minutes دقيقة');
    if (seconds > 0 && parts.isEmpty) parts.add('$seconds ثانية');
    
    // If no parts were added (duration < 1 second), show "أقل من دقيقة"
    if (parts.isEmpty) {
      return 'أقل من دقيقة';
    }
    
    return parts.join(' و ');
  }

  Future<void> addActivity(Activity activity) async {
    final currentActivities = List<Activity>.from(state);
    
    // If this is an OFF event, try to find the matching ON event and calculate duration
    if (activity.type == 'OFF') {
      // Find the most recent ON event for this device that occurred before this OFF event
      final lastOnEvent = currentActivities.where(
        (a) => a.type == 'ON' && 
               a.deviceNumber == activity.deviceNumber && 
               a.timestamp.isBefore(activity.timestamp)
      ).lastOrNull;
      
      if (lastOnEvent != null) {
        final duration = activity.timestamp.difference(lastOnEvent.timestamp);
        // Always set duration for OFF events
        activity = Activity(
          timestamp: activity.timestamp,
          type: activity.type,
          deviceNumber: activity.deviceNumber,
          duration: _formatDuration(duration),
        );
        
        // Update the ON event to include the duration
        final onEventIndex = currentActivities.indexOf(lastOnEvent);
        if (onEventIndex != -1) {
          currentActivities[onEventIndex] = Activity(
            timestamp: lastOnEvent.timestamp,
            type: lastOnEvent.type,
            deviceNumber: lastOnEvent.deviceNumber,
            duration: _formatDuration(duration),
          );
        }
      }
    }

    // Remove any existing OFF events without a matching ON event
    currentActivities.removeWhere((a) => 
      a.type == 'OFF' && a.duration == null && a.deviceNumber == activity.deviceNumber
    );

    currentActivities.insert(0, activity);
    if (currentActivities.length > _maxActivities) {
      currentActivities.removeLast();
    }

    // Save to storage
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(currentActivities.map((a) => a.toJson()).toList());
    await prefs.setString(_storageKey, encoded);

    emit(currentActivities);
  }

  Future<void> clearActivities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    emit([]);
  }
}
