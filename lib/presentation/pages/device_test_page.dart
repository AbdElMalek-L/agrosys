/*

  DEVICE TEST PAGE: Responsible for providing the cubit to the view

  - use BlockProvider

 */

// TODO: convert this to dashboard.

import 'package:agrosys/domain/repository/device_repo.dart';
import 'package:agrosys/presentation/cubits/device_cubit.dart';
import 'package:agrosys/presentation/widgets/device_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeviceTestPage extends StatelessWidget {
  const DeviceTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeviceCubit(context.read<DeviceRepo>()),
      child: const DeviceView(),
    );
  }
}
