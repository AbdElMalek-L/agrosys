import 'package:flutter/material.dart';
import '../../controllers/recent_activity_storage.dart';

class RecentActivityWidget extends StatefulWidget {
  const RecentActivityWidget({super.key});

  @override
  _RecentActivityWidgetState createState() => _RecentActivityWidgetState();
}

class _RecentActivityWidgetState extends State<RecentActivityWidget> {
  List<Map<String, String>> activities = [];

  // Predefined icon constants
  static const Map<String, IconData> activityIcons = {
    'alert': Icons.warning,
    'success': Icons.check_circle,
    'info': Icons.info,
    'error': Icons.error,
    'device': Icons.device_thermostat,
    'sensor': Icons.sensors,
  };

  // Predefined color constants
  static const Map<String, Color> activityColors = {
    'alert': Colors.orange,
    'success': Colors.green,
    'info': Colors.blue,
    'error': Colors.red,
    'default': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final loadedActivities = await RecentActivityStorage.loadActivities();
    setState(() {
      activities = loadedActivities;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "النشاط الأخير",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (activities.isEmpty)
            const Text(
              "لا يوجد نشاط حتى الآن",
              style: TextStyle(color: Colors.grey),
            ),
          ...activities.map(
            (activity) => ListTile(
              leading: Icon(
                activityIcons[activity['iconType']] ?? Icons.help_outline,
                color:
                    activityColors[activity['colorType']] ??
                    activityColors['default']!,
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
