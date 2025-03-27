/*

  DEVICE VIEW: Responsible for the UI

  - use BlocBuilder

*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/presentation/pages/cubits/device_cubit.dart';

class DeviceView extends StatefulWidget {
  const DeviceView({super.key});

  @override
  _DeviceViewState createState() => _DeviceViewState();
}

class _DeviceViewState extends State<DeviceView> {
  String? selectedDevice;
  bool isExpanded = false;

  void _showInsertionForm(BuildContext context) {
    final deviceCubit = context.read<DeviceCubit>();
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: TextField(controller: textController),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  deviceCubit.addDevice(
                    "none",
                    textController.text,
                    "phoneNumber",
                    "passWord",
                  );
                  Navigator.of(context).pop();
                },
                child: const Text("Add"),
              ),
            ],
          ),
    );
  }

  void _controlDevice(Device device) {
    final deviceCubit = context.read<DeviceCubit>();
    deviceCubit.togglePower(device);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInsertionForm(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<DeviceCubit, List<Device>>(
        builder: (context, devices) {
          return Stack(
            children: [
              Positioned.fill(
                child: ListView(
                  padding: const EdgeInsets.all(10),
                  children: [
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ExpansionTile(
                          initiallyExpanded: isExpanded,
                          onExpansionChanged:
                              (expanded) =>
                                  setState(() => isExpanded = expanded),
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                          childrenPadding: const EdgeInsets.only(bottom: 12),
                          iconColor: Colors.green[700],
                          collapsedIconColor: Colors.green[700],
                          title: Center(
                            child: Text(
                              selectedDevice ?? "Devices",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          trailing: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                          ),
                          children: [
                            Column(
                              children:
                                  devices.map((device) {
                                    return ListTile(
                                      title: Text(
                                        device.name,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          selectedDevice = device.name;
                                          isExpanded = false;
                                        });
                                      },
                                      tileColor:
                                          selectedDevice == device.name
                                              ? Colors.green[100]
                                              : Colors.transparent,
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed:
                        selectedDevice != null
                            ? () {
                              if (devices.any(
                                (d) => d.name == selectedDevice,
                              )) {
                                final selectedDeviceObj = devices.firstWhere(
                                  (d) => d.name == selectedDevice,
                                );
                                _controlDevice(selectedDeviceObj);
                              }
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      elevation: 8,
                    ),
                    child: Text(
                      selectedDevice == null
                          ? "Select a Device"
                          : "Control ${selectedDevice!}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
