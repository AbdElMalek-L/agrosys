import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agrosys/main.dart';

// Import Repositories
import 'package:agrosys/domain/repository/device_repo.dart';
import 'package:agrosys/domain/repository/app_state_repo.dart';

// Import Cubits
import 'package:agrosys/presentation/cubits/device_cubit.dart';
import 'package:agrosys/presentation/cubits/app_state_cubit.dart';
import 'package:agrosys/domain/models/device.dart';

import 'package:agrosys/domain/models/app_state.dart';

// Fake class for DeviceRepo for testing
class FakeDeviceRepo extends DeviceRepo {
  @override
  Future<void> addDevice(Device model) async {}

  @override
  Future<void> deleteDevice(Device model) async {} // Corrected here

  @override
  Future<List<Device>> getDevices() async {
    return []; // Return empty list for test
  }

  @override
  Future<void> updateDevice(Device model) async {}
}

// Fake class for AppStateRepo for testing
class FakeAppStateRepo extends AppStateRepo {
  @override
  Future<void> saveAppState(AppState state) async {}

  @override
  Future<AppState> getAppState() async {
    return AppState(
      selectedDeviceIndex: 0, // exemple device 0
      darkMode: false, // mode clair
      seenIntro: true, // intro déjà vue
    );
  }

  @override
  Future<void> updateAppState(AppState state) async {}
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Create fake instances for testing
    final deviceRepo = FakeDeviceRepo();
    final appStateRepo = FakeAppStateRepo();
    final deviceCubit = DeviceCubit(deviceRepo);
    final appStateCubit = AppStateCubit(appStateRepo);

    // Load MyApp with required parameters
    await tester.pumpWidget(
      MyApp(
        deviceRepo: deviceRepo,
        appStateRepo: appStateRepo,
        deviceCubit: deviceCubit,
        appStateCubit: appStateCubit,
      ),
    );

    // Initial test conditions
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap + icon
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // After tap
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
