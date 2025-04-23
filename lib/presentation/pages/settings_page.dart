import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/presentation/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/device_cubit.dart';
import '../../controllers/sms_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.device});

  final Device device;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  bool _oldPasswordVisible = false;
  bool _newPasswordVisible = false;
  late Device _currentDevice;

  final _formKey = GlobalKey<FormState>();
  final SMSController _smsController = SMSController();

  @override
  void initState() {
    super.initState();
    _currentDevice = widget.device;
    _nameController = TextEditingController(text: _currentDevice.name);
    _phoneController = TextEditingController(text: _currentDevice.phoneNumber);
    _oldPasswordController = TextEditingController(
      text: _currentDevice.passWord,
    );
    _newPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _smsController.dispose();
    super.dispose();
  }

  void _updateDevice(Device updatedDevice) {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _currentDevice = updatedDevice;
      });
      context.read<DeviceCubit>().updateDevice(widget.device, updatedDevice);
    }
  }

  void _updateDeviceName() {
    final updatedDevice = _currentDevice.copyWith(name: _nameController.text);
    _updateDevice(updatedDevice);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديث الاسم إلى ${_nameController.text}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _updatePhoneNumber() {
    final updatedDevice = _currentDevice.copyWith(
      phoneNumber: _phoneController.text,
    );
    _updateDevice(updatedDevice);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديث الرقم إلى ${_phoneController.text}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _updatePassword() {
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('يرجى ملء حقلي كلمة المرور القديمة والجديدة'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    if (_oldPasswordController.text != widget.device.passWord) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('كلمة المرور القديمة غير صحيحة'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    if (_newPasswordController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'يجب أن تكون كلمة المرور الجديدة 4 أرقام على الأقل',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final updatedDevice = _currentDevice.copyWith(
      passWord: _newPasswordController.text,
    );
    context.read<DeviceCubit>().updateDevice(widget.device, updatedDevice);

    final String oldPassword = _oldPasswordController.text;
    final String newPassword = _newPasswordController.text;
    final String smsCommand = "$oldPassword#PWD$newPassword#PWD$newPassword#";

    final isMounted = mounted;

    _smsController
        .sendSimpleSMS(
          phoneNumber: _currentDevice.phoneNumber,
          message: smsCommand,
        )
        .then((success) {
          if (!success && isMounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('فشل إرسال أمر تغيير كلمة المرور عبر SMS'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم تحديث كلمة المرور بنجاح'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    setState(() {
      _oldPasswordVisible = false;
      _newPasswordVisible = false;
    });
    _oldPasswordController.clear();
    _newPasswordController.clear();
    FocusScope.of(context).unfocus();
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('حذف الجهاز'),
            content: Text(
              'هل أنت متأكد من رغبتك في حذف جهاز "${_currentDevice.name}"؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم حذف ${_currentDevice.name}'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                  Navigator.pop(context, true);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('حذف'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Header(title: _currentDevice.name)),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 24.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSettingCard(
                title: 'اسم الجهاز',
                controller: _nameController,
                onPressed: _updateDeviceName,
                icon: Icons.thermostat,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'اسم الجهاز لا يمكن أن يكون فارغًا';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildSettingCard(
                title: 'رقم الهاتف',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                onPressed: _updatePhoneNumber,
                icon: Icons.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'رقم الهاتف لا يمكن أن يكون فارغًا';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildPasswordCard(),
              const SizedBox(height: 32),
              FilledButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('حذف الجهاز'),
                onPressed: _confirmDelete,
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إغلاق'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required TextEditingController controller,
    TextInputType? keyboardType,
    required VoidCallback onPressed,
    IconData? icon,
    String? Function(String?)? validator,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                validator: validator,
                decoration: InputDecoration(
                  labelText: title,
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: onPressed, child: const Text('تحديث')),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تغيير كلمة المرور',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _oldPasswordController,
              obscureText: !_oldPasswordVisible,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'كلمة المرور القديمة',
                suffixIcon: IconButton(
                  icon: Icon(
                    _oldPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed:
                      () => setState(
                        () => _oldPasswordVisible = !_oldPasswordVisible,
                      ),
                ),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'كلمة المرور القديمة مطلوبة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPasswordController,
              obscureText: !_newPasswordVisible,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'كلمة المرور الجديدة',
                suffixIcon: IconButton(
                  icon: Icon(
                    _newPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed:
                      () => setState(
                        () => _newPasswordVisible = !_newPasswordVisible,
                      ),
                ),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'كلمة المرور الجديدة مطلوبة';
                }
                if (value.length < 4) {
                  return 'يجب أن تكون كلمة المرور 4 أرقام على الأقل';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _updatePassword,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text('تحديث كلمة المرور'),
            ),
          ],
        ),
      ),
    );
  }
}
