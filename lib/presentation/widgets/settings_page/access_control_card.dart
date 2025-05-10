import 'package:agrosys/controllers/sms_controller.dart';
import 'package:agrosys/domain/models/device.dart';
import 'package:flutter/material.dart';

enum AccessMode {
  allowAll, // Corresponds to #AA#
  authorizedOnly, // Corresponds to #AU#
}

class AccessControlCard extends StatefulWidget {
  final Device device;
  final SMSController smsController;
  // It's good practice to initialize the access mode, e.g., from device settings or a default.
  // For this example, we'll assume a default or that it's managed externally if needed.
  final AccessMode initialAccessMode;

  const AccessControlCard({
    super.key,
    required this.device,
    required this.smsController,
    this.initialAccessMode =
        AccessMode.authorizedOnly, // Default to authorized only
  });

  @override
  State<AccessControlCard> createState() => _AccessControlCardState();
}

class _AccessControlCardState extends State<AccessControlCard> {
  late AccessMode _selectedAccessMode;

  @override
  void initState() {
    super.initState();
    _selectedAccessMode = widget.initialAccessMode;
    // TODO: Fetch current access mode from device if possible, to reflect actual state.
  }

  Future<void> _setAccessMode(AccessMode mode) async {
    if (!mounted) return;

    final String actionCommand = mode == AccessMode.allowAll ? "#AA#" : "#AU#";
    final String command = "${widget.device.passWord}$actionCommand";
    final String modeDescription =
        mode == AccessMode.allowAll
            ? "السماح لجميع الأرقام"
            : "الأرقام المصرح بها فقط";

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
          setState(() {
            _selectedAccessMode = mode;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response ?? 'تم تعيين وضع الوصول إلى $modeDescription بنجاح',
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response ?? 'فشل تعيين وضع الوصول إلى $modeDescription',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
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
              'التحكم في الوصول',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            Text(
              'إدارة صلاحيات الوصول والتحكم في الجهاز',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            RadioListTile<AccessMode>(
              title: const Text('السماح لجميع الأرقام'),
              subtitle: const Text('يمكن لأي رقم الاتصال والتحكم في الجهاز'),
              value: AccessMode.allowAll,
              groupValue: _selectedAccessMode,
              onChanged: (AccessMode? value) {
                if (value != null) {
                  _setAccessMode(value);
                }
              },
              activeColor: theme.colorScheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
            RadioListTile<AccessMode>(
              title: const Text('الأرقام المصرح بها فقط'),
              subtitle: const Text(
                'يمكن فقط للأرقام المصرح بها التحكم في الجهاز',
              ),
              value: AccessMode.authorizedOnly,
              groupValue: _selectedAccessMode,
              onChanged: (AccessMode? value) {
                if (value != null) {
                  _setAccessMode(value);
                }
              },
              activeColor: theme.colorScheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
