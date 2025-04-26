import 'package:agrosys/domain/models/app_state.dart';
import 'package:agrosys/presentation/cubits/app_state_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/presentation/cubits/device_cubit.dart';
import '../widgets/app_drawer.dart';
import '../widgets/device_selector_tile.dart';
import '../widgets/header.dart';
import '../widgets/power_control_button.dart';
import '../widgets/recent_activity.dart';
import '../widgets/schedule_card.dart';
import '../../controllers/sms_controller.dart';

import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _expansionKey = 0;
  final SMSController _smsController = SMSController();
  final SmsQuery _query = SmsQuery();
  String? _lastSms;

  @override
  void initState() {
    super.initState();
    _fetchLastSms();
  }

  Future<void> _fetchLastSms() async {
    var permission = await Permission.sms.status;
    if (!permission.isGranted) {
      permission = await Permission.sms.request();
    }

    if (permission.isGranted) {
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 1,
      );

      if (messages.isNotEmpty) {
        setState(() {
          _lastSms = messages.first.body;
        });

        print("📩 Dernier SMS: $_lastSms");
      }
    } else {
      print("❌ Permission SMS refusée");
    }
  }

  void sendSMS(String phoneNumber, String command) {
    _smsController.sendCommandWithResponse(
      context: context,
      phoneNumber: phoneNumber,
      command: command,
      onMessage: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      onResult: (success, response) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم إرسال الأمر بنجاح'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('فشل إرسال الأمر'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: BlocBuilder<AppStateCubit, AppState>(
        builder: (context, appState) {
          return BlocBuilder<DeviceCubit, List<Device>>(
            builder: (context, devices) {
              return SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Center(child: Header(title: "لوحة التحكم")),
                    const SizedBox(height: 20),
                    if (_lastSms != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          "📥 Dernier SMS reçu :\n$_lastSms",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(10),
                        children: [
                          DeviceSelectorTile(
                            devices: devices,
                            appState: appState,
                            expansionKey: _expansionKey,
                          ),
                          const SizedBox(height: 20),
                          if (devices.isNotEmpty) ...[
                            PowerControlButton(
                              device: devices[appState.selectedDeviceIndex],
                              appState: appState,
                              onTogglePower: sendSMS,
                            ),
                            const SizedBox(height: 20),
                            BlocBuilder<AppStateCubit, AppState>(
                              builder: (context, appState) {
                                return BlocBuilder<DeviceCubit, List<Device>>(
                                  builder: (context, devices) {
                                    if (devices.isNotEmpty) {
                                      return ScheduleCard(
                                        device:
                                            devices[appState
                                                .selectedDeviceIndex],
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                          const SizedBox(height: 30),
                          const RecentActivityWidget(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
