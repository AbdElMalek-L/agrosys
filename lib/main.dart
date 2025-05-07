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
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

void main() async {
  // Initialize Arabic locale data
  await initializeDateFormatting('ar');
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Create repository instances
  final DeviceRepo deviceRepo = DeviceStorageRepo(prefs);
  final AppStateRepo appStateRepo = AppStateStorageRepo(prefs);

  // Create cubit instances
  final DeviceCubit deviceCubit = DeviceCubit(deviceRepo);
  final AppStateCubit appStateCubit = AppStateCubit(appStateRepo);

  // Run the app with providers
  runApp(
    MyApp(
      deviceRepo: deviceRepo,
      appStateRepo: appStateRepo,
      deviceCubit: deviceCubit,
      appStateCubit: appStateCubit,
    ),
  );
}

class MyApp extends StatelessWidget {
  final DeviceRepo deviceRepo;
  final AppStateRepo appStateRepo;
  final DeviceCubit deviceCubit;
  final AppStateCubit appStateCubit;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  MyApp({
    super.key,
    required this.deviceRepo,
    required this.appStateRepo,
    required this.deviceCubit,
    required this.appStateCubit,
  });

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
      child: MultiProvider(
        providers: [
          Provider<DeviceRepo>.value(value: deviceRepo),
          Provider<AppStateRepo>.value(value: appStateRepo),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AppStateCubit>.value(value: appStateCubit),
            BlocProvider<DeviceCubit>.value(value: deviceCubit),
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
