/*
  SHARED PREFERENCES DEVICE MODEL

  Converts device model to shared preferences model that we can stroe in our 
  local storage.

  

 */

import 'package:agrosys/domain/models/device.dart';

class DeviceStorage {
  late int id;
  late String model;
  late String name;
  late String phoneNumber;
  late String passWord;
  late bool isPoweredOn;

  //convert storage oobject -> pure device object to use in our app
  Device toDevice() {
    return Device(
      id: id,
      model: model,
      name: name,
      phoneNumber: phoneNumber,
      passWord: passWord,
      isPoweredOn: isPoweredOn,
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
      ..isPoweredOn = device.isPoweredOn;
  }

  // Convert JSON -> DeviceStorage
  static DeviceStorage fromJson(Map<String, dynamic> json) {
    return DeviceStorage()
      ..id = json['id']
      ..model = json['model']
      ..name = json['name']
      ..phoneNumber = json['phoneNumber']
      ..passWord = json['passWord']
      ..isPoweredOn = json['isPoweredOn'];
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
    };
  }
}
