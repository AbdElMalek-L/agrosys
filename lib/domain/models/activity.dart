/*

DEVICE MODEL

This a device object 
________________________________________________________________________________

It has these propeties:

- id
- model
- name
- phoneNumber
- passWord
- isPowredOn
- signal
________________________________________________________________________________

Methodes:

- toggle power on and off

*/

class Device {
  final int id;
  final String model;
  final String name;
  final String phoneNumber;
  final String passWord;
  final bool isPoweredOn;
  final int signal;

  Device({
    required this.id,
    required this.model,
    required this.name,
    required this.phoneNumber,
    required this.passWord,
    this.isPoweredOn = false,
    this.signal = 0,
  });

  Device togglePower() {
    return Device(
      id: id,
      model: model,
      name: name,
      phoneNumber: phoneNumber,
      passWord: passWord,
      isPoweredOn: !isPoweredOn,
      signal: signal,
    );
  }

  Device updateSignal(int signal) {
    return Device(
      id: id,
      model: model,
      name: name,
      phoneNumber: phoneNumber,
      passWord: passWord,
      isPoweredOn: isPoweredOn,
      signal: signal,
    );
  }
}
