import 'package:agrosys/controllers/sms_controller.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:flutter/material.dart';

class RelayControlCard extends StatefulWidget {
  final Device device;
  final SMSController smsController;

  const RelayControlCard({
    super.key,
    required this.device,
    required this.smsController,
  });

  @override
  State<RelayControlCard> createState() => _RelayControlCardState();
}

class _RelayControlCardState extends State<RelayControlCard> {
  late TextEditingController _relayTimeController;
  bool _isRelaySmsReturnEnabled =
      false; // Default state, ideally fetched or stored

  @override
  void initState() {
    super.initState();
    _relayTimeController = TextEditingController();
    // TODO: Consider fetching/initializing _isRelaySmsReturnEnabled from device.properties or similar if persisted
  }

  @override
  void dispose() {
    _relayTimeController.dispose();
    super.dispose();
  }

  Future<void> _sendDeviceCommand(
    String actionCommand, {
    String? successMessage,
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
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage ?? response ?? 'Command successful'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response ?? 'Command failed'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
    );
  }

  void _turnRelayOn() {
    _sendDeviceCommand("#ON#", successMessage: 'تم تشغيل المرحل بنجاح');
  }

  void _turnRelayOff() {
    _sendDeviceCommand("#OFF#", successMessage: 'تم إيقاف المرحل بنجاح');
  }

  void _setRelayCloseTime() {
    final time = _relayTimeController.text;
    if (time.isNotEmpty && time.length == 4 && int.tryParse(time) != null) {
      _sendDeviceCommand(
        "#GOT$time#",
        successMessage: 'تم تعيين وقت إغلاق المرحل إلى $time بنجاح',
      );
      _relayTimeController.clear();
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'الرجاء إدخال وقت صحيح مكون من 4 أرقام (مثال: 0019 لـ 1.9 ثانية)',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _toggleRelayActionSms(bool value) {
    final previousState = _isRelaySmsReturnEnabled;
    setState(() {
      _isRelaySmsReturnEnabled = value;
    });
    final actionCommand = value ? "#FR#" : "#FN#";
    final String statusMessage =
        value
            ? 'تم تفعيل تأكيد إجراءات المرحل عبر الرسائل'
            : 'تم تعطيل تأكيد إجراءات المرحل عبر الرسائل';

    final command = "${widget.device.passWord}$actionCommand";
    widget.smsController.sendCommandWithResponse(
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
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response ?? statusMessage),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response ?? 'فشل تحديث إعدادات تأكيد الرسائل'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          if (mounted) {
            setState(() {
              _isRelaySmsReturnEnabled = previousState;
            });
          }
        }
      },
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'التحكم في المرحلات',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            Text(
              'التحكم المباشر في مرحلات الجهاز',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.power_settings_new),
                    label: const Text('تشغيل'),
                    onPressed: _turnRelayOn,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green[700],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.power_off),
                    label: const Text('إيقاف'),
                    onPressed: _turnRelayOff,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'تعيين وقت إغلاق المرحل',
              style: theme.textTheme.titleSmall,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 4),
            Text(
              'أدخل 4 أرقام (مثال: 0019 لـ 1.9 ثانية، 0100 لـ 10.0 ثانية)',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _relayTimeController,
              decoration: const InputDecoration(
                labelText: 'قيمة الوقت',
                hintText: 'مثال: 0019',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer_outlined),
                counterText: "",
                alignLabelWithHint: true,
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                onPressed: _setRelayCloseTime,
                child: const Text('تعيين'),
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: Text(
                'تأكيد إجراءات المرحل عبر الرسائل',
                style: theme.textTheme.titleSmall,
                textAlign: TextAlign.right,
              ),
              subtitle: Text(
                _isRelaySmsReturnEnabled
                    ? 'مفعل (يرسل تأكيدات)'
                    : 'معطل (لا يرسل تأكيدات)',
                textAlign: TextAlign.right,
              ),
              value: _isRelaySmsReturnEnabled,
              onChanged: _toggleRelayActionSms,
              secondary: Icon(
                _isRelaySmsReturnEnabled
                    ? Icons.mark_chat_read_outlined
                    : Icons.speaker_notes_off_outlined,
              ),
              activeColor: theme.colorScheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
