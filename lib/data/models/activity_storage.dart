/*

ACTIVITY STORAGE MODEL

This handles converting activities to and from JSON for storage.

*/

import 'package:agrosys/domain/models/activity.dart';

class ActivityStorage {
  final int id;
  final int deviceId;
  final String type;
  final String timestamp;
  final String description;

  ActivityStorage({
    required this.id,
    required this.deviceId,
    required this.type,
    required this.timestamp,
    required this.description,
  });

  // Convert from domain Activity to storage model
  factory ActivityStorage.fromActivity(Activity activity) {
    return ActivityStorage(
      id: activity.id,
      deviceId: activity.deviceId,
      type: activity.type,
      timestamp: activity.timestamp.toIso8601String(),
      description: activity.description,
    );
  }

  // Convert to domain Activity
  Activity toActivity() {
    return Activity(
      id: id,
      deviceId: deviceId,
      type: type,
      timestamp: DateTime.parse(timestamp),
      description: description,
    );
  }

  // Convert from JSON
  factory ActivityStorage.fromJson(Map<String, dynamic> json) {
    return ActivityStorage(
      id: json['id'] as int,
      deviceId: json['deviceId'] as int,
      type: json['type'] as String,
      timestamp: json['timestamp'] as String,
      description: json['description'] as String,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'type': type,
      'timestamp': timestamp,
      'description': description,
    };
  }
}