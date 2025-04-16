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
                            // Schedule button
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => SchedulePage(
                                          device:
                                              devices[appState
                                                  .selectedDeviceIndex],
                                        ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.schedule),
                              label: const Text('جدول الطاقة'),
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
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void sendSMS(String phoneNumber, String command) {
    // _smsController.sendCommandWithResponse(
    //   context: context,
    //   phoneNumber: phoneNumber,
    //   command: command,
    //   onMessage: (message) {
    //     // Log the message instead of showing a snackbar
    //     developer.log(message, name: 'SMSController');
    //   },
    //   onResult: (success, response) {
    //     if (success) {
    //       // SMS sent and response received successfully
    //       developer.log(
    //         "SMS command successful: $response",
    //         name: 'DeviceView',
    //       );

    //       // You can access the SMS history if needed
    //       final sentMessages = _smsController.getSentSMSForPhoneNumber(
    //         phoneNumber,
    //       );
    //       if (sentMessages.isNotEmpty) {
    //         final lastMessage = sentMessages.last;
    //         developer.log(
    //           "Last SMS to $phoneNumber: ${lastMessage.message}, Response: ${lastMessage.response}",
    //           name: 'DeviceView',
    //         );
    //       }
    //     } else {
    //       // SMS failed to send or no response received
    //       developer.log("SMS command failed", name: 'DeviceView');
    //     }
    //   },
    // );
  }
}
