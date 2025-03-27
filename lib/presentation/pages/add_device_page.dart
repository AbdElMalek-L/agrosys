// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'home_screen.dart';
// import '../widgets/device_models_card.dart';
// import '../themes/colors.dart';
// import '../widgets/header.dart';
// import '../../controllers/device_controller.dart';

// class AddDevicePage extends StatefulWidget {
//   const AddDevicePage({super.key});

//   @override
//   _AddDevicePageState createState() => _AddDevicePageState();
// }

// class _AddDevicePageState extends State<AddDevicePage> {
//   final _formKey = GlobalKey<FormState>(); // Form validation key
//   String? _deviceName;
//   String? _deviceNumber;
//   String? _password;
//   String? _selectedModel;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfff6fcf8),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Center(child: Header(title: "إضافة جهاز جديد")),

//             // Scrollable content
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Lottie.asset(
//                       'assets/Adddevice.json',
//                       height: 200,
//                     ), // Dynamic height
//                     const SizedBox(height: 20),
//                     _buildDeviceForm(),
//                     const SizedBox(height: 80), // Add bottom spacing
//                   ],
//                 ),
//               ),
//             ),

//             // Fixed bottom button
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     _formKey.currentState!.save(); // Save form data

//                     // Save device to storage
//                     _addDeviceToStorage();

//                     // Navigate to HomeScreen after adding the device
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (context) => HomeScreen()),
//                     );
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   elevation: 0,
//                   backgroundColor: const Color(0xFF009200),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 60,
//                     vertical: 14,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(
//                       Icons.arrow_back_outlined,
//                       size: 20,
//                       color: Colors.white,
//                     ),
//                     const SizedBox(width: 5),
//                     Text(
//                       "إضافة جهاز",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 20,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // The form for adding device details
//   Widget _buildDeviceForm() {
//     return Form(
//       key: _formKey,
//       child: Directionality(
//         textDirection: TextDirection.rtl,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
//               child: DeviceModelsCard(
//                 models: const ["RTU5024", "AGROS001", "MODEL003"],
//                 onModelSelected: (model) {
//                   setState(() {
//                     _selectedModel = model; // Store selected model
//                   });
//                 },
//               ),
//             ),
//             _buildInputField('اسم الجهاز', (value) => _deviceName = value),
//             _buildInputField(
//               'رقم الخاص بجهاز',
//               (value) => _deviceNumber = value,
//             ),
//             _buildInputField('الرقم السري', (value) => _password = value),
//           ],
//         ),
//       ),
//     );
//   }

//   // A reusable widget for text input fields
//   Widget _buildInputField(String label, Function(String?)? onSaved) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
//       child: TextFormField(
//         textAlign: TextAlign.right,
//         textDirection: TextDirection.rtl,
//         decoration: InputDecoration(
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 12,
//           ),
//           labelText: label,
//           labelStyle: TextStyle(
//             color: Colors.grey[600],
//             textBaseline: TextBaseline.alphabetic,
//           ),
//           floatingLabelAlignment: FloatingLabelAlignment.start,
//           alignLabelWithHint: true,
//           floatingLabelBehavior: FloatingLabelBehavior.auto,
//           enabledBorder: const OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.transparent),
//             borderRadius: BorderRadius.all(Radius.circular(8)),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: mainColor, width: 2.0),
//             borderRadius: const BorderRadius.all(Radius.circular(8)),
//           ),
//           border: const OutlineInputBorder(
//             borderSide: BorderSide.none,
//             borderRadius: BorderRadius.all(Radius.circular(8)),
//           ),
//         ),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'الرجاء إدخال قيمة';
//           }
//           return null;
//         },
//         onSaved: onSaved, // Save the value to the corresponding field
//       ),
//     );
//   }

//   // Function to save device data to storage
//   void _addDeviceToStorage() async {
//     final controller = DeviceController(); // Get the controller
//     final newDevice = {
//       'model': _selectedModel ?? 'Unknown',
//       'name': _deviceName ?? 'Unnamed Device',
//       'phoneNumber': _deviceNumber ?? 'Unknown',
//       'passWord': _password ?? 'Unknown',
//     };

//     // Save device using the controller
//     await controller.addDevice(
//       newDevice['model']!,
//       newDevice['name']!,
//       newDevice['phoneNumber']!,
//       newDevice['passWord']!,
//     );
//   }
// }
