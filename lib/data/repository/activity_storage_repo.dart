/*

ACTIVITY STORAGE REPOSITORY

This implements the activity repository and handles storing, retrieving, updating,
and deleting activities in the local storage.

*/

import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrosys/data/models/activity_storage.dart';
import 'package:agrosys/domain/models/activity.dart';
import 'package:agrosys/domain/repository/activity_repo.dart';
import 'dart:convert';

class ActivityStorageRepo implements ActivityRepo {
  final SharedPreferences storage;

  static const String activitiesKey = "stored_activities";

  ActivityStorageRepo(this.storage);

  // Get all activities
  @override
  Future<List<Activity>> getActivities() async {
    final storedData = storage.getString(activitiesKey);
    if (storedData == null) return [];

    List<dynamic> jsonList = jsonDecode(storedData);
    return jsonList.map((e) => ActivityStorage.fromJson(e).toActivity()).toList();
  }

  // Get activities for a specific device
  @override
  Future<List<Activity>> getDeviceActivities(int deviceId) async {
    final activities = await getActivities();
    return activities.where((activity) => activity.deviceId == deviceId).toList();
  }

  // Add a new activity
  @override
  Future<void> addActivity(Activity activity) async {
    List<Activity> activities = await getActivities();
    activities.add(activity);
    // Remove oldest activities if exceeding 100 limit
    if (activities.length > 100) {
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort in descending order
      activities = activities.take(100).toList(); // Keep most recent 100
    }
    await _saveActivities(activities);
  }

  // Delete an activity
  @override
  Future<void> deleteActivity(Activity activity) async {
    List<Activity> activities = await getActivities();
    activities.removeWhere((a) => a.id == activity.id);
    await _saveActivities(activities);
  }

  // Clear all activities for a device
  @override
  Future<void> clearDeviceActivities(int deviceId) async {
    List<Activity> activities = await getActivities();
    activities.removeWhere((activity) => activity.deviceId == deviceId);
    await _saveActivities(activities);
  }

  // Helper method to save activities to storage
  Future<void> _saveActivities(List<Activity> activities) async {
    final jsonList = activities
        .map((activity) => ActivityStorage.fromActivity(activity).toJson())
        .toList();
    await storage.setString(activitiesKey, jsonEncode(jsonList));
  }
}