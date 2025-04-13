import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences.dart';

class ThemeCubit extends Cubit<bool> {
  final SharedPreferences prefs;
  static const String _isDarkModeKey = 'is_dark_mode';

  ThemeCubit(this.prefs) : super(prefs.getBool(_isDarkModeKey) ?? false);

  void toggleTheme() {
    final newValue = !state;
    emit(newValue);
    prefs.setBool(_isDarkModeKey, newValue);
  }

  bool get isDarkMode => state;
}