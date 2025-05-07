import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/controllers/sms_controller.dart';

class ScheduleService {
  final SMSController _smsController = SMSController();
  Timer? _scheduleTimer;
  final Map<String, DateTime> _lastCommandTime = {};
  final Map<String, int> _retryCount = {};
  final Duration _commandCooldown = const Duration(minutes: 1);
  final Duration _retryDelay = const Duration(seconds: 30);
  final int _maxRetries = 3;
  BuildContext? _context;
  Device? _currentDevice;
  bool _isProcessing = false;

  void setContext(BuildContext context) {
    _context = context;
    debugPrint('ScheduleService: Context set');
  }

  void startScheduleCheck(Device device) {
    debugPrint('ScheduleService: Starting schedule check for device ${device.name}');
    debugPrint('ScheduleService: Schedule enabled: ${device.isScheduleEnabled}');
    debugPrint('ScheduleService: Start time: ${device.scheduleStartTime}');
    debugPrint('ScheduleService: End time: ${device.scheduleEndTime}');
    debugPrint('ScheduleService: Schedule days: ${device.scheduleDays}');

    _currentDevice = device;

    // Cancel existing timer if any
    _scheduleTimer?.cancel();

    // Calculate time until next minute
    final now = DateTime.now();
    final secondsUntilNextMinute = 60 - now.second;
    
    // Start timer at the beginning of the next minute
    Future.delayed(Duration(seconds: secondsUntilNextMinute), () {
      // Then start periodic timer every minute
      _scheduleTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        if (!_isProcessing) {
          debugPrint('ScheduleService: Timer tick at ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}');
          _checkAndSendCommands(device);
        } else {
          debugPrint('ScheduleService: Skipping check - still processing previous command');
        }
      });
      
      // Initial check
      if (!_isProcessing) {
        _checkAndSendCommands(device);
      }
    });
  }

  void updateSchedule(Device device) {
    debugPrint('ScheduleService: Updating schedule for device ${device.name}');
    debugPrint('ScheduleService: New schedule enabled: ${device.isScheduleEnabled}');
    debugPrint('ScheduleService: New start time: ${device.scheduleStartTime}');
    debugPrint('ScheduleService: New end time: ${device.scheduleEndTime}');
    debugPrint('ScheduleService: New schedule days: ${device.scheduleDays}');

    _currentDevice = device;

    // If schedule is enabled, perform an immediate check
    if (device.isScheduleEnabled && !_isProcessing) {
      debugPrint('ScheduleService: Performing immediate check after schedule update');
      _checkAndSendCommands(device);
    } else {
      // If schedule is disabled, stop the timer
      stopScheduleCheck();
    }
  }

  void stopScheduleCheck() {
    debugPrint('ScheduleService: Stopping schedule check');
    _scheduleTimer?.cancel();
    _scheduleTimer = null;
    _lastCommandTime.clear();
    _retryCount.clear();
    _currentDevice = null;
    _isProcessing = false;
  }

  void _checkAndSendCommands(Device device) {
    if (!device.isScheduleEnabled || _isProcessing) {
      debugPrint('ScheduleService: Schedule is not enabled or still processing');
      return;
    }

    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
    final currentDay = now.weekday - 1; // Convert to 0-based index (Monday = 0)

    debugPrint('ScheduleService: Current time: ${currentTime.hour}:${currentTime.minute}:${now.second}');
    debugPrint('ScheduleService: Current day index: $currentDay');
    debugPrint('ScheduleService: Schedule days: ${device.scheduleDays}');
    debugPrint('ScheduleService: Is current day enabled: ${device.scheduleDays[currentDay]}');

    // Check if schedule is active for current day
    if (!device.scheduleDays[currentDay]) {
      debugPrint('ScheduleService: Schedule not active for current day');
      return;
    }

    // Convert schedule times to TimeOfDay
    final startTime = device.scheduleStartTime;
    final endTime = device.scheduleEndTime;

    if (startTime == null || endTime == null) {
      debugPrint('ScheduleService: Start or end time is null');
      return;
    }

    debugPrint('ScheduleService: Checking times - Current: ${currentTime.hour}:${currentTime.minute}:${now.second}, Start: ${startTime.hour}:${startTime.minute}, End: ${endTime.hour}:${endTime.minute}');

    // Check if current time matches start or end time exactly
    if (_isExactTimeMatch(currentTime, startTime)) {
      debugPrint('ScheduleService: Time matches start time exactly - Sending ON command');
      _sendCommand(device, true); // Send ON command
    } else if (_isExactTimeMatch(currentTime, endTime)) {
      debugPrint('ScheduleService: Time matches end time exactly - Sending OFF command');
      _sendCommand(device, false); // Send OFF command
    } else {
      debugPrint('ScheduleService: No exact time match found');
    }
  }

  bool _isExactTimeMatch(TimeOfDay current, TimeOfDay target) {
    // Compare hours and minutes exactly
    final match = current.hour == target.hour && current.minute == target.minute;
    debugPrint('ScheduleService: Exact time match check - Current: ${current.hour}:${current.minute}, Target: ${target.hour}:${target.minute}, Match: $match');
    return match;
  }

  void _sendCommand(Device device, bool turnOn) {
    if (_isProcessing) {
      debugPrint('ScheduleService: Skipping command - still processing previous command');
      return;
    }

    final command = turnOn ? "ON" : "OFF";
    final commandKey = "${device.phoneNumber}_$command";

    debugPrint('ScheduleService: Attempting to send $command command');
    debugPrint('ScheduleService: Command key: $commandKey');

    // Check if we're in cooldown period
    final lastCommandTime = _lastCommandTime[commandKey];
    if (lastCommandTime != null) {
      final timeSinceLastCommand = DateTime.now().difference(lastCommandTime);
      if (timeSinceLastCommand < _commandCooldown) {
        debugPrint('ScheduleService: Skipping command due to cooldown. Time remaining: ${_commandCooldown - timeSinceLastCommand}');
        return;
      }
    }

    if (_context == null) {
      debugPrint('ScheduleService: Context is null, cannot send command');
      return;
    }

    _isProcessing = true;

    // Update last command time
    _lastCommandTime[commandKey] = DateTime.now();

    debugPrint('ScheduleService: Sending SMS command: ${device.passWord}#$command#');
    _smsController.sendCommandWithResponse(
      context: _context!,
      phoneNumber: device.phoneNumber,
      command: "${device.passWord}#$command#",
      onMessage: (message) {
        debugPrint('ScheduleService: Command response: $message');
        // Reset retry count on successful response
        _retryCount.remove(commandKey);
        _isProcessing = false;
      },
      onResult: (success, response) {
        if (!success) {
          debugPrint('ScheduleService: Failed to send command: $response');
          
          // Increment retry count
          _retryCount[commandKey] = (_retryCount[commandKey] ?? 0) + 1;
          
          // Check if we should retry
          if (_retryCount[commandKey]! <= _maxRetries) {
            debugPrint('ScheduleService: Retrying command (attempt ${_retryCount[commandKey]})');
            Future.delayed(_retryDelay, () {
              _isProcessing = false;
              _sendCommand(device, turnOn);
            });
          } else {
            debugPrint('ScheduleService: Max retries reached for command');
            _retryCount.remove(commandKey);
            _lastCommandTime.remove(commandKey);
            _isProcessing = false;
          }
        } else {
          debugPrint('ScheduleService: Command sent successfully');
          // Reset retry count on success
          _retryCount.remove(commandKey);
          _isProcessing = false;
        }
      },
    );
  }
} 