import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DeviceStorage {
  static const String _storageKey = 'devices';

  static Future<List<Map<String, String>>> loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedDevices = prefs.getString(_storageKey);
    if (storedDevices != null) {
      return List<Map<String, String>>.from(json.decode(storedDevices));
    }
    return [];
  }

  static Future<void> saveDevices(List<Map<String, String>> devices) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(devices));
  }

  static Future<void> addDevice(
    String model,
    String name,
    String phoneNumber,
    String passWord,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, String>> devices = await loadDevices();

    final newDevice = {
      'model': model,
      'name': name,
      'phoneNumber': phoneNumber,
      'passWord': passWord,
    };

    devices.insert(0, newDevice);
    await prefs.setString(_storageKey, json.encode(devices));
  }
}
