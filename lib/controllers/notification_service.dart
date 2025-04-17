import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:agrosys/domain/models/device.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal();

  Future<void> initialize() async {
    // No initialization needed for toast notifications
  }

  // Show toast notification for schedule events
  Future<void> showScheduleNotification({
    required Device device,
    required bool isStartEvent,
  }) async {
    final title = isStartEvent ? 'تم تشغيل جهاز' : 'تم إيقاف جهاز';
    final message =
        '${isStartEvent ? 'تم تشغيل' : 'تم إيقاف'} جهاز ${device.name} وفقًا للجدول المحدد';

    await Fluttertoast.showToast(
      msg: "$title\n$message",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 5,
      backgroundColor:
          isStartEvent ? Colors.green.shade600 : Colors.red.shade600,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // For immediate notifications only since we can't schedule toasts
  Future<void> scheduleNotification({
    required Device device,
    required TimeOfDay scheduledTime,
    required bool isStartEvent,
    bool showPreview = false,
  }) async {
    // We can't actually schedule toast notifications,
    // but we'll show one immediately if we want to preview
    if (showPreview) {
      final title =
          isStartEvent ? 'جهاز سيتم تشغيله قريبًا' : 'جهاز سيتم إيقافه قريبًا';
      final message =
          'سيتم ${isStartEvent ? 'تشغيل' : 'إيقاف'} جهاز ${device.name} بعد 5 دقائق';

      await Fluttertoast.showToast(
        msg: "$title\n$message",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.blue.shade600,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  // Cancel notifications - no-op for toast
  Future<void> cancelDeviceNotifications(int deviceId) async {
    // No-op for toast notifications
  }

  // Cancel all notifications - no-op for toast
  Future<void> cancelAllNotifications() async {
    // No-op for toast notifications
  }
}
