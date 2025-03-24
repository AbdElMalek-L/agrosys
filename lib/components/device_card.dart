import 'package:flutter/material.dart';
import '../pages/add_device_page.dart';
import '../modules/device_storage.dart';

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
