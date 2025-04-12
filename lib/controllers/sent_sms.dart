import 'package:flutter/foundation.dart';

/// A model class to represent a sent SMS message
class SentSMS {
  final String phoneNumber;
  final String message;
  final DateTime timestamp;
  final bool success;
  final String? response;

  SentSMS({
    required this.phoneNumber,
    required this.message,
    required this.timestamp,
    required this.success,
    this.response,
  });

  /// Create a copy of this SentSMS with the given fields replaced with new values
  SentSMS copyWith({
    String? phoneNumber,
    String? message,
    DateTime? timestamp,
    bool? success,
    String? response,
  }) {
    return SentSMS(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      success: success ?? this.success,
      response: response ?? this.response,
    );
  }

  @override
  String toString() {
    return 'SentSMS(phoneNumber: $phoneNumber, message: $message, timestamp: $timestamp, success: $success, response: $response)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SentSMS &&
        other.phoneNumber == phoneNumber &&
        other.message == message &&
        other.timestamp == timestamp &&
        other.success == success &&
        other.response == response;
  }

  @override
  int get hashCode {
    return phoneNumber.hashCode ^
        message.hashCode ^
        timestamp.hashCode ^
        success.hashCode ^
        response.hashCode;
  }
}

/// A service to track sent SMS messages
class SentSMSTracker {
  final List<SentSMS> _sentMessages = [];

  /// Add a new sent SMS to the tracker
  void addSentSMS(SentSMS sms) {
    _sentMessages.add(sms);
    debugPrint('SMS added to tracker: ${sms.toString()}');
  }

  /// Get all sent SMS messages
  List<SentSMS> getAllSentSMS() {
    return List.unmodifiable(_sentMessages);
  }

  /// Get sent SMS messages for a specific phone number
  List<SentSMS> getSentSMSForPhoneNumber(String phoneNumber) {
    return _sentMessages
        .where((sms) => sms.phoneNumber == phoneNumber)
        .toList();
  }

  /// Clear all sent SMS messages
  void clearAllSentSMS() {
    _sentMessages.clear();
  }
}
