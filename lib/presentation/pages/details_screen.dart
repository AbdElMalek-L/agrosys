import 'package:flutter/material.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  TimeOfDay? selectedTime;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعداد التوقيت')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: const Text('إختيار الوقت'),
            ),
            const SizedBox(height: 20),
            if (selectedTime != null)
              Text('الوقت المختار : ${selectedTime!.format(context)}'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // TODO: Send command to RTU5024 based on time logic
                Navigator.pop(context);
              },
              child: const Text('حفظ الإعدادات'),
            ),
          ],
        ),
      ),
    );
  }
}
