// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'home_screen.dart';

// List<Map<String, String>> devices = [];

// class IntroPage extends StatelessWidget {
//   const IntroPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           double screenWidth = MediaQuery.of(context).size.width;
//           double screenHeight = MediaQuery.of(context).size.height;
//           bool isSmallScreen = screenWidth < 600;

//           return Center(
//             child: Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isSmallScreen ? 20 : screenWidth * 0.1,
//               ),
//               child: Column(
//                 textDirection: TextDirection.rtl,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // Animated Lottie file
//                   Expanded(
//                     child: Column(
//                       textDirection: TextDirection.rtl,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Lottie.asset(
//                           'assets/lottie_animation.json',
//                           height: screenHeight * 0.4,
//                         ),
//                         SizedBox(height: isSmallScreen ? 40 : 70),
//                         // App title
//                         Text(
//                           "AgroSys: تحكم ذكي في الري",
//                           style: TextStyle(
//                             fontSize: isSmallScreen ? 20 : 24,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF009200),
//                           ),
//                           textAlign: TextAlign.center,
//                           textDirection: TextDirection.rtl,
//                         ),
//                         SizedBox(height: isSmallScreen ? 10 : 20),
//                         // Description text
//                         Text(
//                           "قم بإدارة نظام الري الخاص بك بسهولة باستخدام أوامر SMS تلقائية. راقب وتحكم في أجهزتك عن بُعد لتحقيق إدارة مياه فعالة.",
//                           style: TextStyle(
//                             fontSize: isSmallScreen ? 14 : 16,
//                             color: Colors.black87,
//                           ),
//                           textAlign: TextAlign.center,
//                           textDirection: TextDirection.rtl,
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Start button
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder:
//                               (context) =>
//                                   // devices.isEmpty
//                                   //     ? AddDevicePage()
//                                   // :
//                                   HomeScreen(),
//                         ),
//                       );
//                     },

//                     style: ElevatedButton.styleFrom(
//                       elevation: 0,
//                       backgroundColor: Color(0xFF009200),
//                       padding: EdgeInsets.symmetric(
//                         horizontal: isSmallScreen ? 60 : 80,
//                         vertical: isSmallScreen ? 15 : 20,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.arrow_back_outlined,
//                           size: 20,
//                           color: Colors.white,
//                         ),
//                         SizedBox(width: 5),
//                         Text(
//                           "ابدأ",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: isSmallScreen ? 18 : 20,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
