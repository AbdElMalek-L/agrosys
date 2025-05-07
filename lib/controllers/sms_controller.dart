import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:agrosys/controllers/sent_sms.dart';

/// Callback for showing messages to the user
typedef MessageCallback = void Function(String message);

class SMSController {
  static const MethodChannel _channel = MethodChannel(
    'com.example.agrosys/sms',
  );

  final SmsAutoFill _smsAutoFill = SmsAutoFill();
  final SentSMSTracker _smsTracker = SentSMSTracker();
  StreamSubscription? _smsSubscription;

  /// Get all sent SMS messages
  List<SentSMS> getAllSentSMS() {
    return _smsTracker.getAllSentSMS();
  }

  /// Get sent SMS messages for a specific phone number
  List<SentSMS> getSentSMSForPhoneNumber(String phoneNumber) {
    return _smsTracker.getSentSMSForPhoneNumber(phoneNumber);
  }

  /// Check if the app has SMS permission
  Future<bool> _checkSmsPermission() async {
    try {
      return await _channel.invokeMethod('checkSmsPermission');
    } on PlatformException catch (e) {
      debugPrint('Error checking SMS permission: ${e.message}');
      return false;
    }
  }

  /// Request SMS permission
  Future<void> _requestSmsPermission() async {
    try {
      await _channel.invokeMethod('requestSmsPermission');
    } on PlatformException catch (e) {
      debugPrint('Error requesting SMS permission: ${e.message}');
    }
  }

  /// Send SMS immediately
  Future<bool> _sendSms({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      return await _channel.invokeMethod('sendSms', {
        'phoneNumber': phoneNumber,
        'message': message,
      });
    } on PlatformException catch (e) {
      debugPrint('Error sending SMS: ${e.message}');
      return false;
    }
  }

  /// Schedule SMS to be sent at a specific time
  Future<bool> _scheduleSms({
    required String phoneNumber,
    required String message,
    required DateTime scheduledTime,
  }) async {
    try {
      return await _channel.invokeMethod('scheduleSms', {
        'phoneNumber': phoneNumber,
        'message': message,
        'triggerTimeInMillis': scheduledTime.millisecondsSinceEpoch,
      });
    } on PlatformException catch (e) {
      debugPrint('Error scheduling SMS: ${e.message}');
      return false;
    }
  }

  /// Send a simple SMS without waiting for response or UI updates
  Future<bool> sendSimpleSMS({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final success = await _sendSms(
        phoneNumber: phoneNumber,
        message: message,
      );

      // Track the sent SMS
      final sentSMS = SentSMS(
        phoneNumber: phoneNumber,
        message: message,
        timestamp: DateTime.now(),
        success: success,
        response: null,
      );
      _smsTracker.addSentSMS(sentSMS);

      return success;
    } catch (e) {
      debugPrint('Error in sendSimpleSMS: $e');
      return false;
    }
  }

  Future<void> sendCommandWithResponse({
    required BuildContext context,
    required String phoneNumber,
    required String command,
    required Function(bool success, String? response) onResult,
    Duration timeout = const Duration(seconds: 15),
    MessageCallback? onMessage,
  }) async {
    void showMessage(String message) {
      if (onMessage != null) {
        onMessage(message);
      } else if (context.mounted) {
        _showSnackBar(context, message);
      }
    }

    try {
      // Check SMS permission before sending
      final hasPermission = await _checkSmsPermission();
      if (!hasPermission) {
        await _requestSmsPermission();
        if (!await _checkSmsPermission()) {
          showMessage("❌ SMS permission denied");
          onResult(false, null);
          return;
        }
      }

      final success = await _sendSms(
        phoneNumber: phoneNumber,
        message: command,
      );

      // Track the sent SMS
      final sentSMS = SentSMS(
        phoneNumber: phoneNumber,
        message: command,
        timestamp: DateTime.now(),
        success: success,
        response: null,
      );

      if (!success) {
        showMessage("❌ Failed to send SMS");
        _smsTracker.addSentSMS(sentSMS);
        onResult(false, null);
        return;
      }

      showMessage("📨 SMS sent, waiting for response...");
      _smsTracker.addSentSMS(sentSMS);

      bool received = false;
      await _smsSubscription?.cancel();

      _smsSubscription = _smsAutoFill.code.listen((String? code) {
        if (code != null && !received) {
          received = true;
          showMessage("✅ Response: $code");

          final updatedSMS = sentSMS.copyWith(success: true, response: code);
          _smsTracker.addSentSMS(updatedSMS);

          onResult(true, code);
          _smsSubscription?.cancel();
        }
      });

      _smsAutoFill.listenForCode;

      Future.delayed(timeout, () {
        if (!received) {
          showMessage("⏳ No response received (timeout)");

          final updatedSMS = sentSMS.copyWith(
            success: false,
            response: "Timeout - no response received",
          );
          _smsTracker.addSentSMS(updatedSMS);

          onResult(false, null);
          _smsSubscription?.cancel();
        }
      });
    } catch (e) {
      showMessage("⚠️ Error: $e");
      onResult(false, null);
      _smsSubscription?.cancel();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> scheduleSMS({
    required String phoneNumber,
    required String message,
    required DateTime scheduledTime,
    MessageCallback? onMessage,
  }) async {
    try {
      final hasPermission = await _checkSmsPermission();
      if (!hasPermission) {
        await _requestSmsPermission();
        if (!await _checkSmsPermission()) {
          if (onMessage != null) onMessage("❌ SMS permission denied");
          return;
        }
      }

      final success = await _scheduleSms(
        phoneNumber: phoneNumber,
        message: message,
        scheduledTime: scheduledTime,
      );

      final sentSMS = SentSMS(
        phoneNumber: phoneNumber,
        message: message,
        timestamp: scheduledTime,
        success: success,
        response: null,
      );
      _smsTracker.addSentSMS(sentSMS);

      if (onMessage != null) {
        onMessage(success
            ? "✅ SMS scheduled for ${scheduledTime.toString()}"
            : "❌ Failed to schedule SMS");
      }
    } catch (e) {
      if (onMessage != null) onMessage("⚠️ Error scheduling SMS: $e");
    }
  }

  void dispose() {
    _smsSubscription?.cancel();
  }
}