/*

ACTIVITY MODEL

This is an activity object that represents a device action or state change
________________________________________________________________________________

It has these properties:

- id
- deviceId
- type
- timestamp
- description
________________________________________________________________________________

*/

class Activity {
  final int id;
  final int deviceId;
  final String type;
  final DateTime timestamp;
  final String description;

  Activity({
    required this.id,
    required this.deviceId,
    required this.type,
    required this.timestamp,
    required this.description,
  });

  Activity copyWith({
    int? id,
    int? deviceId,
    String? type,
    DateTime? timestamp,
    String? description,
  }) {
    return Activity(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
    );
  }
}
