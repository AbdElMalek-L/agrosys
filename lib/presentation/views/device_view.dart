/*

  DEVICE VIEW: Responsible for the UI

  - use BlocBuilder

*/
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/presentation/pages/cubits/device_cubit.dart';
import '../themes/colors.dart';
import '../widgets/header.dart';
import '../widgets/recent_activity.dart';
import '../widgets/signal_indicator.dart';

class DeviceView extends StatefulWidget {
  const DeviceView({super.key});

  @override
  _DeviceViewState createState() => _DeviceViewState();
}

class _DeviceViewState extends State<DeviceView> {
  Device? selectedDevice;
  bool _isExpanded = false;
  int _expansionKey = 0;

  final String controlAssetPowerOn = "assets/power_animation.json";
  final String controlAssetPowerOff = "assets/power_off.json";

  void _controlDevice(Device device) {
    context.read<DeviceCubit>().togglePower(device);
  }

  Widget _buildDeviceItem(BuildContext context, Device device) {
    final deviceCubit = context.read<DeviceCubit>();
    return Slidable(
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
            onPressed: (_) => _showSettingsDialog(context, device),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.settings,
            label: 'إعدادات',
          ),
        ],
      ),
      child: Column(
        children: [
          Divider(
            indent: 30,
            endIndent: 30,
            thickness: 1,
            color: Colors.green[100],
          ),
          ListTile(
            title: Text(
              device.name,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color:
                    selectedDevice?.id == device.id ? mainColor : Colors.black,
              ),
            ),
            trailing:
                selectedDevice?.id == device.id
                    ? Icon(Icons.check_circle, color: mainColor)
                    : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onTap: () {
              setState(() {
                selectedDevice = device;
                _expansionKey++;
                _isExpanded = false;
              });
            },
          ),
        ],
      ),
    );
  }

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
                child: const Text("إلغاء"),
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
                child: const Text("إضافة"),
              ),
            ],
          ),
    );
  }

  void _showSettingsDialog(BuildContext context, Device device) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("إعدادات ${device.name}"),
            content: const Text("هنا يمكنك إضافة إعدادات الجهاز"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("إغلاق"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DeviceCubit, List<Device>>(
        builder: (context, devices) {
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
                        child: Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            key: ValueKey(_expansionKey),
                            onExpansionChanged:
                                (expanded) =>
                                    setState(() => _isExpanded = expanded),
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                            childrenPadding: const EdgeInsets.only(bottom: 12),
                            iconColor: Colors.green[700],
                            collapsedIconColor: Colors.green[700],
                            title: Text(
                              selectedDevice?.name ?? "الجهاز",
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    selectedDevice != null
                                        ? Colors.black
                                        : Colors.grey[600],
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            trailing: AnimatedRotation(
                              turns: _isExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: const Icon(Icons.expand_more),
                            ),
                            children: [
                              ...devices.map(
                                (device) => _buildDeviceItem(context, device),
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.add,
                                  color: Colors.green[700],
                                ),
                                title: const Text(
                                  "إضافة جهاز جديد",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                  textDirection: TextDirection.rtl,
                                ),
                                onTap: () => _showInsertionForm(context),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                tileColor: Colors.green[50],
                                splashColor: Colors.green[100],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // const SignalIndicator(),
                      const SizedBox(height: 20),
                      const SizedBox(height: 20),
                      if (selectedDevice != null) ...[
                        BlocBuilder<DeviceCubit, List<Device>>(
                          builder: (context, devices) {
                            // Get the updated device from the list
                            final currentDevice = devices.firstWhere(
                              (d) => d.id == selectedDevice!.id,
                              orElse: () => selectedDevice!,
                            );

                            return Column(
                              children: [
                                Center(
                                  child: GestureDetector(
                                    onTap:
                                        () => context
                                            .read<DeviceCubit>()
                                            .togglePower(currentDevice),
                                    child: Lottie.asset(
                                      currentDevice.isPoweredOn
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
                                    currentDevice.isPoweredOn
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
      ),
    );
  }
}
