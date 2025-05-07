/*

DEVICE MODEL

This a device object 
________________________________________________________________________________

It has these propeties:

- id
- model
- name
- phoneNumber
- passWord
- isPowredOn
- signal
________________________________________________________________________________

Methodes:

- toggle power on and off

*/

class Activity {
  final DateTime timestamp;
  final String type; // 'ON' or 'OFF'
  final String deviceNumber;
  final String? duration; // Duration of the active period (for OFF events)

  Activity({
    required this.timestamp,
    required this.type,
    required this.deviceNumber,
    this.duration,
  });

  factory Activity.fromSms(String message, DateTime timestamp) {
    final isOn = message.startsWith('Relay ON!');
    // Extract device number from the message
    String deviceNumber;
    if (message.contains('Operated by')) {
      deviceNumber = message.split('Operated by ').last.trim();
    } else {
      // If no "Operated by" text, try to extract the number from the message
      final numberMatch = RegExp(r'\d+').firstMatch(message);
      deviceNumber = numberMatch?.group(0) ?? '';
    }

    // Ensure we have a valid timestamp
    final validTimestamp = timestamp.isUtc ? timestamp.toLocal() : timestamp;

    return Activity(
      timestamp: validTimestamp,
      type: isOn ? 'ON' : 'OFF',
      deviceNumber: deviceNumber,
    );
  }

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'type': type,
    'deviceNumber': deviceNumber,
    'duration': duration,
  };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
    timestamp: DateTime.parse(json['timestamp']),
    type: json['type'],
    deviceNumber: json['deviceNumber'],
    duration: json['duration'],
  );
}
