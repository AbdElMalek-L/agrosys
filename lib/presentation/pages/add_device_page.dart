import 'package:agrosys/presentation/cubits/device_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../widgets/device_models_card.dart';
import '../widgets/header.dart';
import '../widgets/app_drawer.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

// TODO: fix the cubit dont refreshing when new device added
// TODO: add the new device as default selected in dashboard screen when saving.

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({super.key});

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _deviceNameController = TextEditingController();
  final TextEditingController _deviceNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedModel;

  @override
  void dispose() {
    _deviceNameController.dispose();
    _deviceNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const Center(child: Header(title: "إضافة جهاز جديد")),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Lottie.asset('assets/Adddevice.json', height: 200),
                    const SizedBox(height: 20),
                    _buildDeviceForm(context),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () => _addDevice(context),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.arrow_back_outlined,
                      size: 20,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text(
                      "إضافة جهاز",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: DeviceModelsCard(
                models: const ["RTU5024", "AGROS001", "MODEL003"],
                onModelSelected: (model) {
                  setState(() {
                    _selectedModel = model;
                  });
                },
              ),
            ),
            _buildInputField('اسم الجهاز', _deviceNameController, Icons.device_hub),
            _buildInputField('رقم الخاص بجهاز', _deviceNumberController, Icons.phone),
            _buildInputField('الرقم السري', _passwordController, Icons.lock),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: label == 'رقم الخاص بجهاز' 
          ? TextFormField(
              controller: controller,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                labelText: label,
                labelStyle: TextStyle(color: Colors.grey[600]),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                prefixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      '+212',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.0,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال قيمة';
                }
                // Remove any non-digit characters
                final cleanNumber = value.replaceAll(RegExp(r'\D'), '');
                if (cleanNumber.length < 9) {
                  return 'رقم الهاتف غير صالح';
                }
                return null;
              },
            )
        : TextFormField(
            controller: controller,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              labelText: label,
              labelStyle: TextStyle(color: Colors.grey[600]),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2.0,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'الرجاء إدخال قيمة' : null,
          ),
    );
  }

  void _addDevice(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<DeviceCubit>().addDevice(
        _selectedModel ?? 'Unknown',
        _deviceNameController.text,
        _deviceNumberController.text,
        _passwordController.text,
      );
      Navigator.pop(context);
    }
  }
}
