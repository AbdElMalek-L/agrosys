import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/presentation/themes/colors.dart';
import 'package:agrosys/presentation/widgets/header.dart';
import 'package:flutter/material.dart';

// TODO: this was made using AI refactor it to work proparlly!!

// TODO: do st.

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

  @override
  void initState() {
    super.initState();
    _currentDevice = widget.device;
    _nameController = TextEditingController(text: _currentDevice.name);
    _phoneController = TextEditingController(text: _currentDevice.phoneNumber);
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _updateDeviceName() {
    setState(() {
      _currentDevice = Device(
        id: _currentDevice.id,
        name: _nameController.text,
        model: _currentDevice.model,
        phoneNumber: _currentDevice.phoneNumber,
        passWord: _currentDevice.passWord,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديث الاسم إلى ${_nameController.text}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _updatePhoneNumber() {
    setState(() {
      _currentDevice = Device(
        id: _currentDevice.id,
        name: _currentDevice.name,
        model: _currentDevice.model,
        phoneNumber: _phoneController.text,
        passWord: _currentDevice.passWord,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديث الرقم إلى ${_phoneController.text}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _updatePassword() {
    if (_oldPasswordController.text != _currentDevice.passWord) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('كلمة المرور القديمة غير صحيحة'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _currentDevice = Device(
        id: _currentDevice.id,
        name: _currentDevice.name,
        model: _currentDevice.model,
        phoneNumber: _currentDevice.phoneNumber,
        passWord: _newPasswordController.text,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم تحديث كلمة المرور بنجاح'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    _oldPasswordController.clear();
    _newPasswordController.clear();
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('حذف الجهاز'),
            content: const Text('هل أنت متأكد من رغبتك في حذف هذا الجهاز؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم حذف ${_currentDevice.name}'),
                      backgroundColor: mainColor,
                    ),
                  );
                  Navigator.pop(context, true);
                },
                child: Text('حذف', style: TextStyle(color: mainColor)),
              ),
            ],
          ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Header(title: _currentDevice.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            children: [
              _buildSettingCard(
                title: 'اسم الجهاز',
                controller: _nameController,
                onPressed: _updateDeviceName,
              ),
              const SizedBox(height: 16),
              _buildSettingCard(
                title: 'رقم الهاتف',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                onPressed: _updatePhoneNumber,
              ),
              const SizedBox(height: 16),
              _buildPasswordCard(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _confirmDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('حذف الجهاز'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
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
  }) {
    // TODO: search this!!
    // final mainColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelSmall),
                  TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('تحديث'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordCard() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تغيير كلمة المرور',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _oldPasswordController,
                    obscureText: !_oldPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور القديمة',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _oldPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: mainColor,
                        ),
                        onPressed:
                            () => setState(
                              () => _oldPasswordVisible = !_oldPasswordVisible,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _newPasswordController,
                    obscureText: !_newPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور الجديدة',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _newPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: mainColor,
                        ),
                        onPressed:
                            () => setState(
                              () => _newPasswordVisible = !_newPasswordVisible,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('تحديث كلمة المرور'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
