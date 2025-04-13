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

  const MyApp({
    super.key,
    required this.deviceRepo,
    required this.appStateRepo,
    required this.deviceCubit,
    required this.appStateCubit,
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
        ],
        child: MaterialApp(
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
          home: IntroPage(), // Use HomeScreen as the home
        ),
      ),
    );
  }
}
