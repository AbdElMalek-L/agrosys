/*

  DEVICE TEST PAGE: Responsible for providing the cubit to the view

  - use BlockProvider

 */

import 'package:agrosys/domain/repository/device_repo.dart';
import 'package:agrosys/presentation/pages/cubits/device_cubit.dart';
import 'package:agrosys/presentation/views/device_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeviceTestPage extends StatelessWidget {
  final DeviceRepo deviceRepo;

  const DeviceTestPage({super.key, required this.deviceRepo});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeviceCubit(deviceRepo),
      child: const DeviceView(),
    );
  }
}
