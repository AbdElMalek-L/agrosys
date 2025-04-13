import 'package:agrosys/domain/models/app_state.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/presentation/cubits/device_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

/// A widget that displays a power control button (Lottie animation)
/// and handles toggling the power state of a device via SMS.
class PowerControlButton extends StatelessWidget {
  final Device device;
  final AppState appState; // Needed to get the selected device index
  final Function(String, String) onTogglePower; // Callback to send SMS

  // Asset paths for Lottie animations
  final String controlAssetPowerOn = "assets/power_animation.json";
  final String controlAssetPowerOff = "assets/power_off.json";

  const PowerControlButton({
    super.key,
    required this.device,
    required this.appState,
    required this.onTogglePower,
  });

  @override
  Widget build(BuildContext context) {
    // Listen to DeviceCubit changes to update the button state
    return BlocBuilder<DeviceCubit, List<Device>>(
      builder: (context, devices) {
        // Ensure we have the latest state for the *currently selected* device
        // This assumes the 'device' passed in might be stale if not updated
        // by the parent widget listening to the cubit. A safer approach might
        // be to just use appState.selectedDeviceIndex directly if 'devices'
        // list is guaranteed to be up-to-date by the BlocBuilder.
        final currentDevice = devices[appState.selectedDeviceIndex];

        return Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                  // 1. Update local state via Cubit
                  context.read<DeviceCubit>().togglePower(currentDevice);

                  // 2. Prepare SMS command
                  String phoneNumber = currentDevice.phoneNumber;
                  // Use the *new* power state after toggle for the command
                  String togglePowerCmd =
                      "${currentDevice.passWord}#${!currentDevice.isPoweredOn ? "ON" : "OFF"}#";

                  // 3. Trigger SMS sending via callback
                  onTogglePower(phoneNumber, togglePowerCmd);
                },
                child: Lottie.asset(
                  // Use currentDevice state to determine which animation to show
                  currentDevice.isPoweredOn
                      ? controlAssetPowerOff // Show 'Off' animation if powered On
                      : controlAssetPowerOn, // Show 'On' animation if powered Off
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              child: Text(
                // Use currentDevice state for the label
                currentDevice.isPoweredOn ? "إيقاف التشغيل" : "تشغيل",
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        );
      },
    );
  }
}
