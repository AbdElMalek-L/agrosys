import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/presentation/widgets/header.dart';
import 'package:flutter/material.dart';

// TODO: add update password for device
// TODO: add update device number
// TODO: add delete device
// TODO: make this page useful XD

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.device});

  final Device device; // Device passed via constructor

  @override
  Widget build(BuildContext context) {
    // Correct build method signature
    return Scaffold(
      appBar: AppBar(
        // Proper AppBar widget
        title: Header(title: device.name), // Set header as title
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove shadow if needed
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Text("هنا يمكنك إضافة إعدادات الجهاز"),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("إغلاق"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
