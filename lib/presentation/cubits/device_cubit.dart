/*

  DEVICE CUBIT - state management

  Each cubit is a card of devices.
 */

import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/domain/repository/device_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeviceCubit extends Cubit<List<Device>> {
  final DeviceRepo deviceRepo;

  DeviceCubit(this.deviceRepo) : super([]) {
    loadDevices();
  }

  Future<void> loadDevices() async {
    final devicesList = await deviceRepo.getDevices();
    emit(devicesList);
  }

  Future<void> addDevice(
    String model,
    String name,
    String phoneNumber,
    String passWord,
  ) async {
    final newDevice = Device(
      id: DateTime.now().millisecondsSinceEpoch,
      model: model,
      name: name,
      phoneNumber: phoneNumber,
      passWord: passWord,
    );

    await deviceRepo.addDevice(newDevice);
    loadDevices();
  }

  Future<void> deleteDevice(Device device) async {
    await deviceRepo.deleteDevice(device);
    loadDevices();
  }

  Future<void> togglePower(Device device) async {
    final updatedDevice = device.togglePower();
    await deviceRepo.updateDevice(updatedDevice);

    // Optimistic update
    final newState = List<Device>.from(state);
    final index = newState.indexWhere((d) => d.id == device.id);
    if (index != -1) {
      newState[index] = updatedDevice;
      emit(newState);
    }

    // Still sync with repo
    await deviceRepo.updateDevice(updatedDevice);
  }

  Future<void> updateSignal(Device device, int signal) async {
    final updatedDevice = device.updateSignal(signal);

    // Optimistic update
    final newState = List<Device>.from(state);
    final index = newState.indexWhere((d) => d.id == device.id);
    if (index != -1) {
      newState[index] = updatedDevice;
      emit(newState);
    }

    await deviceRepo.updateDevice(updatedDevice);
  }

  Future<void> updateDevice(Device oldDevice, Device newDevice) async {
    // First update local state for immediate UI update
    final newState = List<Device>.from(state);
    final index = newState.indexWhere((d) => d.id == oldDevice.id);

    if (index != -1) {
      // Create updated device with new properties but keep the same ID
      final updatedDevice = oldDevice.copyWith(
        name: newDevice.name,
        phoneNumber: newDevice.phoneNumber,
        passWord: newDevice.passWord,
        // include other properties as needed
      );

      newState[index] = updatedDevice;
      emit(newState);

      // Then update in repository
      await deviceRepo.updateDevice(updatedDevice);
    }
  }
}
