import 'package:agrosys/controllers/sent_sms.dart';
import 'package:agrosys/domain/models/app_state.dart';
import 'package:agrosys/presentation/cubits/app_state_cubit.dart';
import 'package:agrosys/presentation/pages/schedule_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/presentation/cubits/device_cubit.dart';
import '../widgets/app_drawer.dart';
import '../widgets/device_selector_tile.dart';
import '../widgets/header.dart';
import '../widgets/power_control_button.dart';
import '../widgets/recent_activity.dart';
import '../widgets/schedule_card.dart'; // Import the new widget
import '../../controllers/sms_controller.dart';
// If you have a DeviceCard widget, uncomment this:
// import '../widgets/device_card.dart';

/// Displays the main control view for the selected device.
///
/// This widget acts as the primary screen for interacting with a device.
/// It uses [BlocBuilder] to listen to changes in both [AppStateCubit] (for the
/// currently selected device index) and [DeviceCubit] (for the list of devices
/// and their states).
///
/// It includes:
/// - A [Header] widget.
/// - A [DeviceSelectorTile] to show and allow changing the selected device.
/// - A [PowerControlButton] to toggle the device's power state via SMS.
/// - A [RecentActivityWidget] (presumably to show recent actions).
class HomeScreen extends StatefulWidget {
  /// Creates a HomeScreen.
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final bool _isExpanded = false; // Removed unused variable
  final int _expansionKey = 0; // Keep key for potential state preservation
  // final SMSController _smsController = SMSController();

  // Removed unused asset paths, they are now inside PowerControlButton
  // final String controlAssetPowerOn = "assets/power_animation.json";
  // final String controlAssetPowerOff = "assets/power_off.json";

  @override
  Widget build(BuildContext context) {
    // Removed planifierSms call
    return Scaffold(
      drawer: const AppDrawer(),
      body: BlocBuilder<AppStateCubit, AppState>(
        builder: (context, appState) {
          // Listens to AppStateCubit for changes in the selected device index.
          return BlocBuilder<DeviceCubit, List<Device>>(
            builder: (context, devices) {
              // Listens to DeviceCubit for changes in the device list (e.g., power state).
              return SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    const Center(child: Header(title: "لوحة التحكم")),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(10),
                        children: [
                          // Use the extracted DeviceSelectorTile widget
                          DeviceSelectorTile(
                            devices: devices,
                            appState: appState,
                            expansionKey: _expansionKey,
                          ),
                          // const SignalIndicator(), // Assuming this is commented out intentionally
                          const SizedBox(height: 20),

                          const SizedBox(height: 20),
                          if (devices.isNotEmpty) ...[
                            PowerControlButton(
                              // Pass the currently selected device
                              device: devices[appState.selectedDeviceIndex],
                              appState: appState,
                              // Pass the sendSMS method as the callback
                              onTogglePower: sendSMS,
                            ),
                            const SizedBox(height: 20),
                            // Schedule Card (now clickable)
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

  final SMSController _smsController =
      SMSController(); // Need to import SMSController class

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

  // Removed planifierSms method
}
