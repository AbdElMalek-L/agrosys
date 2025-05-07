import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrosys/domain/models/activity.dart';
import 'package:agrosys/presentation/cubits/recent_activity_cubit.dart';
import 'package:intl/intl.dart';

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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return 'اليوم ${DateFormat('HH:mm').format(timestamp)}';
    } else if (messageDate == yesterday) {
      return 'أمس ${DateFormat('HH:mm').format(timestamp)}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
    }
  }

  Widget _buildActivityTile(Activity activity, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOn = activity.type == 'ON';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isOn 
            ? (isDark ? Colors.green.withOpacity(0.1) : Colors.green.withOpacity(0.05))
            : (isDark ? Colors.red.withOpacity(0.1) : Colors.red.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOn 
              ? (isDark ? Colors.green.withOpacity(0.3) : Colors.green.withOpacity(0.2))
              : (isDark ? Colors.red.withOpacity(0.3) : Colors.red.withOpacity(0.2)),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isOn 
                ? (isDark ? Colors.green.withOpacity(0.2) : Colors.green.withOpacity(0.1))
                : (isDark ? Colors.red.withOpacity(0.2) : Colors.red.withOpacity(0.1)),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isOn ? Icons.power : Icons.power_off,
            color: isOn 
                ? (isDark ? Colors.green[300] : Colors.green[700])
                : (isDark ? Colors.red[300] : Colors.red[700]),
          ),
        ),
        title: Text(
          isOn ? 'تم تشغيل الجهاز' : 'تم إيقاف الجهاز',
          style: theme.textTheme.titleMedium?.copyWith(
            color: isOn 
                ? (isDark ? Colors.green[300] : Colors.green[700])
                : (isDark ? Colors.red[300] : Colors.red[700]),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(activity.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            if (activity.duration != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'مدة التشغيل: ${activity.duration}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "النشاط الأخير",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
            ),
              BlocBuilder<RecentActivityCubit, List<Activity>>(
              builder: (context, activities) {
                  if (activities.isEmpty) return const SizedBox.shrink();
                  return TextButton.icon(
                    onPressed: () {
                      context.read<RecentActivityCubit>().clearActivities();
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('مسح'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<RecentActivityCubit, List<Activity>>(
            builder: (context, activities) {
              if (activities.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا يوجد نشاط حتى الآن',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                              ),
                  ),
                );
              }
              return Column(
                children: activities.map((activity) => _buildActivityTile(activity, context)).toList(),
                );
              },
            ),
          ],
      ),
    );
  }
}
