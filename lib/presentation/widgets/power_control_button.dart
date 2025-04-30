import 'package:agrosys/domain/models/app_state.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/presentation/cubits/device_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class PowerControlButton extends StatelessWidget {
  final Device device;
  final AppState appState;
  final Function(String, String) onTogglePower;
  final bool isWaiting; // ✅ nouveau paramètre

  final String controlAssetPowerOn = "assets/power_animation.json";
  final String controlAssetPowerOff = "assets/power_off.json";

  const PowerControlButton({
    super.key,
    required this.device,
    required this.appState,
    required this.onTogglePower,
    this.isWaiting = false, // ✅ valeur par défaut
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceCubit, List<Device>>(
      builder: (context, devices) {
        final currentDevice = devices[appState.selectedDeviceIndex];

        final bool isOn = currentDevice.isPoweredOn;
        final String command =
            "${currentDevice.passWord}#${!isOn ? "ON" : "OFF"}#";

        return Column(
          children: [
            Center(
              child: GestureDetector(
                onTap:
                    isWaiting
                        ? null
                        : () {
                          onTogglePower(currentDevice.phoneNumber, command);
                        },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Lottie.asset(
                      isOn ? controlAssetPowerOff : controlAssetPowerOn,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                      animate: !isWaiting, // ✅ stop animation if waiting
                    ),
                    if (isWaiting)
                      const Positioned(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),
            ),
            Center(
              child: Text(
                isWaiting
                    ? "جارٍ الإنتظار..."
                    : isOn
                    ? "إيقاف التشغيل"
                    : "تشغيل",
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }
}
