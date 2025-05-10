import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/presentation/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/device_cubit.dart';
import '../../controllers/sms_controller.dart';
import '../widgets/settings_page/setting_item_card.dart';
import '../widgets/settings_page/password_setting_card.dart';
import '../widgets/settings_page/authorized_numbers_card.dart';
import '../widgets/settings_page/relay_control_card.dart';
import '../widgets/settings_page/system_info_card.dart';
import '../widgets/settings_page/access_control_card.dart';
import '../widgets/settings_page/category_header.dart';
import '../widgets/settings_page/digital_input_settings_card.dart'; // Added import

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
  bool _isResponseEnabled = true;

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

  Future<void> _toggleResponseMessages(bool value) async {
    setState(() {
      _isResponseEnabled = value;
    });

    // Send the appropriate command to the device
    final command = value ? '#R#' : '#N#';
    await _smsController.sendCommandWithResponse(
      context: context,
      phoneNumber: _currentDevice.phoneNumber,
      command: '${_currentDevice.passWord}$command',
      onMessage: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      onResult: (success, response) {
        if (!success) {
          setState(() {
            _isResponseEnabled = !value; // Revert the toggle if command failed
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل في تغيير حالة الردود'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
              // Device Info Category
              const CategoryHeader(
                title: 'معلومات الجهاز',
                icon: Icons.devices_other,
              ),
              SettingItemCard(
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
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 16),
              SettingItemCard(
                title: 'رقم الهاتف',
                controller: _phoneController,
                onPressed: _updatePhoneNumber,
                icon: Icons.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'رقم الهاتف لا يمكن أن يكون فارغًا';
                  }
                  return null;
                },
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 28),
              // Security Category
              const CategoryHeader(title: 'الأمان', icon: Icons.lock),
              PasswordSettingCard(
                title: 'تغيير كلمة المرور',
                oldPasswordController: _oldPasswordController,
                newPasswordController: _newPasswordController,
                onUpdatePassword: _updatePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى ملء حقلي كلمة المرور القديمة والجديدة';
                  }
                  if (value.length < 4) {
                    return 'يجب أن تكون كلمة المرور 4 أرقام على الأقل';
                  }
                  return null;
                },
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 28),
              // Notifications Category
              const CategoryHeader(
                title: 'الإشعارات',
                icon: Icons.notifications_active,
              ),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SwitchListTile.adaptive(
                  value: _isResponseEnabled,
                  onChanged: _toggleResponseMessages,
                  title: Text(
                    'تفعيل الردود من الجهاز',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.right,
                  ),
                  secondary: Icon(Icons.sms, color: colorScheme.primary),
                  activeColor: colorScheme.primary,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Danger Zone Category
              CategoryHeader(
                title: 'المنطقة الخطرة',
                icon: Icons.warning_amber_rounded,
                iconColor: colorScheme.error,
              ),
              FilledButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('حذف الجهاز'),
                onPressed: _confirmDelete,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Authorized Numbers Management
              const CategoryHeader(
                title: 'الأرقام المصرح بها',
                icon: Icons.contacts,
              ),
              AuthorizedNumbersCard(
                device: _currentDevice,
                smsController: _smsController,
              ),
              const SizedBox(height: 28),
              // Relay Control
              const CategoryHeader(
                title: 'التحكم في المرحلات',
                icon: Icons.electrical_services,
              ),
              RelayControlCard(
                device: _currentDevice,
                smsController: _smsController,
              ),
              const SizedBox(height: 28),
              // System Information
              const CategoryHeader(
                title: 'معلومات النظام',
                icon: Icons.info_outline,
              ),
              SystemInfoCard(
                device: _currentDevice,
                smsController: _smsController,
              ),
              const SizedBox(height: 28),
              // Access Control
              const CategoryHeader(
                title: 'التحكم في الوصول',
                icon: Icons.security,
              ),
              AccessControlCard(
                device: _currentDevice,
                smsController: _smsController,
              ),
              const SizedBox(height: 28),
              // Digital Input Settings
              const CategoryHeader(
                title: 'إعدادات المدخلات الرقمية',
                icon: Icons.input,
              ),
              DigitalInputSettingsCard(
                device: _currentDevice,
                smsController: _smsController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
