/*

DEVICE REPOSITORY

Here we define what the app can do.

*/

import 'package:agrosys/domain/models/app_state.dart';

abstract class AppStateRepo {
  // Get app state
  Future<AppState> getAppState();

  // Update app state
  Future<void> updateAppState(AppState newState);
}
