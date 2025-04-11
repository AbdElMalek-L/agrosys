import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'details_screen.dart';
import 'package:agrosys/controllers/device_controller.dart';

import '../widgets/devices_card.dart';
import '../widgets/header.dart';
import '../widgets/recent_activity_widget.dart';
import '../widgets/signal_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DeviceController deviceController = Get.put(DeviceController());
  bool isPowerOn = false;

  String controlAssetPowerOn = "assets/power_animation.json";
  String controlAssetPowerOff = "assets/power_off.json";

  @override
  void initState() {
    super.initState();
    _loadPowerState();
    deviceController.loadDevices();
  }

  Future<void> _loadPowerState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isPowerOn = prefs.getBool('isPowerOn') ?? false;
    });
  }

  Future<void> _togglePower() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isPowerOn = !isPowerOn;
      prefs.setBool('isPowerOn', isPowerOn);
    });
    sendSMS();
  }

  void sendSMS() {
    // Your logic to send SMS to RTU5024
    print("Sending SMS to RTU5024...");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6fcf8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DetailsScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "إعداد توقيت التشغيل",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                Center(child: Header(title: "لوحة التحكم")),

                const SizedBox(height: 20),

                Obx(() => DevicesCard()),

                const SizedBox(height: 20),

                const SignalIndicator(),

                const SizedBox(height: 20),

                Center(
                  child: GestureDetector(
                    onTap: _togglePower,
                    child: Lottie.asset(
                      isPowerOn ? controlAssetPowerOff : controlAssetPowerOn,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                Center(
                  child: Text(
                    isPowerOn ? "إيقاف التشغيل" : "تشغيل",
                    textDirection: TextDirection.rtl,
                  ),
                ),

                const SizedBox(height: 20),

                // BOUTON RESPONSIVE POUR DETAILS SCREEN
                const SizedBox(height: 20),

                const RecentActivityWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
