import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_background_messenger/flutter_background_messenger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final messenger = FlutterBackgroundMessenger();

// Function to send an SMS message
Future<void> sendSMS() async {
  try {
    final success = await messenger.sendSMS(
      phoneNumber: '+212631200554',
      message: 'KJDFQKHFAIUZVNJSKLDQNVGLQKJFJLKzefhu',
    );

    // Show toast message to indicate success or failure
    Fluttertoast.showToast(
      msg: success ? "SMS sent successfully" : "Failed to send SMS",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  } catch (e) {
    print("Error sending SMS: $e"); // Log error for debugging
    Fluttertoast.showToast(
      msg: 'Error sending SMS: $e',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = MediaQuery.of(context).size.width;
          bool isSmallScreen = screenWidth < 600;

          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 20 : screenWidth * 0.1,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Lottie file
                  Lottie.asset(
                    'assets/lottie_animation.json',
                    height: isSmallScreen ? 200 : 300,
                  ),
                  SizedBox(height: isSmallScreen ? 40 : 70),
                  // App title
                  Text(
                    "AgroSys: تحكم ذكي في الري",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF009200),
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: isSmallScreen ? 10 : 20),
                  // Description text
                  Text(
                    "قم بإدارة نظام الري الخاص بك بسهولة باستخدام أوامر SMS تلقائية. راقب وتحكم في أجهزتك عن بُعد لتحقيق إدارة مياه فعالة.",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: isSmallScreen ? 100 : 200),
                  // Start button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF009200),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 60 : 80,
                        vertical: isSmallScreen ? 10 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    child: Text(
                      "ابدأ",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
              // Animated power button
              GestureDetector(
                onTap: _togglePower,
                child: Lottie.asset(
                  isPowerOn ? controlAssetPowerOff : controlAssetPowerOn,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
              // Status text
              Text(
                isPowerOn ? "إيقاف التشغيل" : "تشغيل",
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

class DeviceCard extends StatefulWidget {
  const DeviceCard({super.key});

  @override
  _DeviceCardState createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, // Adds a soft shadow effect
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          childrenPadding: EdgeInsets.only(bottom: 12),
          iconColor: Colors.green[700],
          collapsedIconColor: Colors.green[700],
          trailing: AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0, // Smooth icon rotation
            duration: Duration(milliseconds: 300),
            child: Icon(Icons.expand_more),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "RTU5024",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "بركان، سيدي سليم الشرا",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          children: [
            Divider(
              indent: 16,
              endIndent: 16,
              thickness: 1,
            ), // Stylish separator
            ListTile(
              leading: Icon(Icons.add, color: Colors.green[700]),
              title: Text(
                "إضافة جهاز جديد",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddDevicePage()),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Colors.green[50], // Subtle background color
              splashColor: Colors.green[100], // Interactive ripple effect
            ),
          ],
        ),
      ),
    );
  }
}

class AddDevicePage extends StatelessWidget {
  const AddDevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("إضافة جهاز جديد")),
      body: Center(child: Text("صفحة إضافة جهاز")),
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
