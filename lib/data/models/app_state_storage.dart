/*
  SHARED PREFERENCES APPSTATE MODEL

  Converts appState model to shared preferences model that we can stroe in our 
  local storage.

  

 */

import 'package:agrosys/domain/models/app_state.dart';
import 'package:agrosys/domain/models/device.dart';

class AppStateStorage {
  late Device? selectedDevice;
  late int selectedDeviceIndex;
  late bool darkMode;
  late bool seenIntro;

  //convert storage oobject -> pure appState object to use in our app
  AppState toAppState() {
    return AppState(
      selectedDevice: selectedDevice,
      selectedDeviceIndex: selectedDeviceIndex,
      darkMode: darkMode,
      seenIntro: seenIntro,
    );
  }

  // Convert pure appState object -> storage object to store in local storage
  static AppStateStorage fromDomain(AppState appState) {
    return AppStateStorage()
      ..selectedDevice = appState.selectedDevice
      ..selectedDeviceIndex = appState.selectedDeviceIndex
      ..darkMode = appState.darkMode
      ..seenIntro = appState.seenIntro;
  }

  // Convert JSON -> AppStateStorage
  static AppStateStorage fromJson(Map<String, dynamic> json) {
    return AppStateStorage()
      ..selectedDevice = json['selectedDevice']
      ..selectedDeviceIndex = json['selectedDeviceIndex']
      ..darkMode = json['darkMode']
      ..seenIntro = json['seenIntro'];
  }

  // Convert AppStateStorage -> JSON
  Map<String, dynamic> toJson() {
    return {
      'selectedDeviceId': selectedDevice,
      'selectedDeviceIndex': selectedDeviceIndex,
      'darkMode': darkMode,
      'seenIntro': seenIntro,
    };
  }
}
