/*

APPSTATE MODEL

This a Appstate object 
________________________________________________________________________________

It has these propeties:

- selectedDeviceId
- darkMode
- seenIntro
________________________________________________________________________________

Methodes:

- toggle dark mode and light mode
- update selected device

*/

import 'package:agrosys/domain/models/device.dart';

class AppState {
  final int? selectedDeviceId;
  final bool darkMode;
  final bool seenIntro;

  AppState({
    this.selectedDeviceId,
    this.darkMode = false,
    this.seenIntro = false,
  });

  AppState toggleDarkMode() {
    return AppState(
      selectedDeviceId: selectedDeviceId,
      darkMode: !darkMode,
      seenIntro: seenIntro,
    );
  }

  AppState updateSelectedDevieId(Device device) {
    return AppState(
      selectedDeviceId: device.id,
      darkMode: darkMode,
      seenIntro: seenIntro,
    );
  }

  AppState sawIntro() {
    return AppState(
      selectedDeviceId: selectedDeviceId,
      darkMode: darkMode,
      seenIntro: true,
    );
  }
}
