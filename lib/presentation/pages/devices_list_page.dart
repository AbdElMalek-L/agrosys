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

class DevicesListPage extends StatelessWidget {
  const DevicesListPage({super.key});

  Widget _buildDeviceItem(
    BuildContext context,
    Device device,
    int index,
    AppState appState,
  ) {
    final deviceCubit = context.read<DeviceCubit>();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
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
                onPressed: (_) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(device: device),
                    ),
                  );
                },
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.settings,
                label: 'إعدادات',
              ),
            ],
          ),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onTap: () {
              context.read<AppStateCubit>().setSelectedDevice(index);
              Navigator.pop(context);
            },
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.model,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        appState.selectedDeviceIndex == index
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                  ),
                ),
                Text(
                  device.name,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color:
                        appState.selectedDeviceIndex == index
                            ? colorScheme.primary
                            : colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            trailing:
                appState.selectedDeviceIndex == index
                    ? Icon(Icons.check_circle, color: colorScheme.primary)
                    : null,
          ),
        ),
        Divider(
          indent: 30,
          endIndent: 30,
          thickness: 1,
          color: colorScheme.primary.withOpacity(0.1),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final colorScheme = Theme.of(context).colorScheme;

=======
>>>>>>> parent of c530d7f (add sms for password update and setting the default phone number)
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddDevicePage()),
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
                    const SizedBox(height: 20),
                    const Center(child: Header(title: "لائحة الاجهزة")),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Hero(
                        tag: "change_selected_device",
                        child: Material(
                          color: Colors.transparent,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            itemCount: devices.length,
                            itemBuilder: (context, index) {
                              return _buildDeviceItem(
                                context,
                                devices[index],
                                index,
                                appState,
                              );
                            },
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
