/*

ACTIVITY CUBIT

Manages the state of activities and handles activity-related operations.

*/

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrosys/domain/models/activity.dart';
import 'package:agrosys/domain/repository/activity_repo.dart';

// Activity State
class ActivityState {
  final List<Activity> activities;
  final bool isLoading;
  final String? error;

  ActivityState({
    required this.activities,
    this.isLoading = false,
    this.error,
  });

  ActivityState copyWith({
    List<Activity>? activities,
    bool? isLoading,
    String? error,
  }) {
    return ActivityState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Activity Cubit
class ActivityCubit extends Cubit<ActivityState> {
  final ActivityRepo _activityRepo;

  ActivityCubit(this._activityRepo) : super(ActivityState(activities: []));

  // Load all activities
  Future<void> loadActivities() async {
    emit(state.copyWith(isLoading: true));
    try {
      final activities = await _activityRepo.getActivities();
      emit(state.copyWith(
        activities: activities,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load activities: $e',
      ));
    }
  }

  // Load activities for a specific device
  Future<void> loadDeviceActivities(int deviceId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final activities = await _activityRepo.getDeviceActivities(deviceId);
      emit(state.copyWith(
        activities: activities,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load device activities: $e',
      ));
    }
  }

  // Add a new activity
  Future<void> addActivity(Activity activity) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _activityRepo.addActivity(activity);
      final activities = await _activityRepo.getActivities();
      emit(state.copyWith(
        activities: activities,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to add activity: $e',
      ));
    }
  }

  // Delete an activity
  Future<void> deleteActivity(Activity activity) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _activityRepo.deleteActivity(activity);
      final activities = await _activityRepo.getActivities();
      emit(state.copyWith(
        activities: activities,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to delete activity: $e',
      ));
    }
  }

  // Clear all activities for a device
  Future<void> clearDeviceActivities(int deviceId) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _activityRepo.clearDeviceActivities(deviceId);
      final activities = await _activityRepo.getActivities();
      emit(state.copyWith(
        activities: activities,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to clear device activities: $e',
      ));
    }
  }
}