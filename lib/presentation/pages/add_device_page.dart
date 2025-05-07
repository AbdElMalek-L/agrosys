import 'package:agrosys/presentation/cubits/device_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:intl_phone_field/intl_phone_field.dart'; // Ensure this is imported
import '../widgets/device_models_card.dart';
import '../widgets/header.dart';
import '../widgets/set_default_number_popup.dart'; // Import the new popup

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
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildDeviceForm(context),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => _addDevice(context),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.save, size: 22),
                      SizedBox(width: 8),
                      Text(
                        "إضافة جهاز",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: DeviceModelsCard(
                models: const ["RTU5024", "AGROS001", "MODEL003"],
                onModelSelected: (model) {
                  setState(() {
                    _selectedModel = model;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            _buildInputField(
              'اسم الجهاز',
              _deviceNameController,
              icon: Icons.devices,
            ),
            const SizedBox(height: 8),
            _buildInputField(
              'رقم الخاص بجهاز',
              _deviceNumberController,
              icon: Icons.phone_android,
              isPhone: true,
            ),
            const SizedBox(height: 8),
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
    final theme = Theme.of(context);
    final inputDecoration = InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
      ),
      prefixIcon:
          icon != null
              ? Icon(icon, color: theme.colorScheme.primary.withOpacity(0.7))
              : null,
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: theme.dividerColor, width: 1.0),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: theme.dividerColor.withOpacity(0.8),
          width: 1.0,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.error, width: 2.0),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );

    Widget inputFieldWidget;
    if (isPhone) {
      inputFieldWidget = Directionality(
        textDirection: TextDirection.ltr,
        child: IntlPhoneField(
          controller: controller,
          decoration: inputDecoration.copyWith(
            prefixIcon: Icon(
              Icons.phone_android,
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
          ),
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 16,
          ),
          initialCountryCode: 'MA',
          languageCode: 'ar',
          disableLengthCheck: true,
          onChanged: (phone) {
            controller.text = phone.number;
          },
          validator: (phone) {
            if (phone == null || phone.number.isEmpty) {
              return 'الرجاء إدخال رقم هاتف صحيح';
            }
            return null;
          },
        ),
      );
    } else {
      inputFieldWidget = TextFormField(
        controller: controller,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        decoration: inputDecoration,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 16),
        validator:
            (value) =>
                value == null || value.isEmpty ? 'الرجاء إدخال قيمة' : null,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Material(
        elevation: 1.0,
        shadowColor: Colors.black.withOpacity(0.1),
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        child: inputFieldWidget,
      ),
    );
  }

  void _addDevice(BuildContext context) async {
    // Keep track of mounted state before async operations
    final isMounted = context.mounted;
    if (!_formKey.currentState!.validate()) {
      return; // Don't proceed if form is invalid
    }

    // Add the country code to the phone number when saving
    String phoneNumberWithCountryCode = "+212${_deviceNumberController.text}";

    // Add the device using the cubit
    context.read<DeviceCubit>().addDevice(
      _selectedModel ?? 'Unknown',
      _deviceNameController.text,
      phoneNumberWithCountryCode,
      _passwordController.text,
    );

    // --- Show the popup AFTER adding device ---
    // Check mount status again before showing dialog
    if (isMounted) {
      // Pass device phone number and password to the popup
      await showSetDefaultNumberPopup(
        context,
        phoneNumberWithCountryCode, // Device phone number
        _passwordController.text, // Device password
        // (String number) { // Original callback removed, handled by SMS now
        //   print("Default number to save: $number");
        //   if (context.mounted) {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(
        //         content: Text('تم حفظ الرقم الافتراضي: $number'),
        //         backgroundColor: Colors.green,
        //       ),
        //     );
        //   }
        // }
      );
    }
    // --- End popup ---

    // Check mount status again before popping the main page navigator
    if (isMounted) {
      Navigator.pop(context); // Pop the AddDevicePage itself
    }
  }
}
