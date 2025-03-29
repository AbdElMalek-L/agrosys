/*

  DEVICE CUBIT - state management

  Each cubit is a card of devices.
 */

import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/domain/repository/device_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeviceCubit extends Cubit<List<Device>> {
  // Reference device repo
  final DeviceRepo deviceRepo;

  // Constructor initializes the cubit with an empty list
  DeviceCubit(this.deviceRepo) : super([]) {
    loadDevices();
  }

  // load
  Future<void> loadDevices() async {
    final devicesList = await deviceRepo.getDevices();

    // emit teh fetched list as the new state
    emit(devicesList);
  }

  // add
  Future<void> addDevice(
    String model,
    String name,
    String phoneNumber,
    String passWord,
  ) async {
    // create a new device with a unique id
    final newDevice = Device(
      id: DateTime.now().millisecondsSinceEpoch,
      model: model,
      name: name,
      phoneNumber: phoneNumber,
      passWord: passWord,
    );

    // save the new device to repo
    await deviceRepo.addDevice(newDevice);

    // reload
    loadDevices();
  }

  // Delete
  Future<void> deleteDevice(Device device) async {
    // delete the device from the repo
    await deviceRepo.deleteDevice(device);

    // reload
    loadDevices();
  }

  // Toggle
  Future<void> togglePower(Device device) async {
    // toggle the power state
    final updatedDevice = device.togglePower();

    // update the device in the repo
    await deviceRepo.updateDevice(updatedDevice);

    //reload
    loadDevices();
  }

  // update signal
  Future<void> updateSignal(Device device, int signal) async {
    // update signal
    final updatedDevice = device.updateSignal(signal);

    // update the device in the repo
    await deviceRepo.updateDevice(updatedDevice);

    // reload
    loadDevices();
  }
}
