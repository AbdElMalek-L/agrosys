import 'package:get/get.dart'; // Import GetX package
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Convert this class into a GetX Controller (extend GetxController)
class DeviceController extends GetxController {
  static const String _storageKey = 'devices';

  // Create an observable list to store devices
  var devices = <Map<String, String>>[].obs;
  int id = 0;

  // Load devices from SharedPreferences when the controller is initialized
  @override
  void onInit() {
    super.onInit();
    loadDevices();
  }

  // Convert this method into an observable function
  Future<void> loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedDevices = prefs.getString(_storageKey);
    if (storedDevices != null) {
      // Assign loaded data to the observable list
      devices.value = List<Map<String, String>>.from(
        json.decode(storedDevices),
      );
    }
  }

  // Convert this method to update the observable list and persist data
  Future<void> saveDevices() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(devices));
  }

  // Create a method to remove a device
  void removeDevice(int index) {
    devices.removeAt(index);
    saveDevices();
  }

  // Create a method to update a device
  void updateDevice(
    String id,
    String model,
    String name,
    String phoneNumber,
    String passWord,
  ) {
    // Find the index of the device with the given ID
    int index = devices.indexWhere((device) => device['id'] == id);

    if (index != -1) {
      // If the device exists, update it
      devices[index] = {
        'id': id, // Ensure the ID remains the same
        'model': model,
        'name': name,
        'phoneNumber': phoneNumber,
        'passWord': passWord,
      };

      saveDevices(); // Save changes to SharedPreferences
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
