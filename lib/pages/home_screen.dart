import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modules/sent_sms.dart';
import '../modules/device_storage.dart';
import '../components/recent_activity.dart';
import '../components/devices_card.dart';
import '../components/header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isPowerOn = false;

  String controlAssetPowerOn = "assets/power_animation.json";
  String controlAssetPowerOff = "assets/power_off.json";

  List<Map<String, String>> devices = [];

  @override
  void initState() {
    super.initState();
    _loadPowerState();
  }

  // Load saved power state from shared preferences
  Future<void> _loadPowerState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isPowerOn = prefs.getBool('isPowerOn') ?? false;
    });
  }

  // Load the list of devices

  Future<void> _loadDevices() async {
    final loadedDevices = await DeviceStorage.loadDevices();
    setState(() {
      devices = loadedDevices;
    });
  }

  // Toggle power state and send an SMS
  Future<void> _togglePower() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isPowerOn = !isPowerOn;
      prefs.setBool('isPowerOn', isPowerOn);
    });
    print("Power toggled: \$isPowerOn"); // Debugging log
    sendSMS();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6fcf8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Header(title: "لوحة التحكم")),
              SizedBox(height: 20),
              DevicesCard(devices: devices),
              SizedBox(height: 20),

              SignalIndicator(),
              SizedBox(height: 20),

              // Animated power button
              Center(
                child: GestureDetector(
                  // onTapDown: _addActivity(
                  //   "String title",
                  //   "String subtitle",
                  //   "IconData icon",
                  //   "Color color",
                  // ),
                  onTap: _togglePower,
                  child: Lottie.asset(
                    isPowerOn ? controlAssetPowerOff : controlAssetPowerOn,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Status text
              Center(
                child: Text(
                  isPowerOn ? "إيقاف التشغيل" : "تشغيل",
                  textDirection: TextDirection.rtl,
                ),
              ),
              RecentActivityWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30),
          SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class SignalIndicator extends StatelessWidget {
  const SignalIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.signal_cellular_alt, color: Colors.green),
          Text(
            "متصل",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
