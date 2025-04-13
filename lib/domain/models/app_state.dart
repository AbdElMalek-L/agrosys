/*

APPSTATE MODEL

This a Appstate object 
________________________________________________________________________________

It has these propeties:

- selectedDevice
- darkMode
- seenIntro
________________________________________________________________________________

Methodes:

- toggle dark mode and light mode
- update selected device

*/

import 'package:agrosys/domain/models/device.dart';

class AppState {
  final int selectedDeviceIndex;
  final bool darkMode;
  final bool seenIntro;

  AppState({
    this.darkMode = true,
    this.seenIntro = false,
    this.selectedDeviceIndex = 0,
  });

  AppState toggleDarkMode() {
    return AppState(
      selectedDeviceIndex: selectedDeviceIndex,
      darkMode: !darkMode,
      seenIntro: seenIntro,
    );
  }

  AppState setSelectedDevice(int index) {
    return AppState(
      selectedDeviceIndex: index,
      darkMode: darkMode,
      seenIntro: seenIntro,
    );
  }

  AppState updateSelectedDevieId(Device device) {
    return AppState(
      selectedDeviceIndex: selectedDeviceIndex,
      darkMode: darkMode,
      seenIntro: seenIntro,
    );
  }

  AppState sawIntro() {
    return AppState(
      selectedDeviceIndex: selectedDeviceIndex,
      darkMode: darkMode,
      seenIntro: true,
    );
  }
}
