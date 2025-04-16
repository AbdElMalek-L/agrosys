import 'package:agrosys/presentation/cubits/device_cubit.dart';
import 'package:flutter/material.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/presentation/widgets/header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SchedulePage extends StatefulWidget {
  final Device device;

  const SchedulePage({super.key, required this.device});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late TimeOfDay? _startTime;
  late TimeOfDay? _endTime;
  late bool _isScheduleEnabled;

  @override
  void initState() {
    super.initState();
    _startTime = widget.device.scheduleStartTime;
    _endTime = widget.device.scheduleEndTime;
    _isScheduleEnabled = widget.device.isScheduleEnabled;
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Header(title: 'جدول الطاقة - ${widget.device.name}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text(
                  'تفعيل الجدول',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                value: _isScheduleEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _isScheduleEnabled = value;
                  });
                },
                activeColor: colorScheme.primary,
              ),
              const SizedBox(height: 24),
              if (_isScheduleEnabled) ...[
                ListTile(
                  title: const Text('وقت البدء'),
                  trailing: TextButton(
                    onPressed: () => _selectTime(context, true),
                    child: Text(
                      _startTime?.format(context) ?? 'اختر الوقت',
                      style: TextStyle(color: colorScheme.primary),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('وقت الانتهاء'),
                  trailing: TextButton(
                    onPressed: () => _selectTime(context, false),
                    child: Text(
                      _endTime?.format(context) ?? 'اختر الوقت',
                      style: TextStyle(color: colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed:
                        _startTime != null && _endTime != null
                            ? () {
                              final deviceCubit = context.read<DeviceCubit>();
                              final updatedDevice = widget.device.copyWith(
                                isScheduleEnabled: _isScheduleEnabled,
                                scheduleStartTime: _startTime,
                                scheduleEndTime: _endTime,
                              );
                              deviceCubit.updateDevice(
                                widget.device,
                                updatedDevice,
                              );
                              Navigator.pop(context);
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('حفظ الجدول'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
