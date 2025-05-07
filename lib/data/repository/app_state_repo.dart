/*

  STORAGE REPO
  
  This implements the device repo and handles stroing, retriving, updating,
  deleting in the local storage.

 */

import 'dart:convert';
import 'package:agrosys/data/models/app_state_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrosys/domain/models/app_state.dart';
import 'package:agrosys/domain/repository/app_state_repo.dart';

class AppStateStorageRepo implements AppStateRepo {
  final SharedPreferences storage;
  static const String appStateKey = "stored_app_state";

  AppStateStorageRepo(this.storage);

  @override
  Future<AppState> getAppState() async {
    final storedData = storage.getString(appStateKey);
    if (storedData == null) {
      return AppState(); // Return default state if none is stored
    }
    return AppStateStorage.fromJson(jsonDecode(storedData)).toAppState();
  }

  @override
  Future<void> updateAppState(AppState newState) async {
    await storage.setString(
      appStateKey,
      jsonEncode(AppStateStorage.fromDomain(newState).toJson()),
    );
  }
}
