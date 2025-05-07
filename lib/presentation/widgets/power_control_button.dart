import 'package:agrosys/domain/models/app_state.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/presentation/cubits/device_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PowerControlButton extends StatefulWidget {
  final Device device;
  final AppState appState;
  final Function(String, String) onTogglePower;
  final bool isWaiting;

  const PowerControlButton({
    super.key,
    required this.device,
    required this.appState,
    required this.onTogglePower,
    this.isWaiting = false,
  });

  @override
  State<PowerControlButton> createState() => _PowerControlButtonState();
}

class _PowerControlButtonState extends State<PowerControlButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceCubit, List<Device>>(
      builder: (context, devices) {
        final currentDevice = devices[widget.appState.selectedDeviceIndex];
        final bool isOn = currentDevice.isPoweredOn;

        // Generate command based on current state - send opposite command
        final String command =
            "${currentDevice.passWord}#${isOn ? "OFF" : "ON"}#";

        // Determine button color based on device state
        final Color baseColor =
            widget.isWaiting
                ? Colors.grey
                : (isOn
                    ? const Color(0xFFE70808) // red
                    : const Color.fromARGB(255, 5, 138, 27)); // green

        final bool useGradient = !widget.isWaiting && !isOn;

        return Column(
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: GestureDetector(
                onTap:
                    widget.isWaiting
                        ? null
                        : () => widget.onTogglePower(
                          currentDevice.phoneNumber,
                          command,
                        ),
                child: Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient:
                        useGradient
                            ? LinearGradient(
                              colors: [
                                const Color.fromARGB(255, 4, 139, 38),
                                const Color.fromARGB(255, 8, 134, 52),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                            : null,
                    color: !useGradient ? baseColor : null,
                    boxShadow: [
                      BoxShadow(
                        color: baseColor.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.power_settings_new,
                      size: 38,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.isWaiting ? "جارٍ الإنتظار..." : (isOn ? "مشغل" : "تشغيل"),
              style: const TextStyle(fontSize: 15),
              textDirection: TextDirection.rtl,
            ),
          ],
        );
      },
    );
  }
}
