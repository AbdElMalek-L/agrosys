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

import 'package:flutter/material.dart';

class Device {
  final int id;
  final String model;
  final String name;
  final String phoneNumber;
  final String passWord;
  final bool isPoweredOn;
  final int signal;
  final bool isScheduleEnabled;
  final TimeOfDay? scheduleStartTime;
  final TimeOfDay? scheduleEndTime;

  Device({
    required this.id,
    required this.model,
    required this.name,
    required this.phoneNumber,
    required this.passWord,
    this.isPoweredOn = false,
    this.signal = 0,
    this.isScheduleEnabled = false,
    this.scheduleStartTime,
    this.scheduleEndTime,
  });

  Device togglePower() {
    return Device(
      id: id,
      model: model,
      name: name,
      phoneNumber: phoneNumber,
      passWord: passWord,
      isPoweredOn: !isPoweredOn,
      signal: signal,
      isScheduleEnabled: isScheduleEnabled,
      scheduleStartTime: scheduleStartTime,
      scheduleEndTime: scheduleEndTime,
    );
  }

  Device updateSignal(int signal) {
    return Device(
      id: id,
      model: model,
      name: name,
      phoneNumber: phoneNumber,
      passWord: passWord,
      isPoweredOn: isPoweredOn,
      signal: signal,
      isScheduleEnabled: isScheduleEnabled,
      scheduleStartTime: scheduleStartTime,
      scheduleEndTime: scheduleEndTime,
    );
  }

  Device updateDeviceDetails(Device device) {
    return Device(
      id: device.id,
      model: device.model,
      name: device.name,
      phoneNumber: device.phoneNumber,
      passWord: device.passWord,
      isPoweredOn: device.isPoweredOn,
      signal: device.signal,
    );
  }

  Device copyWith({
    bool? isScheduleEnabled,
    TimeOfDay? scheduleStartTime,
    TimeOfDay? scheduleEndTime,
    int? id,
    String? name,
    String? model,
    String? phoneNumber,
    String? passWord,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      model: model ?? this.model,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      passWord: passWord ?? this.passWord,
      isScheduleEnabled: isScheduleEnabled ?? this.isScheduleEnabled,
      scheduleStartTime: scheduleStartTime ?? this.scheduleStartTime,
      scheduleEndTime: scheduleEndTime ?? this.scheduleEndTime,
    );
  }
}
