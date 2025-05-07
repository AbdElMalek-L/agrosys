import 'package:agrosys/domain/models/app_state.dart';
import 'package:agrosys/presentation/cubits/device_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrosys/data/repository/app_state_repo.dart';
import 'package:agrosys/data/repository/device_storage_repo.dart';
import 'package:agrosys/domain/repository/app_state_repo.dart';
import 'package:agrosys/domain/repository/device_repo.dart';
import 'package:agrosys/presentation/pages/intro_page.dart';
import 'package:agrosys/presentation/cubits/app_state_cubit.dart';
import 'package:agrosys/presentation/themes/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:agrosys/controllers/schedule_service.dart';
import 'package:agrosys/controllers/sms_controller.dart';
import 'package:agrosys/controllers/background_service.dart';
import 'package:agrosys/controllers/notification_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:agrosys/presentation/cubits/recent_activity_cubit.dart';

void main() async {
  // Initialize Arabic locale data
  await initializeDateFormatting('ar');
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background service for running in background
  await BackgroundServiceManager.initialize();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Create repository instances
  final DeviceRepo deviceRepo = DeviceStorageRepo(prefs);
  final AppStateRepo appStateRepo = AppStateStorageRepo(prefs);

  // Create cubit instances
  final DeviceCubit deviceCubit = DeviceCubit(deviceRepo);
  final AppStateCubit appStateCubit = AppStateCubit(appStateRepo);
  final RecentActivityCubit recentActivityCubit = RecentActivityCubit();

  // Create SMS controller and schedule service
  final SMSController smsController = SMSController();
  final ScheduleService scheduleService = ScheduleService(
    deviceCubit,
    smsController,
  );

  // Start schedule monitoring (in-app)
  scheduleService.startScheduleMonitoring();

  // Schedule notifications for all devices
  await scheduleService.scheduleAllNotifications();

  // Load activities
  await recentActivityCubit.loadActivities();

  // Run the app with providers
  runApp(
    MyApp(
      deviceRepo: deviceRepo,
      appStateRepo: appStateRepo,
      deviceCubit: deviceCubit,
      appStateCubit: appStateCubit,
      recentActivityCubit: recentActivityCubit,
      scheduleService: scheduleService,
      notificationService: notificationService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final DeviceRepo deviceRepo;
  final AppStateRepo appStateRepo;
  final DeviceCubit deviceCubit;
  final AppStateCubit appStateCubit;
  final RecentActivityCubit recentActivityCubit;
  final ScheduleService scheduleService;
  final NotificationService notificationService;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  MyApp({
    super.key,
    required this.deviceRepo,
    required this.appStateRepo,
    required this.deviceCubit,
    required this.appStateCubit,
    required this.recentActivityCubit,
    required this.scheduleService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
      child: MultiProvider(
        providers: [
          Provider<DeviceRepo>.value(value: deviceRepo),
          Provider<AppStateRepo>.value(value: appStateRepo),
          Provider<ScheduleService>.value(value: scheduleService),
          Provider<NotificationService>.value(value: notificationService),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AppStateCubit>.value(value: appStateCubit),
            BlocProvider<DeviceCubit>.value(value: deviceCubit),
            BlocProvider<RecentActivityCubit>.value(value: recentActivityCubit),
          ],
          child: BlocBuilder<AppStateCubit, AppState>(
            builder: (context, appState) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: MaterialApp(
                  navigatorKey: _navigatorKey,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode:
                      appState.darkMode ? ThemeMode.dark : ThemeMode.light,
                  debugShowCheckedModeBanner: false,
                  home: const IntroPage(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
