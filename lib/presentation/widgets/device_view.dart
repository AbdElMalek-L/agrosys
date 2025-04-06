/*

  DEVICE VIEW: Responsible for the UI

  - use BlocBuilder

*/
import 'package:agrosys/domain/models/app_state.dart';
import 'package:agrosys/presentation/cubits/app_state_cubit.dart';
import 'package:agrosys/presentation/pages/devices_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/presentation/cubits/device_cubit.dart';
import 'header.dart';
import 'recent_activity.dart';

// TODO: Extract all the widgets in here.

class DeviceView extends StatefulWidget {
  const DeviceView({super.key});

  @override
  _DeviceViewState createState() => _DeviceViewState();
}

class _DeviceViewState extends State<DeviceView> {
  final bool _isExpanded = false;
  final int _expansionKey = 0;

  final String controlAssetPowerOn = "assets/power_animation.json";
  final String controlAssetPowerOff = "assets/power_off.json";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AppStateCubit, AppState>(
        builder: (context, appState) {
          return BlocBuilder<DeviceCubit, List<Device>>(
            builder: (context, devices) {
              return SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    const Center(child: Header(title: "لوحة التحكم")),
                    Text(appState.selectedDeviceIndex.toString()),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(10),
                        children: [
                          Hero(
                            tag: "change_selected_device",

                            child: Card(
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 8,
                              ),
                              child: Theme(
                                data: Theme.of(
                                  context,
                                ).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  key: ValueKey(_expansionKey),
                                  onExpansionChanged:
                                      (expanded) => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => DevicesListPage(),
                                        ),
                                      ),
                                  tilePadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 0,
                                  ),
                                  childrenPadding: const EdgeInsets.only(
                                    bottom: 12,
                                  ),
                                  iconColor: Colors.green[700],
                                  collapsedIconColor: Colors.green[700],
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        devices[appState.selectedDeviceIndex]
                                            .model,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromARGB(
                                            255,
                                            66,
                                            66,
                                            66,
                                          ),
                                        ),
                                      ),

                                      Text(
                                        devices[appState.selectedDeviceIndex]
                                            .name,
                                        textDirection: TextDirection.rtl,

                                        style: TextStyle(
                                          color: const Color.fromARGB(
                                            255,
                                            129,
                                            129,
                                            129,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: AnimatedRotation(
                                    turns: _isExpanded ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 300),
                                    child: const Icon(Icons.expand_more),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // const SignalIndicator(),
                          const SizedBox(height: 20),

                          const SizedBox(height: 20),
                          if (devices.isNotEmpty) ...[
                            BlocBuilder<DeviceCubit, List<Device>>(
                              builder: (context, devices) {
                                // Get the updated device from the list

                                return Column(
                                  children: [
                                    Center(
                                      child: GestureDetector(
                                        onTap:
                                            () => context
                                                .read<DeviceCubit>()
                                                .togglePower(
                                                  devices[appState
                                                      .selectedDeviceIndex],
                                                ),
                                        child: Lottie.asset(
                                          devices[appState.selectedDeviceIndex]
                                                  .isPoweredOn
                                              ? controlAssetPowerOff
                                              : controlAssetPowerOn,
                                          height: 150,
                                          width: 150,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        devices[appState.selectedDeviceIndex]
                                                .isPoweredOn
                                            ? "إيقاف التشغيل"
                                            : "تشغيل",
                                        textDirection: TextDirection.rtl,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
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
