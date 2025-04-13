import 'package:agrosys/domain/models/device.dart';
import 'package:agrosys/presentation/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/device_cubit.dart';
import '../widgets/app_drawer.dart';

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
  Map<String, bool> _expandedCards = {};

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
    _expandedCards = {
      'name': false,
      'phone': false,
      'password': false,
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _updateDevice(Device updatedDevice) {
    setState(() {
      _currentDevice = updatedDevice;
    });
    context.read<DeviceCubit>().updateDevice(widget.device, updatedDevice);
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
    if (_oldPasswordController.text != _currentDevice.passWord) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('كلمة المرور القديمة غير صحيحة'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final updatedDevice = _currentDevice.copyWith(
      passWord: _newPasswordController.text,
    );
    _updateDevice(updatedDevice);

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
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                  Navigator.pop(context, true);
                },
                child: Text(
                  'حذف',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        drawer: const AppDrawer(),
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
              _buildExpandableCard(
                title: 'اسم الجهاز',
                icon: Icons.person,
                cardKey: 'name',
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'أدخل اسم الجهاز',
                  ),
                ),
                onSave: _updateDeviceName,
              ),
              const SizedBox(height: 16),
              _buildExpandableCard(
                title: 'رقم الهاتف',
                icon: Icons.phone,
                cardKey: 'phone',
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'أدخل رقم الهاتف',
                  ),
                ),
                onSave: _updatePhoneNumber,
              ),
              const SizedBox(height: 16),
              _buildExpandableCard(
                title: 'تغيير كلمة المرور',
                icon: Icons.lock,
                cardKey: 'password',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _oldPasswordController,
                      obscureText: !_oldPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور القديمة',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _oldPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _oldPasswordVisible = !_oldPasswordVisible,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: !_newPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور الجديدة',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _newPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _newPasswordVisible = !_newPasswordVisible,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                onSave: _updatePassword,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _confirmDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
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

  Widget _buildExpandableCard({
    required String title,
    required IconData icon,
    required String cardKey,
    required Widget child,
    required VoidCallback onSave,
  }) {
    final isExpanded = _expandedCards[cardKey] ?? false;

    return Card(
      elevation: 0,
      child: Column(
        children: [
          ListTile(
            trailing: Icon(icon, color: Theme.of(context).colorScheme.primary),
            title: Text(title),
            leading: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Theme.of(context).colorScheme.primary,
            ),
            onTap: () => setState(() {
              _expandedCards[cardKey] = !isExpanded;
            }),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  child,
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        onSave();
                        setState(() {
                          _expandedCards[cardKey] = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('تحديث'),
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
