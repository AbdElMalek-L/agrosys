/*

  DEVICE CUBIT - state management

  Each cubit is a card of devices.
 */

import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/domain/repository/device_repo.dart';
import 'package:agrosys/controllers/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeviceCubit extends Cubit<List<Device>> {
  final DeviceRepo deviceRepo;
  final NotificationService _notificationService = NotificationService();

  DeviceCubit(this.deviceRepo) : super([]) {
    loadDevices();
  }

  Future<void> loadDevices() async {
    final devicesList = await deviceRepo.getDevices();
    emit(devicesList);
  }

  void updatePowerState(int deviceIndex, bool isPoweredOn) {
    final currentDevices = state;

    if (deviceIndex >= 0 && deviceIndex < currentDevices.length) {
      final updatedDevice = currentDevices[deviceIndex].copyWith(
        isPoweredOn: isPoweredOn,
      );

      final updatedList = List<Device>.from(currentDevices);
      updatedList[deviceIndex] = updatedDevice;

      emit(updatedList);
    }
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
    // Cancel existing notifications for this device
    await _notificationService.cancelDeviceNotifications(device.id);

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
        isScheduleEnabled: newDevice.isScheduleEnabled,
        scheduleStartTime: newDevice.scheduleStartTime,
        scheduleEndTime: newDevice.scheduleEndTime,
        scheduleDays: newDevice.scheduleDays,
      );

      newState[index] = updatedDevice;
      emit(newState);

      // Then update in repository
      await deviceRepo.updateDevice(updatedDevice);

      // Update schedule notifications
      await _updateScheduleNotifications(updatedDevice);
    }
  }

  // Method to update schedule notifications for a device
  Future<void> _updateScheduleNotifications(Device device) async {
    // First cancel existing notifications
    await _notificationService.cancelDeviceNotifications(device.id);

    // If schedule is not enabled or times are not set, no need to schedule notifications
    if (!device.isScheduleEnabled ||
        device.scheduleStartTime == null ||
        device.scheduleEndTime == null) {
      return;
    }

    // Schedule start time notification
    await _notificationService.scheduleNotification(
      device: device,
      scheduledTime: device.scheduleStartTime!,
      isStartEvent: true,
    );

    // Schedule preview notification 5 minutes before start time
    await _notificationService.scheduleNotification(
      device: device,
      scheduledTime: device.scheduleStartTime!,
      isStartEvent: true,
      showPreview: true,
    );

    // Schedule end time notification
    await _notificationService.scheduleNotification(
      device: device,
      scheduledTime: device.scheduleEndTime!,
      isStartEvent: false,
    );

    // Schedule preview notification 5 minutes before end time
    await _notificationService.scheduleNotification(
      device: device,
      scheduledTime: device.scheduleEndTime!,
      isStartEvent: false,
      showPreview: true,
    );
  }
}
