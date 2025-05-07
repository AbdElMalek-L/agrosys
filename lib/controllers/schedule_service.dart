import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/presentation/cubits/device_cubit.dart';
import 'package:agrosys/controllers/sms_controller.dart';
import 'package:agrosys/controllers/notification_service.dart';

class ScheduleService {
  final DeviceCubit _deviceCubit;
  final SMSController _smsController;
  Timer? _scheduleTimer;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final NotificationService _notificationService = NotificationService();
  
  // Add cooldown tracking
  final Map<String, DateTime> _lastCommandTime = {};
  final Duration _commandCooldown = const Duration(minutes: 1);

  ScheduleService(this._deviceCubit, this._smsController);

  void startScheduleMonitoring() {
    // Check schedule every minute
    _scheduleTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndExecuteSchedules();
    });
  }

  void stopScheduleMonitoring() {
    _scheduleTimer?.cancel();
    _scheduleTimer = null;
  }

  void _checkAndExecuteSchedules() {
    final devices = _deviceCubit.state;
    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
    final currentDayIndex = now.weekday - 1; // 0 = Monday, 6 = Sunday

    for (final device in devices) {
      if (!device.isScheduleEnabled ||
          device.scheduleStartTime == null ||
          device.scheduleEndTime == null ||
          !_isScheduleEnabledForDay(device, currentDayIndex)) {
        continue;
      }

      // Check if it's time to turn on
      if (_isTimeToTurnOn(device, currentTime)) {
        _sendPowerCommand(device, true);
      }
      // Check if it's time to turn off
      else if (_isTimeToTurnOff(device, currentTime)) {
        _sendPowerCommand(device, false);
      }
    }
  }

  // Check if schedule is enabled for the given day
  bool _isScheduleEnabledForDay(Device device, int dayIndex) {
    if (dayIndex < 0 || dayIndex >= device.scheduleDays.length) {
      return false;
    }
    return device.scheduleDays[dayIndex];
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

  void _sendPowerCommand(Device device, bool turnOn) {
    final command = "${device.passWord}#${turnOn ? "ON" : "OFF"}#";
    final commandKey = "${device.phoneNumber}_$command";

    // Check if we're in cooldown period
    final lastCommandTime = _lastCommandTime[commandKey];
    if (lastCommandTime != null) {
      final timeSinceLastCommand = DateTime.now().difference(lastCommandTime);
      if (timeSinceLastCommand < _commandCooldown) {
        debugPrint('ScheduleService: Skipping command due to cooldown. Time remaining: ${_commandCooldown - timeSinceLastCommand}');
        return;
      }
    }

    // Get the current context from the navigator key
    final context = _navigatorKey.currentContext;
    if (context == null) return; // Skip if no context is available

    // Update last command time
    _lastCommandTime[commandKey] = DateTime.now();

    _smsController.sendCommandWithResponse(
      context: context,
      phoneNumber: device.phoneNumber,
      command: command,
      onResult: (success, response) {
        if (success) {
          // Show a notification
          _notificationService.showScheduleNotification(
            device: device,
            isStartEvent: turnOn,
          );

          // Update device state in the cubit
          final updatedDevice = device.copyWith(isPoweredOn: turnOn);
          _deviceCubit.updateDevice(device, updatedDevice);
        } else {
          // If command failed, remove the cooldown so we can retry
          _lastCommandTime.remove(commandKey);
        }
      },
    );
  }

  // Method to schedule notifications for all devices with active schedules
  Future<void> scheduleAllNotifications() async {
    final devices = _deviceCubit.state;
    final now = DateTime.now();
    final currentDayIndex = now.weekday - 1; // 0 = Monday, 6 = Sunday

    for (final device in devices) {
      if (!device.isScheduleEnabled ||
          device.scheduleStartTime == null ||
          device.scheduleEndTime == null ||
          !_isScheduleEnabledForDay(device, currentDayIndex)) {
        // Cancel existing notifications if schedule is disabled
        await _notificationService.cancelDeviceNotifications(device.id);
        continue;
      }

      // Schedule start time notification
      await _notificationService.scheduleNotification(
        device: device,
        scheduledTime: device.scheduleStartTime!,
        isStartEvent: true,
      );

      // Schedule preview notification 5 minutes before start time
      await _notificationService.scheduleNotification(
        device: device,
        scheduledTime: device.scheduleStartTime!,
        isStartEvent: true,
        showPreview: true,
      );

      // Schedule end time notification
      await _notificationService.scheduleNotification(
        device: device,
        scheduledTime: device.scheduleEndTime!,
        isStartEvent: false,
      );

      // Schedule preview notification 5 minutes before end time
      await _notificationService.scheduleNotification(
        device: device,
        scheduledTime: device.scheduleEndTime!,
        isStartEvent: false,
        showPreview: true,
      );
    }
  }
}
