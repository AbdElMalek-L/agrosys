/*

ACTIVITY REPOSITORY

Here we define what operations can be performed on activities.

*/

import 'package:agrosys/domain/models/activity.dart';

abstract class ActivityRepo {
  // Get all activities
  Future<List<Activity>> getActivities();

  // Get activities for a specific device
  Future<List<Activity>> getDeviceActivities(int deviceId);

  // Add a new activity
  Future<void> addActivity(Activity activity);

  // Delete an activity
  Future<void> deleteActivity(Activity activity);

  // Clear all activities for a device
  Future<void> clearDeviceActivities(int deviceId);
}