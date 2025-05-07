/*

  STORAGE REPO
  
  This implements the device repo and handles stroing, retriving, updating,
  deleting in the local storage.

 */

import 'package:agrosys/data/models/device_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/domain/repository/device_repo.dart';
import 'dart:convert';

class DeviceStorageRepo implements DeviceRepo {
  final SharedPreferences storage;

  static const String devicesKey = "stored_devices";

  DeviceStorageRepo(this.storage);

  // Get all devices
  @override
  Future<List<Device>> getDevices() async {
    final storedData = storage.getString(devicesKey);
    if (storedData == null) return [];

    List<dynamic> jsonList = jsonDecode(storedData);
    return jsonList.map((e) => DeviceStorage.fromJson(e).toDevice()).toList();
  }

  // Add a new device
  @override
  Future<void> addDevice(Device device) async {
    List<Device> devices = await getDevices();
    devices.add(device);
    await _saveDevices(devices);
  }

  // Update a device by ID
  @override
  Future<void> updateDevice(Device updatedDevice) async {
    List<Device> devices = await getDevices();
    int index = devices.indexWhere((d) => d.id == updatedDevice.id);
    if (index != -1) {
      devices[index] = updatedDevice;
      await _saveDevices(devices);
    }
  }

  // Delete a device by ID
  @override
  Future<void> deleteDevice(Device deletedDevice) async {
    List<Device> devices = await getDevices();
    devices.removeWhere((d) => d.id == deletedDevice.id);
    await _saveDevices(devices);
  }

  // Helper function to save devices list
  Future<void> _saveDevices(List<Device> devices) async {
    List<Map<String, dynamic>> jsonList =
        devices.map((d) => DeviceStorage.fromDomain(d).toJson()).toList();
    await storage.setString(devicesKey, jsonEncode(jsonList));
  }
}
