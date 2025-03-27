import 'package:agrosys/data/repository/device_storage_repo.dart';
import 'package:agrosys/domain/repository/device_repo.dart';
import 'package:agrosys/presentation/pages/device_test_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize the repository with SharedPreferences
  final deviceStorageRepo = DeviceStorageRepo(prefs);

  // Run app
  runApp(MyApp(deviceRepo: deviceStorageRepo));
}

class MyApp extends StatelessWidget {
  // Database injection through the app
  final DeviceRepo deviceRepo;

  const MyApp({super.key, required this.deviceRepo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DeviceTestPage(deviceRepo: deviceRepo),
    );
  }
}
