import 'package:agrosys/domain/models/app_state.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/presentation/cubits/app_state_cubit.dart';
import 'package:agrosys/presentation/cubits/device_cubit.dart';
import 'package:agrosys/presentation/pages/add_device_page.dart';
import 'package:agrosys/presentation/pages/settings_page.dart';
import 'package:agrosys/presentation/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

// TODO: implement a full page scrolable lsitview with slidable devices
// TODO: Add floating action button for adding new device _/ _/

class DevicesListPage extends StatelessWidget {
  const DevicesListPage({super.key});

  Widget _buildDeviceItem(
    BuildContext context,
    Device device,
    int index,
    AppState appState,
  ) {
    final deviceCubit = context.read<DeviceCubit>();
    return Column(
      spacing: 0,
      children: [
        Slidable(
          key: Key(device.id.toString()),
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => deviceCubit.deleteDevice(device),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'حذف',
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed:
                    (_) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsPage(device: device),
                      ),
                    ),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.settings,
                label: 'إعدادات',
              ),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.model,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            appState.selectedDeviceIndex == index
                                ? Theme.of(context).colorScheme.primary
                                : const Color.fromARGB(255, 66, 66, 66),
                      ),
                    ),

                    Text(
                      device.name,
                      textDirection: TextDirection.rtl,

                      style: TextStyle(
                        color:
                            appState.selectedDeviceIndex == index
                                ? Theme.of(context).colorScheme.primary
                                : const Color.fromARGB(255, 129, 129, 129),
                      ),
                    ),
                  ],
                ),
                trailing:
                    appState.selectedDeviceIndex == index
                        ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                        : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  context.read<AppStateCubit>().setSelectedDevice(index);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        Divider(
          indent: 30,
          endIndent: 30,
          thickness: 1,
          color: Colors.green[100],
        ),
      ],
    );
  }

  //   Padding(
  //   padding: const EdgeInsets.all(8.0),
  //   child: ListTile(
  //     leading: Icon(Icons.add, color: Colors.green[700]),
  //     title: const Text(
  //       "إضافة جهاز جديد",
  //       style: TextStyle(fontWeight: FontWeight.w500),
  //       textDirection: TextDirection.rtl,
  //     ),
  //     onTap:

  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     tileColor: Colors.green[50],
  //     splashColor: Colors.green[100],
  //   ),
  // ),

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Colors.white),

        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddDevicePage()),
            ),
      ),
      body: BlocBuilder<AppStateCubit, AppState>(
        builder: (context, appState) {
          return BlocBuilder<DeviceCubit, List<Device>>(
            builder: (context, devices) {
              return SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    const Center(child: Header(title: "لائحة الاجهزة")),
                    Text(appState.selectedDeviceIndex.toString()),
                    const SizedBox(height: 20),
                    Hero(
                      tag: "change_selected_device",

                      child: Material(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ...List.generate(devices.length, (index) {
                                final device = devices[index];
                                return _buildDeviceItem(
                                  context,
                                  device,
                                  index, // Pass index explicitly
                                  appState,
                                );
                              }),
                            ],
                          ),
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
