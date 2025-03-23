import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modules/sent_sms.dart';
import '../components/device_card.dart';
import 'dart:convert';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "لوحة التحكم",
      style: TextStyle(
        color: const Color(0xff009200),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isPowerOn = false;

  String controlAssetPowerOn = "assets/power_animation.json";
  String controlAssetPowerOff = "assets/power_off.json";

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
    print("Loaded power state: \$isPowerOn"); // Debugging log
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
              Center(child: Header()),
              SizedBox(height: 20),
              DeviceCard(),
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
              RecentActivity(),
            ],
          ),
        ),
      ),
    );
  }
}

class RecentActivity extends StatefulWidget {
  const RecentActivity({super.key});

  @override
  _RecentActivityState createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity> {
  List<Map<String, String>> activities = [];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedActivities = prefs.getString('recent_activities');
    if (storedActivities != null) {
      setState(() {
        activities = List<Map<String, String>>.from(
          json.decode(storedActivities),
        );
      });
    }
  }

  Future<void> _addActivity(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final newActivity = {
      'title': title,
      'subtitle': subtitle,
      'icon': icon.codePoint.toString(),
      'color': color.value.toString(),
    };
    activities.insert(0, newActivity);
    await prefs.setString('recent_activities', json.encode(activities));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "النشاط الأخير",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          if (activities.isEmpty)
            Text("لا يوجد نشاط حتى الآن", style: TextStyle(color: Colors.grey)),
          ...activities.map(
            (activity) => ListTile(
              leading: Icon(
                IconData(
                  int.parse(activity['icon']!),
                  fontFamily: 'MaterialIcons',
                ),
                color: Color(int.parse(activity['color']!)),
              ),
              title: Text(activity['title']!),
              subtitle: Text(activity['subtitle']!),
            ),
          ),
        ],
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
