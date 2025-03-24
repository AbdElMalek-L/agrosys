import 'package:flutter/material.dart';
import '../themes/colors.dart';
import '../pages/add_device_page.dart';
import '../modules/device_storage.dart';

initSampleData() async {
  final devices = await DeviceStorage.loadDevices();
  if (devices.isEmpty) {
    await DeviceStorage.saveDevices([]);
  }
}

class DevicesCard extends StatefulWidget {
  final List<Map<String, String>> devices;
  final ValueChanged<String>? ondeviceselected;

  const DevicesCard({super.key, required this.devices, this.ondeviceselected});

  @override
  _DevicesCardState createState() => _DevicesCardState();
}

class _DevicesCardState extends State<DevicesCard> {
  String? _selecteddevice;
  bool _isExpanded = false;
  int _expansionKey = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: ValueKey(_expansionKey),
          onExpansionChanged:
              (expanded) => setState(() => _isExpanded = expanded),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          childrenPadding: const EdgeInsets.only(bottom: 12),
          iconColor: Colors.green[700],
          collapsedIconColor: Colors.green[700],
          title: Text(
            _selecteddevice ?? "الجهاز",
            style: TextStyle(
              fontSize: 16,
              color: _selecteddevice != null ? Colors.black : Colors.grey[600],
            ),
            textDirection: TextDirection.rtl,
          ),
          trailing: AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            child: const Icon(Icons.expand_more),
          ),
          children: [
            ...widget.devices.map((device) => _buildDeviceItem(device)),
            ListTile(
              leading: Icon(Icons.add, color: Colors.green[700]),
              title: const Text(
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
              tileColor: Colors.green[50],
              splashColor: Colors.green[100],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceItem(Map<String, String> device) {
    final deviceName = device['name'] ?? 'Unnamed Device';
    return Column(
      children: [
        Divider(
          indent: 30,
          endIndent: 30,
          thickness: 1,
          color: Colors.green[100],
        ),
        ListTile(
          title: Text(
            deviceName,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: _selecteddevice == deviceName ? mainColor : Colors.black,
            ),
          ),
          trailing:
              _selecteddevice == deviceName
                  ? Icon(Icons.check_circle, color: mainColor)
                  : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: () {
            setState(() {
              _selecteddevice = deviceName;
              _expansionKey++;
            });
            widget.ondeviceselected?.call(deviceName);
          },
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import '../pages/add_device_page.dart';
// import '../modules/device_storage.dart';

// class DevicesCard extends StatefulWidget {
//   const DevicesCard({super.key});

//   @override
//   _DevicesCardState createState() => _DevicesCardState();
// }

// class _DevicesCardState extends State<DevicesCard> {
//   bool _isExpanded = false;
//   List<Map<String, String>> devices = [];

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 0, // Adds a soft shadow effect
//       color: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       margin: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
//       child: Theme(
//         data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//         child: ExpansionTile(
//           onExpansionChanged: (expanded) {
//             setState(() {
//               _isExpanded = expanded;
//             });
//           },
//           tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           childrenPadding: EdgeInsets.only(bottom: 12),
//           iconColor: Colors.green[700],
//           collapsedIconColor: Colors.green[700],
//           trailing: AnimatedRotation(
//             turns: _isExpanded ? 0.5 : 0, // Smooth icon rotation
//             duration: Duration(milliseconds: 300),
//             child: Icon(Icons.expand_more),
//           ),
//           title: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Text(
//               //   "RTU5024",
//               //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               // ),
//               // SizedBox(height: 4),
//               // Text(
//               //   "بركان، سيدي سليم الشرا",
//               //   style: TextStyle(color: Colors.grey[600], fontSize: 14),
//               // ),
//             ],
//           ),
//           children: [
//             Divider(indent: 16, endIndent: 16, thickness: 1),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "RTU5024",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   "بركان، سيدي سليمان الشراعة",
//                   style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                 ),
//               ],
//             ), // Stylish separator
//             ListTile(
//               leading: Icon(Icons.add, color: Colors.green[700]),
//               title: Text(
//                 "إضافة جهاز جديد",
//                 style: TextStyle(fontWeight: FontWeight.w500),
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => AddDevicePage()),
//                 );
//               },
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               tileColor: Colors.green[50], // Subtle background color
//               splashColor: Colors.green[100], // Interactive ripple effect
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
