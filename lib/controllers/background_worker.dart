import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrosys/data/models/device_storage.dart';
import 'package:agrosys/controllers/sms_controller.dart';
import 'package:agrosys/domain/models/device.dart';

class BackgroundScheduler {
  static Timer? _timer;
  static final SMSController _smsController = SMSController();

  // Start a periodic check timer that runs every minute
  static void initialize() {
    // Cancel any existing timer
    _timer?.cancel();

    // Start a new timer that checks every minute
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkAndExecuteSchedules(),
    );
  }

  // Stop the scheduler
  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

  // Check schedules and execute commands
  static Future<void> _checkAndExecuteSchedules() async {
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

  static bool _isTimeToTurnOn(Device device, TimeOfDay currentTime) {
    if (device.scheduleStartTime == null) return false;

    // If device is already on, no need to turn it on
    if (device.isPoweredOn) return false;

    // Check if current time matches start time
    return currentTime.hour == device.scheduleStartTime!.hour &&
        currentTime.minute == device.scheduleStartTime!.minute;
  }

  static bool _isTimeToTurnOff(Device device, TimeOfDay currentTime) {
    if (device.scheduleEndTime == null) return false;

    // If device is already off, no need to turn it off
    if (!device.isPoweredOn) return false;

    // Check if current time matches end time
    return currentTime.hour == device.scheduleEndTime!.hour &&
        currentTime.minute == device.scheduleEndTime!.minute;
  }

  static Future<void> _sendPowerCommand(Device device, bool turnOn) async {
    final command = "${device.passWord}#${turnOn ? "ON" : "OFF"}#";

    // Send command using SMS controller
    await _smsController.sendSimpleSMS(
      phoneNumber: device.phoneNumber,
      message: command,
    );

    // Update device state in storage
    await _updateDeviceState(device, turnOn);
  }

  static Future<void> _updateDeviceState(
    Device device,
    bool isPoweredOn,
  ) async {
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
