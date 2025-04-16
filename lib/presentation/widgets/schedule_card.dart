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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Schedule', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (device.isScheduleEnabled)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start Time: ${device.scheduleStartTime != null ? DateFormat('hh:mm a').format(DateTime(2023, 1, 1, device.scheduleStartTime!.hour, device.scheduleStartTime!.minute)) : 'Not set'}',
                  ),
                  Text(
                    'End Time: ${device.scheduleEndTime != null ? DateFormat('hh:mm a').format(DateTime(2023, 1, 1, device.scheduleEndTime!.hour, device.scheduleEndTime!.minute)) : 'Not set'}',
                  ),
                ],
              )
            else
              const Text('No schedule set.'),
          ],
        ),
      ),
    );
  }
}
