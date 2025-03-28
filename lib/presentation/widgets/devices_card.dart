// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../themes/colors.dart';
// import '../pages/add_device_page.dart';
// import '../../controllers/device_controller.dart';

// class DevicesCard extends StatelessWidget {
//   final ValueChanged<String>? onDeviceSelected;

//   const DevicesCard({Key? key, this.onDeviceSelected}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final DeviceController deviceController = Get.find<DeviceController>();

//     return Card(
//       elevation: 0,
//       color: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
//       child: Obx(
//         () => ExpansionTile(
//           tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
//           childrenPadding: const EdgeInsets.only(bottom: 12),
//           iconColor: Colors.green[700],
//           collapsedIconColor: Colors.green[700],
//           title: Text(
//             deviceController.selectedDevice.value ?? "الجهاز",
//             style: TextStyle(
//               fontSize: 16,
//               color:
//                   deviceController.selectedDevice.value != null
//                       ? Colors.black
//                       : Colors.grey[600],
//             ),
//             textDirection: TextDirection.rtl,
//           ),
//           trailing: const Icon(Icons.expand_more),
//           children: [
//             // Device list or empty state
//             _buildDeviceList(deviceController),

//             // Add device tile
//             _buildAddDeviceTile(context),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDeviceList(DeviceController deviceController) {
//     if (deviceController.devices.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Text(
//           "لم يتم إضافة أي جهاز بعد",
//           textDirection: TextDirection.rtl,
//           style: TextStyle(color: Colors.grey[600]),
//         ),
//       );
//     }

//     return Column(
//       children:
//           deviceController.devices
//               .map((device) => _buildDeviceItem(device, deviceController))
//               .toList(),
//     );
//   }

//   Widget _buildDeviceItem(
//     Map<String, String> device,
//     DeviceController deviceController,
//   ) {
//     final deviceName = device['name'] ?? 'Unnamed Device';

//     return Column(
//       children: [
//         Divider(
//           indent: 30,
//           endIndent: 30,
//           thickness: 1,
//           color: Colors.green[100],
//         ),
//         ListTile(
//           title: Text(
//             deviceName,
//             textDirection: TextDirection.rtl,
//             style: TextStyle(
//               color:
//                   deviceController.selectedDevice.value == deviceName
//                       ? mainColor
//                       : Colors.black,
//             ),
//           ),
//           trailing:
//               deviceController.selectedDevice.value == deviceName
//                   ? Icon(Icons.check_circle, color: mainColor)
//                   : null,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           onTap: () {
//             deviceController.selectDevice(deviceName);
//             onDeviceSelected?.call(deviceName);
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildAddDeviceTile(BuildContext context) {
//     return ListTile(
//       leading: Icon(Icons.add, color: Colors.green[700]),
//       title: const Text(
//         "إضافة جهاز جديد",
//         style: TextStyle(fontWeight: FontWeight.w500),
//       ),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => AddDevicePage()),
//         );
//       },
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       tileColor: Colors.green[50],
//       splashColor: Colors.green[100],
//     );
//   }
// }
