/*
  SHARED PREFERENCES DEVICE MODEL

  Converts device model to shared preferences model that we can stroe in our 
  local storage.

  

 */

import 'package:agrosys/domain/models/device.dart';
import 'package:flutter/material.dart';

class DeviceStorage {
  late int id;
  late String model;
  late String name;
  late String phoneNumber;
  late String passWord;
  late bool isPoweredOn;
  late int signal;
  late bool isScheduleEnabled;
  int? scheduleStartHour;
  int? scheduleStartMinute;
  int? scheduleEndHour;
  int? scheduleEndMinute;
  late List<bool> scheduleDays;

  //convert storage oobject -> pure device object to use in our app
  Device toDevice() {
    return Device(
      id: id,
      model: model,
      name: name,
      phoneNumber: phoneNumber,
      passWord: passWord,
      isPoweredOn: isPoweredOn,
      signal: signal,
      isScheduleEnabled: isScheduleEnabled,
      scheduleStartTime:
          scheduleStartHour != null && scheduleStartMinute != null
              ? TimeOfDay(
                hour: scheduleStartHour!,
                minute: scheduleStartMinute!,
              )
              : null,
      scheduleEndTime:
          scheduleEndHour != null && scheduleEndMinute != null
              ? TimeOfDay(hour: scheduleEndHour!, minute: scheduleEndMinute!)
              : null,
      scheduleDays: scheduleDays,
    );
  }

  // Convert pure device object -> storage object to store in local storage
  static DeviceStorage fromDomain(Device device) {
    return DeviceStorage()
      ..id = device.id
      ..model = device.model
      ..name = device.name
      ..phoneNumber = device.phoneNumber
      ..passWord = device.passWord
      ..isPoweredOn = device.isPoweredOn
      ..signal = device.signal
      ..isScheduleEnabled = device.isScheduleEnabled
      ..scheduleStartHour = device.scheduleStartTime?.hour
      ..scheduleStartMinute = device.scheduleStartTime?.minute
      ..scheduleEndHour = device.scheduleEndTime?.hour
      ..scheduleEndMinute = device.scheduleEndTime?.minute
      ..scheduleDays = device.scheduleDays;
  }

  // Convert JSON -> DeviceStorage
  static DeviceStorage fromJson(Map<String, dynamic> json) {
    // Parse the scheduleDays list from JSON
    List<bool> parsedScheduleDays;
    if (json['scheduleDays'] != null) {
      parsedScheduleDays = List<bool>.from(
        json['scheduleDays'].map((day) => day == 1),
      );
    } else {
      parsedScheduleDays = List.filled(7, true);
    }

    return DeviceStorage()
      ..id = json['id']
      ..model = json['model']
      ..name = json['name']
      ..phoneNumber = json['phoneNumber']
      ..passWord = json['passWord']
      ..isPoweredOn = json['isPoweredOn']
      ..signal = json['signal']
      ..isScheduleEnabled = json['isScheduleEnabled'] ?? false
      ..scheduleStartHour = json['scheduleStartHour']
      ..scheduleStartMinute = json['scheduleStartMinute']
      ..scheduleEndHour = json['scheduleEndHour']
      ..scheduleEndMinute = json['scheduleEndMinute']
      ..scheduleDays = parsedScheduleDays;
  }

  // Convert DeviceStorage -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'model': model,
      'name': name,
      'phoneNumber': phoneNumber,
      'passWord': passWord,
      'isPoweredOn': isPoweredOn,
      'signal': signal,
      'isScheduleEnabled': isScheduleEnabled,
      'scheduleStartHour': scheduleStartHour,
      'scheduleStartMinute': scheduleStartMinute,
      'scheduleEndHour': scheduleEndHour,
      'scheduleEndMinute': scheduleEndMinute,
      'scheduleDays': scheduleDays.map((day) => day ? 1 : 0).toList(),
    };
  }
}
