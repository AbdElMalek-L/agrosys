import 'package:agrosys/presentation/cubits/device_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:intl_phone_field/intl_phone_field.dart'; // Ensure this is imported
import '../widgets/device_models_card.dart';
import '../widgets/header.dart';

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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
            _buildInputField(
              'اسم الجهاز',
              _deviceNameController,
              icon: Icons.devices,
            ),
            _buildInputField(
              'رقم الخاص بجهاز',
              _deviceNumberController,
              icon: Icons.phone_android,
              isPhone: true, // Use IntlPhoneField for this one
            ),
            _buildInputField(
              'الرقم السري',
              _passwordController,
              icon: Icons.lock,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    bool isPhone = false,
  }) {
    if (isPhone) {
      // Use IntlPhoneField for phone number input
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: IntlPhoneField(
          controller: controller, // Provide the controller
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            prefixIcon: icon != null ? Icon(icon) : null,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
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
          initialCountryCode: 'MA', // Default country code
          languageCode: 'ar', // Set language if needed for country names
          disableLengthCheck: true, // Disable internal length check
          // keyboardType: TextInputType.phone, // Remove explicit keyboard type
          onChanged: (phone) {
            // Reinstate onChanged to update controller
            controller.text = phone.completeNumber;
          },
          validator: (phone) {
            // Validate using the phone object
            if (phone == null || phone.number.isEmpty) {
              return 'الرجاء إدخال رقم هاتف صحيح'; // Please enter a valid phone number
            }
            return null;
          },
        ),
      );
    } else {
      // Use standard TextFormField for other inputs
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: TextFormField(
          controller: controller,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            prefixIcon: icon != null ? Icon(icon) : null,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
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
          validator:
              (value) =>
                  value == null || value.isEmpty ? 'الرجاء إدخال قيمة' : null,
        ),
      );
    }
  }

  void _addDevice(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Ensure the controller text is used when adding the device
      context.read<DeviceCubit>().addDevice(
        _selectedModel ?? 'Unknown',
        _deviceNameController.text,
        _deviceNumberController.text, // Use the controller's text
        _passwordController.text,
      );
      Navigator.pop(context);
    }
  }
}
