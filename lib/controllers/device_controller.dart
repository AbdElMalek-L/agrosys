import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DeviceController extends GetxController {
  static const String _storageKey = 'devices';

  // This list stores all devices
  var devices = <Map<String, String>>[].obs;

  // Variable to store selected device
  var selectedDevice = RxnString(); // <--- ADD THIS LINE HERE

  int id = 0;

  @override
  void onInit() {
    super.onInit();
    loadDevices();
  }

  // This method lets you select a device
  void selectDevice(String deviceName) {
    // <--- ADD THIS METHOD HERE
    selectedDevice.value = deviceName;
  }

  Future<void> loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedDevices = prefs.getString(_storageKey);
    if (storedDevices != null) {
      devices.value = List<Map<String, String>>.from(
        json.decode(storedDevices),
      );
    }
  }

  Future<void> saveDevices() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(devices));
  }

  void removeDevice(int index) {
    devices.removeAt(index);
    saveDevices();
  }

  void updateDevice(
    String id,
    String model,
    String name,
    String phoneNumber,
    String passWord,
  ) {
    int index = devices.indexWhere((device) => device['id'] == id);

    if (index != -1) {
      devices[index] = {
        'id': id,
        'model': model,
        'name': name,
        'phoneNumber': phoneNumber,
        'passWord': passWord,
      };
      saveDevices();
    }
  }

  Future<int> getNextDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    int lastId = prefs.getInt('lastDeviceId') ?? 0;
    lastId++;
    await prefs.setInt('lastDeviceId', lastId);
    return lastId;
  }

  Future<void> addDevice(
    String model,
    String name,
    String phoneNumber,
    String passWord,
  ) async {
    int id = await getNextDeviceId();

    final newDevice = {
      'id': id.toString(),
      'model': model,
      'name': name,
      'phoneNumber': phoneNumber,
      'passWord': passWord,
    };

    devices.insert(0, newDevice);
    saveDevices();
  }
}
