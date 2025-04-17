import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrosys/data/models/device_storage.dart';
import 'package:agrosys/controllers/sms_controller.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:agrosys/controllers/notification_service.dart';

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(ScheduleTaskHandler());
}

class ScheduleTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  SMSController? _smsController;
  Timer? _timer;
  NotificationService? _notificationService;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;
    _smsController = SMSController();
    _notificationService = NotificationService();
    await _notificationService?.initialize();

    // Start the timer to check schedules every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      await _checkAndExecuteSchedules();
    });
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    // Not used in this example
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    _timer?.cancel();
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onButtonPressed(String id) {
    // Not used in this example
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    // This is called when the service is in repeat mode.
    await _checkAndExecuteSchedules();
  }

  // Check schedules and execute commands
  Future<void> _checkAndExecuteSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('stored_devices');
    if (storedData == null) return;

    final List<dynamic> jsonList = jsonDecode(storedData);
    final devices =
        jsonList.map((e) => DeviceStorage.fromJson(e).toDevice()).toList();
    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

    for (final device in devices) {
      if (!device.isScheduleEnabled ||
          device.scheduleStartTime == null ||
          device.scheduleEndTime == null) {
        continue;
      }

      // Check if it's 5 minutes before turn on time to show preview notification
      if (_isTimeBeforeEvent(device.scheduleStartTime!, currentTime, 5)) {
        await _notificationService?.scheduleNotification(
          device: device,
          scheduledTime: device.scheduleStartTime!,
          isStartEvent: true,
          showPreview: true,
        );
      }

      // Check if it's 5 minutes before turn off time to show preview notification
      if (_isTimeBeforeEvent(device.scheduleEndTime!, currentTime, 5)) {
        await _notificationService?.scheduleNotification(
          device: device,
          scheduledTime: device.scheduleEndTime!,
          isStartEvent: false,
          showPreview: true,
        );
      }

      // Check if it's time to turn on
      if (_isTimeToTurnOn(device, currentTime)) {
        await _sendPowerCommand(device, true);
      }
      // Check if it's time to turn off
      else if (_isTimeToTurnOff(device, currentTime)) {
        await _sendPowerCommand(device, false);
      }
    }
  }

  bool _isTimeBeforeEvent(
    TimeOfDay scheduleTime,
    TimeOfDay currentTime,
    int minutesBefore,
  ) {
    // Convert both times to minutes since midnight for easy comparison
    final scheduleTotalMinutes = scheduleTime.hour * 60 + scheduleTime.minute;
    final currentTotalMinutes = currentTime.hour * 60 + currentTime.minute;

    // The target time is exactly 'minutesBefore' minutes before the scheduled time
    final targetMinutes = scheduleTotalMinutes - minutesBefore;

    // If target time wraps to previous day (negative value)
    if (targetMinutes < 0) {
      return currentTotalMinutes == (24 * 60 + targetMinutes);
    }

    return currentTotalMinutes == targetMinutes;
  }

  bool _isTimeToTurnOn(Device device, TimeOfDay currentTime) {
    if (device.scheduleStartTime == null) return false;

    // If device is already on, no need to turn it on
    if (device.isPoweredOn) return false;

    // Check if current time matches start time
    return currentTime.hour == device.scheduleStartTime!.hour &&
        currentTime.minute == device.scheduleStartTime!.minute;
  }

  bool _isTimeToTurnOff(Device device, TimeOfDay currentTime) {
    if (device.scheduleEndTime == null) return false;

    // If device is already off, no need to turn it off
    if (!device.isPoweredOn) return false;

    // Check if current time matches end time
    return currentTime.hour == device.scheduleEndTime!.hour &&
        currentTime.minute == device.scheduleEndTime!.minute;
  }

  Future<void> _sendPowerCommand(Device device, bool turnOn) async {
    final command = "${device.passWord}#${turnOn ? "ON" : "OFF"}#";

    // Update notification to show we're sending a message
    FlutterForegroundTask.updateService(
      notificationTitle: 'جاري إرسال الرسالة',
      notificationText: 'إرسال رسالة إلى ${device.phoneNumber}: $command',
    );

    // Send command using SMS controller
    if (_smsController != null) {
      final success = await _smsController!.sendSimpleSMS(
        phoneNumber: device.phoneNumber,
        message: command,
      );

      if (success) {
        // Update notification to show success
        FlutterForegroundTask.updateService(
          notificationTitle: 'تم إرسال الرسالة',
          notificationText: 'تم إرسال الرسالة إلى ${device.phoneNumber} بنجاح',
        );

        // Show schedule notification
        await _notificationService?.showScheduleNotification(
          device: device,
          isStartEvent: turnOn,
        );

        // Update device state in storage
        await _updateDeviceState(device, turnOn);
      }
    }
  }

  Future<void> _updateDeviceState(Device device, bool isPoweredOn) async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('stored_devices');
    if (storedData == null) return;

    final List<dynamic> jsonList = jsonDecode(storedData);
    final devices =
        jsonList.map((e) => DeviceStorage.fromJson(e).toDevice()).toList();

    final index = devices.indexWhere((d) => d.id == device.id);
    if (index != -1) {
      final updatedDevice = device.copyWith(isPoweredOn: isPoweredOn);
      devices[index] = updatedDevice;

      final updatedJsonList =
          devices.map((d) => DeviceStorage.fromDomain(d).toJson()).toList();
      await prefs.setString('stored_devices', jsonEncode(updatedJsonList));
    }
  }
}

class BackgroundServiceManager {
  static Future<void> initialize() async {
    // Initialize the foreground task
    await _initForegroundTask();

    // Start the foreground service
    await _startForegroundService();
  }

  static Future<void> _initForegroundTask() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'agrosys_service',
        channelName: 'Agrosys Schedule Service',
        channelDescription:
            'Monitoring device schedules and sending SMS commands',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher_icon',
        ),
        buttons: [
          const NotificationButton(id: 'stopService', text: 'إيقاف الخدمة'),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 60000, // 1 minute
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<void> _startForegroundService() async {
    // Check if the service is already running
    if (await FlutterForegroundTask.isRunningService) {
      return;
    }

    // Start the foreground service
    await FlutterForegroundTask.startService(
      notificationTitle: 'جدول الري',
      notificationText: 'جاري مراقبة الجدول',
      callback: startCallback,
    );
  }

  static Future<void> stopService() async {
    await FlutterForegroundTask.stopService();
  }
}
