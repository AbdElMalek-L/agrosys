/*

DEVICE REPOSITORY

Here we define what the app can do.

*/

import 'package:agrosys/domain/models/device.dart';

abstract class DeviceRepo {
  // get list of devices
  Future<List<Device>> getDevices();

  // add a new device
  Future<void> addDevice(Device newDevice);

  // update an ecisting device
  Future<void> updateDevice(Device device);

  // delete a device
  Future<void> deleteDevice(Device device);
}
