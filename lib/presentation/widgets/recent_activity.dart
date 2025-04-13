import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/recent_activity_cubit.dart'; // Import the Cubit

/// A widget that displays a list of recent activities.
///
/// Uses a [BlocBuilder] to listen to changes in a [RecentActivityCubit]
/// and display the activities accordingly.
class RecentActivityWidget extends StatelessWidget {
  /// Predefined icon constants for different activity types.
  static const Map<String, IconData> activityIcons = {
    'alert': Icons.warning,
    'success': Icons.check_circle,
    'info': Icons.info,
    'error': Icons.error,
    'device': Icons.device_thermostat,
    'sensor': Icons.sensors,
  };

  /// Predefined color constants for different activity types.
  static const Map<String, Color> activityColors = {
    'alert': Colors.orange,
    'success': Colors.green,
    'info': Colors.blue,
    'error': Colors.red,
    'default': Colors.grey,
  };

  /// Creates a RecentActivityWidget.
  const RecentActivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Provide the Cubit
      create: (context) => RecentActivityCubit()..loadActivities(),
      child: Container(
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
            // Use BlocBuilder to listen to the Cubit's state
            BlocBuilder<RecentActivityCubit, List<Map<String, String>>>(
              builder: (context, activities) {
                if (activities.isEmpty) {
                  return const Text(
                    "لا يوجد نشاط حتى الآن",
                    style: TextStyle(color: Colors.grey),
                  );
                }
                return Column(
                  children:
                      activities
                          .map(
                            (activity) => ListTile(
                              leading: Icon(
                                activityIcons[activity['iconType']] ??
                                    Icons.help_outline,
                                color:
                                    activityColors[activity['colorType']] ??
                                    activityColors['default']!,
                              ),
                              title: Text(activity['title']!),
                              subtitle: Text(activity['subtitle']!),
                            ),
                          )
                          .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
