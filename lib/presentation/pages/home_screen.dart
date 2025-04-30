import 'dart:async';

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
  Timer? _smsRefreshTimer;
  bool _initialCheckDone = false;
  bool _isWaitingForConfirmation = false;

  @override
  void initState() {
    super.initState();
    _fetchLastSms();
    _smsRefreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchLastSms(),
    );
  }

  @override
  void dispose() {
    _smsRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLastSms() async {
    var permission = await Permission.sms.status;
    if (!permission.isGranted) {
      permission = await Permission.sms.request();
    }

    if (!permission.isGranted) return;

    final messages = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
      count: 1,
    );
    if (messages.isEmpty) return;

    final latest = messages.first;
    final newMessage = latest.body;
    final sender = latest.address ?? '';

    final devices = context.read<DeviceCubit>().state;
    final selectedIndex =
        context.read<AppStateCubit>().state.selectedDeviceIndex;
    if (devices.isEmpty || selectedIndex >= devices.length) return;

    final selectedDevice = devices[selectedIndex];
    final selectedDeviceNumber = selectedDevice.phoneNumber
        .replaceAll('+', '')
        .replaceAll(' ', '');
    final senderClean = sender.replaceAll('+', '').replaceAll(' ', '');

    if (senderClean.contains(selectedDeviceNumber)) {
      if (_lastSms != newMessage) {
        setState(() {
          _lastSms = newMessage;
        });

        if (_isWaitingForConfirmation) {
          if (newMessage!.toUpperCase().contains("ON")) {
            context.read<DeviceCubit>().updatePowerState(selectedIndex, true);
            ;
          } else if (newMessage.toUpperCase().contains("OFF")) {
            context.read<DeviceCubit>().updatePowerState(selectedIndex, false);
            ;
          }
          _isWaitingForConfirmation = false;
        }

        if (_initialCheckDone && mounted) {
          showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  title: const Text("\u{1F4E9} رسالة جديدة من الجهاز"),
                  content: Text(newMessage ?? ''),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("إغلاق"),
                    ),
                  ],
                ),
          );
        }
        _initialCheckDone = true;
      }
    }
  }

  void sendSMS(String phoneNumber, String command) {
    setState(() {
      _isWaitingForConfirmation = true;
    });

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
        if (!success) {
          setState(() {
            _isWaitingForConfirmation = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('فشل إرسال الأمر'),
              backgroundColor: Colors.red,
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
                              isWaiting: _isWaitingForConfirmation,
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
