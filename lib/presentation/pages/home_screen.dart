import 'dart:async';

import 'package:agrosys/domain/models/app_state.dart';
import 'package:agrosys/presentation/cubits/app_state_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/presentation/cubits/device_cubit.dart';
import 'package:agrosys/domain/models/activity.dart';
import 'package:agrosys/presentation/cubits/recent_activity_cubit.dart';
import '../widgets/app_drawer.dart';
import '../widgets/device_selector_tile.dart';
import '../widgets/header.dart';
import '../widgets/power_control_button.dart';
import '../widgets/recent_activity.dart';
import '../widgets/schedule_card.dart';
import '../widgets/signal_strength_indicator.dart';
import '../../controllers/sms_controller.dart';
import 'device_sms_history_page.dart';

import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'settings_page.dart';
import 'chatbot_page.dart';

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
  int _currentSignalStrength = 0;

  Future<void> _refreshSignalStrength() async {
    final devices = context.read<DeviceCubit>().state;
    final selectedIndex =
        context.read<AppStateCubit>().state.selectedDeviceIndex;
    if (devices.isNotEmpty && selectedIndex < devices.length) {
      final device = devices[selectedIndex];
      sendSMS(device.phoneNumber, "${device.passWord}#CSQ#");
    }
  }

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

  void _updateSignalStrength(String message) {
    // Try to find any number between 0-31 in the message
    final signalMatch = RegExp(
      r'\b([0-9]|[12][0-9]|3[01])\b',
    ).firstMatch(message);
    if (signalMatch != null) {
      final signalStr = signalMatch.group(1);
      if (signalStr != null) {
        final signal = int.tryParse(signalStr);
        if (signal != null && signal >= 0 && signal <= 31) {
          print('Updating signal strength to: $signal'); // Debug log
          setState(() {
            _currentSignalStrength = signal;
          });

          // Update device signal in cubit
          final devices = context.read<DeviceCubit>().state;
          final selectedIndex =
              context.read<AppStateCubit>().state.selectedDeviceIndex;
          if (devices.isNotEmpty && selectedIndex < devices.length) {
            context.read<DeviceCubit>().updateSignal(
              devices[selectedIndex],
              signal,
            );
          }
        }
      }
    }
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

        if (newMessage != null) {
          print('Received new message: $newMessage'); // Debug log
          _updateSignalStrength(newMessage);

          // Check for exact relay status response format
          if (newMessage.startsWith("Relay ON!") ||
              newMessage.startsWith("Relay OFF!")) {
            final isOn = newMessage.startsWith("Relay ON!");
            // Verify that the message contains the device number
            if (newMessage.contains(selectedDeviceNumber)) {
              print(
                'Updating power state to: ${isOn ? "ON" : "OFF"}',
              ); // Debug log
              context.read<DeviceCubit>().updatePowerState(selectedIndex, isOn);

              // Only update waiting state if we were waiting for confirmation
              if (_isWaitingForConfirmation) {
                setState(() {
                  _isWaitingForConfirmation = false;
                });
              }

              // Add activity to recent activities
              final activity = Activity.fromSms(
                newMessage,
                latest.date ?? DateTime.now(),
              );
              context.read<RecentActivityCubit>().addActivity(activity);
            }
          }
        }

        // Only show notification if it's not a signal strength message or relay status
        if (_initialCheckDone && mounted) {
          // Check if the message contains only a number between 0-31
          final isSignalMessage = RegExp(
            r'^\s*([0-9]|[12][0-9]|3[01])\s*$',
          ).hasMatch(newMessage ?? '');

          if (!isSignalMessage) {
            showDialog(
              context: context,
              builder:
                  (_) => AlertDialog(
                    title: const Text("\u{1F4E9} رسالة من الجهاز"),
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
        }
        _initialCheckDone = true;
      }
    }
  }

  void sendSMS(String phoneNumber, String command) {
    setState(() {
      _isWaitingForConfirmation = true;
    });

    // Create a timer for 45 second timeout
    Timer? timeoutTimer = Timer(const Duration(seconds: 45), () {
      if (mounted) {
        setState(() {
          _isWaitingForConfirmation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('انتهت مهلة انتظار التأكيد'),
            backgroundColor: Colors.orange,
          ),
        );
      }
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
        // Cancel the timeout timer since we got a response
        timeoutTimer.cancel();

        if (!success) {
          if (mounted) {
            setState(() {
              _isWaitingForConfirmation = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('فشل إرسال الأمر'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        // Note: We don't set _isWaitingForConfirmation to false here
        // as we want to wait for the confirmation SMS
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () {
                            final devices = context.read<DeviceCubit>().state;
                            final selectedIndex =
                                context
                                    .read<AppStateCubit>()
                                    .state
                                    .selectedDeviceIndex;
                            if (devices.isNotEmpty &&
                                selectedIndex < devices.length) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SettingsPage(
                                        device: devices[selectedIndex],
                                      ),
                                ),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChatbotPage(),
                              ),
                            );
                          },
                        ),
                        GestureDetector(
                          onVerticalDragEnd: (details) {
                            if (details.primaryVelocity! > 0) {
                              // Swipe down
                              _refreshSignalStrength();
                            }
                          },
                          child: SignalStrengthIndicator(
                            signalStrength: _currentSignalStrength,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Header(title: "لوحة التحكم"),
                        const SizedBox(
                          width: 48,
                        ), // Add padding to balance the settings icon
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          // Request signal strength from device
                          final devices = context.read<DeviceCubit>().state;
                          final selectedIndex =
                              context
                                  .read<AppStateCubit>()
                                  .state
                                  .selectedDeviceIndex;
                          if (devices.isNotEmpty &&
                              selectedIndex < devices.length) {
                            final device = devices[selectedIndex];
                            sendSMS(
                              device.phoneNumber,
                              "${device.passWord}#CSQ#",
                            );
                          }
                        },
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
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => DeviceSmsHistoryPage(
                                            device:
                                                devices[appState
                                                    .selectedDeviceIndex],
                                          ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.history),
                                label: const Text('سجل الرسائل'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                ),
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
