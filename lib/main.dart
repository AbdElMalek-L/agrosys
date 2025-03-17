import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_background_messenger/flutter_background_messenger.dart';

final messenger = FlutterBackgroundMessenger();

Future<void> sendSMS() async {
  try {
    final success = await messenger.sendSMS(
      phoneNumber: '+212631200554',
      message: 'KJDFQKHFAIUZVNJSKLDQNVGLQKJFJLKzefhu',
    );

    if (success) {
      Fluttertoast.showToast(
        msg: "SMS sent successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Failed to send SMS",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  } catch (e) {
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/lottie_animation.json', height: 300),
              const SizedBox(height: 70),
              const Text(
                "AgroSys: تحكم ذكي في الري",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF009200),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                "قم بإدارة نظام الري الخاص بك بسهولة باستخدام أوامر SMS تلقائية. راقب وتحكم في أجهزتك عن بُعد لتحقيق إدارة مياه فعالة.",
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 200),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF009200), // Green color
                  padding: const EdgeInsets.symmetric(
                    horizontal: 80,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                child: const Text(
                  "ابدأ",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
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
              Center(
                child: Column(
                  children: [
                    IconButton(
                      icon: Lottie.asset(
                        !isPowerOn ? controlAssetPowerOn : controlAssetPowerOff,
                        height: 150, // Adjusted size for a button-friendly UI
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                      onPressed: () {
                        setState(() {
                          isPowerOn = !isPowerOn;
                        });
                        sendSMS();
                      },
                    ),
                    Text(isPowerOn ? "إيقاف التشغيل" : "تشغيل"),

                    // ActionButton(
                    //   icon: LucideIcons.calendarClock,
                    //   label: "ضبط الجدول",
                    // ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              RecentActivity(),
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

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

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
          ListTile(
            leading: Icon(LucideIcons.power, color: Colors.blue),
            title: Text("تم تشغيل الجهاز"),
            subtitle: Text("اليوم، 2:34 مساءً"),
          ),
          ListTile(
            leading: Icon(LucideIcons.bellRing, color: Colors.red),
            title: Text("تنبيه: تم استعادة الإشارة"),
            subtitle: Text("اليوم، 1:15 مساءً"),
          ),
        ],
      ),
    );
  }
}
