import 'package:flutter/material.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:intl/intl.dart';

class ScheduleCard extends StatelessWidget {
  final Device device;

  const ScheduleCard({Key? key, required this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('الجدول', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (device.isScheduleEnabled)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'وقت البدء: ${device.scheduleStartTime != null ? DateFormat('hh:mm', 'en').format(DateTime(2023, 1, 1, device.scheduleStartTime!.hour, device.scheduleStartTime!.minute)) + (device.scheduleStartTime!.hour < 12 ? ' صباحاً' : ' مساءً') : 'غير محدد'}',
                  ),
                  Text(
                    'وقت الانتهاء: ${device.scheduleEndTime != null ? DateFormat('hh:mm', 'en').format(DateTime(2023, 1, 1, device.scheduleEndTime!.hour, device.scheduleEndTime!.minute)) + (device.scheduleEndTime!.hour < 12 ? ' صباحاً' : ' مساءً') : 'غير محدد'}',
                  ),
                ],
              )
            else
              const Text('لم يتم تعيين جدول.'),
          ],
        ),
      ),
    );
  }
}
