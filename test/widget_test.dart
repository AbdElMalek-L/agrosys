// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:agrosys/data/repository/app_state_repo.dart';
import 'package:agrosys/data/repository/device_storage_repo.dart';
import 'package:agrosys/domain/repository/app_state_repo.dart';
import 'package:agrosys/domain/repository/device_repo.dart';
import 'package:agrosys/presentation/cubits/app_state_cubit.dart';
import 'package:agrosys/presentation/cubits/device_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrosys/controllers/schedule_service.dart';
import 'package:agrosys/controllers/notification_service.dart';
import 'package:agrosys/controllers/sms_controller.dart'; // Import SMSController
import 'package:agrosys/main.dart';
import 'package:agrosys/presentation/cubits/recent_activity_cubit.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Setup SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Create repository instances
    final DeviceRepo deviceRepo = DeviceStorageRepo(prefs);
    final AppStateRepo appStateRepo = AppStateStorageRepo(prefs);

    // Create cubit instances
    final DeviceCubit deviceCubit = DeviceCubit(deviceRepo);
    final AppStateCubit appStateCubit = AppStateCubit(appStateRepo);

    // Create service instances
    final SMSController smsController = SMSController();
    final ScheduleService scheduleService = ScheduleService();
    final NotificationService notificationService = NotificationService();

    // Create RecentActivityCubit
    final RecentActivityCubit recentActivityCubit = RecentActivityCubit();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MyApp(
        deviceRepo: deviceRepo,
        appStateRepo: appStateRepo,
        deviceCubit: deviceCubit,
        appStateCubit: appStateCubit,
        recentActivityCubit: recentActivityCubit,
      ),
    );

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
