import 'package:agrosys/controllers/sms_controller.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart'; // For phone number input

class AuthorizedNumbersCard extends StatefulWidget {
  final Device device;
  final SMSController smsController;

  const AuthorizedNumbersCard({
    super.key,
    required this.device,
    required this.smsController,
  });

  @override
  State<AuthorizedNumbersCard> createState() => _AuthorizedNumbersCardState();
}

class _AuthorizedNumbersCardState extends State<AuthorizedNumbersCard> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _serialController = TextEditingController();
  final TextEditingController _startSerialController = TextEditingController();
  final TextEditingController _endSerialController = TextEditingController();
  String?
  _fullPhoneNumber; // To store the complete phone number with country code

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _serialController.dispose();
    _startSerialController.dispose();
    _endSerialController.dispose();
    super.dispose();
  }

  Future<void> _sendDeviceCommand(
    String actionCommand, {
    String? successMessage,
    String? defaultResponseMessage,
  }) async {
    if (!mounted) return;

    final command = "${widget.device.passWord}$actionCommand";
    await widget.smsController.sendCommandWithResponse(
      context: context,
      phoneNumber: widget.device.phoneNumber,
      command: command,
      onMessage: (message) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
          ),
        );
      },
      onResult: (success, response) {
        if (!mounted) return;
        final message =
            response ??
            (success
                ? (successMessage ?? 'Command successful')
                : 'Command failed');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor:
                success
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
          ),
        );
      },
    );
  }

  void _addAuthorizedNumber() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_fullPhoneNumber == null || _fullPhoneNumber!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('الرجاء إدخال رقم هاتف صحيح'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      final serial = _serialController.text;
      final cleanedPhoneNumber =
          _fullPhoneNumber!.startsWith('+')
              ? '+' +
                  _fullPhoneNumber!.substring(1).replaceAll(RegExp(r'\D'), '')
              : _fullPhoneNumber!.replaceAll(RegExp(r'\D'), '');

      _sendDeviceCommand(
        "#TEL$cleanedPhoneNumber#$serial#",
        successMessage:
            'تم إضافة الرقم $cleanedPhoneNumber في التسلسل $serial بنجاح',
      );
      _phoneNumberController.clear();
      _serialController.clear();
      _fullPhoneNumber = null;
      FocusScope.of(context).unfocus();
    }
  }

  void _removeAuthorizedNumberByValue() {
    if (_phoneNumberController.text.isNotEmpty) {
      final String phoneNumberValue =
          _fullPhoneNumber!.startsWith('+')
              ? '+' +
                  _fullPhoneNumber!.substring(1).replaceAll(RegExp(r'\D'), '')
              : _fullPhoneNumber!.replaceAll(RegExp(r'\D'), '');
      _sendDeviceCommand(
        "#DEL$phoneNumberValue#",
        successMessage: 'تم حذف الرقم $phoneNumberValue بنجاح',
      );
      _phoneNumberController.clear();
      _fullPhoneNumber = null;
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('الرجاء إدخال رقم الهاتف المراد حذفه'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _clearAuthorizedNumberBySerial() {
    if (_serialController.text.isNotEmpty) {
      final serial = _serialController.text;
      _sendDeviceCommand(
        "#TEL#$serial#",
        successMessage: 'تم مسح الرقم في التسلسل $serial بنجاح',
      );
      _serialController.clear();
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('الرجاء إدخال الرقم التسلسلي المراد مسحه'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _clearAuthorizedNumberRange() {
    final startSerial = _startSerialController.text;
    final endSerial = _endSerialController.text;
    if (startSerial.isNotEmpty && endSerial.isNotEmpty) {
      _sendDeviceCommand(
        "#CRTEL$startSerial#$endSerial#",
        successMessage:
            'تم مسح الأرقام من التسلسل $startSerial إلى $endSerial بنجاح',
      );
      _startSerialController.clear();
      _endSerialController.clear();
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('الرجاء إدخال نطاق التسلسل المراد مسحه'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _queryAuthorizedNumberBySerial() {
    if (_serialController.text.isNotEmpty) {
      final serial = _serialController.text;
      _sendDeviceCommand(
        "#TEL$serial?#",
        defaultResponseMessage: 'جاري استعلام الرقم في التسلسل $serial',
      );
      _serialController.clear();
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'الرجاء إدخال الرقم التسلسلي المراد الاستعلام عنه',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _queryAuthorizedNumberRange() {
    final startSerial = _startSerialController.text;
    final endSerial = _endSerialController.text;
    if (startSerial.isNotEmpty && endSerial.isNotEmpty) {
      _sendDeviceCommand(
        "#CRTEL$startSerial#$endSerial#",
        defaultResponseMessage:
            'جاري استعلام الأرقام من التسلسل $startSerial إلى $endSerial',
      );
      _startSerialController.clear();
      _endSerialController.clear();
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('الرجاء إدخال نطاق التسلسل المراد الاستعلام عنه'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'الأرقام المصرح بها',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              Text(
                'إدارة الأرقام المسموح لها بالتحكم في الجهاز',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 16),

              Text(
                'إضافة رقم جديد',
                style: theme.textTheme.titleSmall,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              IntlPhoneField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  alignLabelWithHint: true,
                ),
                initialCountryCode: 'MA',
                onChanged: (phone) {
                  _fullPhoneNumber = phone.completeNumber;
                },
                validator: (phoneNumber) {
                  if (phoneNumber == null || phoneNumber.number.isEmpty) {
                    return 'الرجاء إدخال رقم الهاتف';
                  }
                  return null;
                },
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _serialController,
                decoration: const InputDecoration(
                  labelText: 'الرقم التسلسلي',
                  hintText: 'مثال: 01، 02',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.confirmation_number_outlined),
                  alignLabelWithHint: true,
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                textDirection: TextDirection.ltr,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الرقم التسلسلي';
                  }
                  if (int.tryParse(value) == null || value.length > 3) {
                    return 'الرجاء إدخال رقم تسلسلي صحيح (مثال: 01)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  icon: const Icon(Icons.add_call),
                  label: const Text('إضافة'),
                  onPressed: _addAuthorizedNumber,
                ),
              ),
              const Divider(height: 32),

              Text(
                'إدارة الأرقام',
                style: theme.textTheme.titleSmall,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('حذف رقم'),
                      onPressed: _removeAuthorizedNumberByValue,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.clear),
                      label: const Text('مسح تسلسل'),
                      onPressed: _clearAuthorizedNumberBySerial,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('استعلام تسلسل'),
                onPressed: _queryAuthorizedNumberBySerial,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                ),
              ),
              const Divider(height: 32),

              Text(
                'إدارة نطاق التسلسل',
                style: theme.textTheme.titleSmall,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startSerialController,
                      decoration: const InputDecoration(
                        labelText: 'التسلسل الأول',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.play_arrow),
                        alignLabelWithHint: true,
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _endSerialController,
                      decoration: const InputDecoration(
                        labelText: 'التسلسل الأخير',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.stop),
                        alignLabelWithHint: true,
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.clear_all),
                      label: const Text('مسح النطاق'),
                      onPressed: _clearAuthorizedNumberRange,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.search),
                      label: const Text('استعلام النطاق'),
                      onPressed: _queryAuthorizedNumberRange,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
