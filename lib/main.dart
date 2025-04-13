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
import 'package:agrosys/presentation/cubits/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Create repository instances
  final DeviceRepo deviceRepo = DeviceStorageRepo(prefs);
  final AppStateRepo appStateRepo = AppStateStorageRepo(prefs);

  // Create cubit instances
  final DeviceCubit deviceCubit = DeviceCubit(deviceRepo);
  final AppStateCubit appStateCubit = AppStateCubit(appStateRepo);
  final ThemeCubit themeCubit = ThemeCubit(prefs);

  // Run the app with providers
  runApp(
    MyApp(
      deviceRepo: deviceRepo,
      appStateRepo: appStateRepo,
      deviceCubit: deviceCubit,
      appStateCubit: appStateCubit,
      themeCubit: themeCubit,
    ),
  );
}

class MyApp extends StatelessWidget {
  final DeviceRepo deviceRepo;
  final AppStateRepo appStateRepo;
  final DeviceCubit deviceCubit;
  final AppStateCubit appStateCubit;
  final ThemeCubit themeCubit;

  const MyApp({
    super.key,
    required this.deviceRepo,
    required this.appStateRepo,
    required this.deviceCubit,
    required this.appStateCubit,
    required this.themeCubit,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DeviceRepo>.value(value: deviceRepo),
        Provider<AppStateRepo>.value(value: appStateRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AppStateCubit>.value(value: appStateCubit),
          BlocProvider<DeviceCubit>.value(value: deviceCubit),
          BlocProvider<ThemeCubit>.value(value: themeCubit),
        ],
        child: BlocBuilder<ThemeCubit, bool>(
          builder: (context, isDarkMode) {
            return MaterialApp(
              theme: ThemeData(
            useMaterial3: true,
            colorScheme: const ColorScheme(
              brightness: Brightness.light,
              primary: Color(0xff009200), // Your green
              onPrimary: Colors.white,
              secondary: Color(0xFF004B23),
              onSecondary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
              error: Colors.red,
              onError: Colors.white,
            ),
            scaffoldBackgroundColor: Color(0xFFEAF1EA),
            snackBarTheme: SnackBarThemeData(
              backgroundColor: Color(0xFF0A8754),
              contentTextStyle: TextStyle(color: Colors.white),
            ),
          ),

              debugShowCheckedModeBanner: false,
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: const ColorScheme(
                  brightness: Brightness.dark,
                  primary: Color(0xff00B200),
                  onPrimary: Colors.white,
                  secondary: Color(0xFF004B23),
                  onSecondary: Colors.white,
                  surface: Color(0xFF121212),
                  onSurface: Colors.white,
                  error: Colors.red,
                  onError: Colors.white,
                ),
                scaffoldBackgroundColor: Color(0xFF121212),
                snackBarTheme: SnackBarThemeData(
                  backgroundColor: Color(0xFF0A8754),
                  contentTextStyle: TextStyle(color: Colors.white),
                ),
              ),
              themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: const IntroPage(),
            );
          },
        ),
      ),
    );
  }
}
