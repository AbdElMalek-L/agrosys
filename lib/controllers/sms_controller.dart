import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_messenger/flutter_background_messenger.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:agrosys/controllers/sent_sms.dart';

/// Callback for showing messages to the user
typedef MessageCallback = void Function(String message);

class SMSController {
  final FlutterBackgroundMessenger _messenger = FlutterBackgroundMessenger();
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

  /// Send a simple SMS without waiting for response or UI updates
  /// Used for background operations
  Future<bool> sendSimpleSMS({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final success = await _messenger.sendSMS(
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
    // Capture the context in a local function to avoid async gap issues
    void showMessage(String message) {
      if (onMessage != null) {
        onMessage(message);
      } else if (context.mounted) {
        _showSnackBar(context, message);
      }
    }

    try {
      final success = await _messenger.sendSMS(
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

      // Cancel any existing subscription
      await _smsSubscription?.cancel();

      // Start listening for SMS responses
      _smsSubscription = _smsAutoFill.code.listen((String? code) {
        if (code != null && !received) {
          received = true;
          showMessage("✅ Response: $code");

          // Update the sent SMS with the response
          final updatedSMS = sentSMS.copyWith(success: true, response: code);
          _smsTracker.addSentSMS(updatedSMS);

          onResult(true, code);
          _smsSubscription?.cancel();
        }
      });

      // Start listening for incoming SMS
      await _smsAutoFill.listenForCode;

      // Timeout fallback
      Future.delayed(timeout, () {
        if (!received) {
          showMessage("⏳ No response received (timeout)");

          // Update the sent SMS to indicate timeout
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

  /// Shows a snackbar with the given message
  /// Note: This should only be called when we're sure the context is still valid
  void _showSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Clean up resources when done
  void dispose() {
    _smsSubscription?.cancel();
  }
}
