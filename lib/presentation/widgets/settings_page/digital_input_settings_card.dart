import 'package:agrosys/controllers/sms_controller.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:flutter/material.dart';

class DigitalInputSettingsCard extends StatefulWidget {
  final Device device;
  final SMSController smsController;

  const DigitalInputSettingsCard({
    super.key,
    required this.device,
    required this.smsController,
  });

  @override
  State<DigitalInputSettingsCard> createState() =>
      _DigitalInputSettingsCardState();
}

class _DigitalInputSettingsCardState extends State<DigitalInputSettingsCard> {
  // true for Enabled (EA), false for Disabled (DA)
  // Default to disabled as per table. Ideally, this state would be fetched or stored.
  bool _digitalInputsEnabled = false;

  @override
  void initState() {
    super.initState();
    // TODO: Consider fetching the current state of digital inputs from the device if possible.
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

  void _toggleDigitalInputs(bool enable) {
    final previousState = _digitalInputsEnabled;
    setState(() {
      _digitalInputsEnabled = enable;
    });

    final actionCommand = enable ? "#EA#" : "#DA#";
    final statusMessage =
        enable ? 'تم تفعيل المدخلات الرقمية' : 'تم تعطيل المدخلات الرقمية';

    _sendDeviceCommand(
      actionCommand,
      successMessage: 'تم إرسال أمر $statusMessage.',
      defaultResponseMessage: statusMessage,
    ).catchError((_) {
      if (mounted) {
        setState(() {
          _digitalInputsEnabled = previousState;
        });
      }
    });
  }

  void _inquireAlarmSettings() {
    _sendDeviceCommand(
      "#AL?",
      defaultResponseMessage: 'تم إرسال استعلام إعدادات الإنذار.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إعدادات المدخلات الرقمية والإنذار',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('حالة المدخلات الرقمية'),
              subtitle: Text(
                _digitalInputsEnabled ? 'مفعل (EA)' : 'معطل (DA - افتراضي)',
              ),
              value: _digitalInputsEnabled,
              onChanged: _toggleDigitalInputs,
              secondary: Icon(
                _digitalInputsEnabled
                    ? Icons.input_rounded
                    : Icons.input_outlined,
              ),
              activeColor: theme.colorScheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                icon: const Icon(Icons.help_outline),
                label: const Text('استعلام إعدادات الإنذار'),
                onPressed: _inquireAlarmSettings,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
