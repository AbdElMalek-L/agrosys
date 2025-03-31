// TODO: remove this.

import 'package:flutter/material.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final DeviceController deviceController = Get.put(DeviceController());
//   bool isPowerOn = false;

//   String controlAssetPowerOn = "assets/power_animation.json";
//   String controlAssetPowerOff = "assets/power_off.json";

//   @override
//   void initState() {
//     super.initState();
//     _loadPowerState();
//     deviceController.loadDevices(); // Ensure devices are loaded at startup
//   }

//   // Load saved power state from shared preferences
//   Future<void> _loadPowerState() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       isPowerOn = prefs.getBool('isPowerOn') ?? false;
//     });
//   }

//   // Toggle power state and send an SMS
//   Future<void> _togglePower() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       isPowerOn = !isPowerOn;
//       prefs.setBool('isPowerOn', isPowerOn);
//     });
//     print("Power toggled: $isPowerOn"); // Debugging log
//     sendSMS();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfff6fcf8),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(child: Header(title: "لوحة التحكم")),
//                 SizedBox(height: 20),

//                 // Display devices dynamically using GetX
//                 Obx(() => DevicesCard()),

//                 SizedBox(height: 20),

//                 const SignalIndicator(),
//                 SizedBox(height: 20),

//                 // Animated power button
//                 Center(
//                   child: GestureDetector(
//                     onTap: _togglePower,
//                     child: Lottie.asset(
//                       isPowerOn ? controlAssetPowerOff : controlAssetPowerOn,
//                       height: 150,
//                       width: 150,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 // Status text
//                 Center(
//                   child: Text(
//                     isPowerOn ? "إيقاف التشغيل" : "تشغيل",
//                     textDirection: TextDirection.rtl,
//                   ),
//                 ),
//                 const RecentActivityWidget(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class SignalIndicator extends StatelessWidget {
//   const SignalIndicator({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Icon(Icons.signal_cellular_alt, color: Colors.green),
//           Text(
//             "متصل",
//             style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
// }
