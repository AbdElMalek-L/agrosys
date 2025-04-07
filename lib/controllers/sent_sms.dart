import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_background_messenger/flutter_background_messenger.dart';

final messenger = FlutterBackgroundMessenger();

// Function to send an SMS message
Future<void> sendSMS(String phoneNumber, String cmd) async {
  try {
    final success = await messenger.sendSMS(
      phoneNumber: phoneNumber,
      message: cmd,
    );

    // Show toast message to indicate success or failure
    Fluttertoast.showToast(
      msg: success ? "SMS sent successfully" : "Failed to send SMS",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  } catch (e) {
    Fluttertoast.showToast(
      msg: 'Error sending SMS: $e',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
