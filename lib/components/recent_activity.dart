import 'package:flutter/material.dart';
import '../modules/recent_activity_storage.dart';

class RecentActivityWidget extends StatefulWidget {
  const RecentActivityWidget({super.key});

  @override
  _RecentActivityWidgetState createState() => _RecentActivityWidgetState();
}

class _RecentActivityWidgetState extends State<RecentActivityWidget> {
  List<Map<String, String>> activities = [];

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
