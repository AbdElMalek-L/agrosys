import 'package:agrosys/controllers/sms_controller.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:flutter/material.dart';

class SystemInfoCard extends StatefulWidget {
  final Device device;
  final SMSController smsController;

  const SystemInfoCard({
    super.key,
    required this.device,
    required this.smsController,
  });

  @override
  State<SystemInfoCard> createState() => _SystemInfoCardState();
}

class _SystemInfoCardState extends State<SystemInfoCard> {
  String _imei = 'انقر للاستعلام';
  String _csq = 'انقر للاستعلام';

  Future<void> _sendDeviceCommand(
    String actionCommand, {
    String? successMessage,
    Function(String)? onResponseReceived,
  }) async {
    if (!mounted) return;

    final command = "${widget.device.passWord}$actionCommand";
    await widget.smsController.sendCommandWithResponse(
      context: context,
      phoneNumber: widget.device.phoneNumber,
      command: command,
      onMessage: (message) {
        if (!mounted) return;
        if (onResponseReceived != null) {
          onResponseReceived(message);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      onResult: (success, response) {
        if (!mounted) return;
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                successMessage ?? response ?? 'تم تنفيذ الأمر بنجاح',
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response ?? 'فشل تنفيذ الأمر'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
    );
  }

  void _queryImei() {
    _sendDeviceCommand(
      "#IMEI?",
      successMessage: 'تم استعلام رقم IMEI بنجاح',
      onResponseReceived: (response) {
        if (mounted && response.startsWith('IMEI:')) {
          setState(() {
            _imei = response.substring('IMEI:'.length).trim();
          });
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('استجابة IMEI: $response'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
    );
  }

  void _queryCsq() {
    _sendDeviceCommand(
      "#CSQ?",
      successMessage: 'تم استعلام قوة الإشارة بنجاح',
      onResponseReceived: (response) {
        if (mounted && response.startsWith('Signal value:')) {
          setState(() {
            _csq = response.substring('Signal value:'.length).trim();
          });
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('استجابة قوة الإشارة: $response'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
    );
  }

  void _resetDevice() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تأكيد إعادة الضبط'),
            content: const Text(
              'هل أنت متأكد من رغبتك في إعادة ضبط الجهاز إلى إعدادات المصنع؟\nهذا الإجراء لا يمكن التراجع عنه.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  _sendDeviceCommand(
                    "#RESET#",
                    successMessage:
                        'تم إرسال أمر إعادة الضبط. سيتم إعادة تشغيل الجهاز خلال 3 دقائق.',
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('إعادة ضبط'),
              ),
            ],
          ),
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
              'معلومات النظام والإجراءات',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.perm_device_information),
              title: const Text('رقم IMEI'),
              subtitle: Text(_imei),
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _queryImei,
                tooltip: 'استعلام IMEI',
              ),
              contentPadding: EdgeInsets.zero,
              titleAlignment: ListTileTitleAlignment.center,
            ),
            ListTile(
              leading: const Icon(Icons.signal_cellular_alt),
              title: const Text('قوة إشارة GSM'),
              subtitle: Text(_csq),
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _queryCsq,
                tooltip: 'استعلام قوة الإشارة',
              ),
              contentPadding: EdgeInsets.zero,
              titleAlignment: ListTileTitleAlignment.center,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                icon: const Icon(
                  Icons.settings_backup_restore,
                  color: Colors.white,
                ),
                label: const Text('إعادة ضبط الجهاز'),
                onPressed: _resetDevice,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
