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
    final textTheme = Theme.of(context).textTheme;
    final bool isSelected = appState.selectedDeviceIndex == index;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 14.0),
      elevation: isSelected ? 4.5 : 2.0,
      shadowColor: colorScheme.shadow.withOpacity(isSelected ? 0.3 : 0.15),
      color:
          isSelected
              ? colorScheme.primary.withOpacity(0.08)
              : colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side:
            isSelected
                ? BorderSide(color: colorScheme.primary, width: 1.5)
                : BorderSide.none,
      ),
      child: Slidable(
        key: Key(device.id.toString()),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (_) => deviceCubit.deleteDevice(device),
              backgroundColor: Colors.red.shade300,
              foregroundColor: Colors.white,
              icon: Icons.delete_sweep_outlined,
              label: 'حذف',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
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
              backgroundColor: Colors.blue.shade300,
              foregroundColor: Colors.white,
              icon: Icons.tune,
              label: 'إعدادات',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 20.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          onTap: () {
            context.read<AppStateCubit>().setSelectedDevice(index);
            Navigator.pop(context);
          },
          title: Text(
            device.model,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color:
                  isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              device.name,
              textDirection: TextDirection.rtl,
              style: textTheme.bodyMedium?.copyWith(
                color:
                    isSelected
                        ? colorScheme.primary.withOpacity(0.9)
                        : colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Chip(
                avatar: Icon(
                  Icons.power_settings_new,
                  color: Colors.white,
                  size: 14,
                ),
                label: Text(
                  device.isPoweredOn ? 'ON' : 'OFF',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 2.0,
                  vertical: 0,
                ),
                labelPadding: const EdgeInsets.only(left: 2.0, right: 6.0),
                visualDensity: VisualDensity.compact,
                backgroundColor:
                    device.isPoweredOn
                        ? Colors.green.shade600
                        : Colors.red.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide.none,
                ),
              ),
              const SizedBox(width: 8),
              Chip(
                avatar: Icon(Icons.schedule, color: Colors.white, size: 14),
                label: Text(
                  device.isScheduleEnabled ? 'ON' : 'OFF',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 2.0,
                  vertical: 0,
                ),
                labelPadding: const EdgeInsets.only(left: 2.0, right: 6.0),
                visualDensity: VisualDensity.compact,
                backgroundColor:
                    device.isScheduleEnabled
                        ? colorScheme.secondary
                        : Colors.grey.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-device-fab',
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        elevation: 4.0,
        tooltip: 'إضافة جهاز جديد',
        child: const Icon(Icons.add),
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddDevicePage()),
            ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surfaceContainerLowest,
              colorScheme.surfaceContainerHigh,
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        child: BlocBuilder<AppStateCubit, AppState>(
          builder: (context, appState) {
            return BlocBuilder<DeviceCubit, List<Device>>(
              builder: (context, devices) {
                return SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Header(title: "أجهزتي"),
                      ),
                      const SizedBox(height: 25),
                      Expanded(
                        child:
                            devices.isEmpty
                                ? _buildEmptyState(context)
                                : _buildDeviceList(context, devices, appState),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDeviceList(
    BuildContext context,
    List<Device> devices,
    AppState appState,
  ) {
    return Hero(
      tag: "change_selected_device",
      child: Material(
        color: Colors.transparent,
        child: ListView.builder(
          padding: const EdgeInsets.only(
            top: 10.0,
            bottom: 90.0,
            left: 5.0,
            right: 5.0,
          ),
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final animationDelay = Duration(milliseconds: 100 + (index * 60));
            return FutureBuilder(
              future: Future.delayed(animationDelay),
              builder: (context, snapshot) {
                final bool isVisible =
                    snapshot.connectionState == ConnectionState.done;
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: isVisible ? 1.0 : 0.0,
                  curve: Curves.easeOut,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 400),
                    offset: isVisible ? Offset.zero : const Offset(0, 0.1),
                    curve: Curves.easeOut,
                    child: _buildDeviceItem(
                      context,
                      devices[index],
                      index,
                      appState,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.agriculture_outlined,
            size: 80,
            color: colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'لا توجد أجهزة مسجلة',
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'انقر فوق الزر + لإضافة جهاز جديد',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
