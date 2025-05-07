import 'package:agrosys/controllers/sms_controller.dart'; // Import SMSController
import 'package:flutter/material.dart';

// Callback type for when the user confirms and saves the number
// typedef SaveNumberCallback = void Function(String phoneNumber); // Keep if needed elsewhere, but not used here

/// Shows the 'Set Default Number' dialog.
///
/// [context]: The build context to show the dialog in.
/// [devicePhoneNumber]: The phone number of the device to send the command to.
/// [devicePassword]: The password of the device for the command.
/// [onSave]: The callback function to execute when the user saves the number.
Future<void> showSetDefaultNumberPopup(
  BuildContext context,
  String devicePhoneNumber,
  String devicePassword,
  // SaveNumberCallback onSave, // Remove onSave if only SMS is needed
) async {
  // Ensure the context is still mounted before showing the dialog
  if (!context.mounted) return;

  await showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside initially
    builder: (BuildContext dialogContext) {
      // Pass the context and necessary device info to the stateful dialog widget
      return SetDefaultNumberDialog(
        devicePhoneNumber: devicePhoneNumber,
        devicePassword: devicePassword,
        // onSave: onSave, // Pass if needed
      );
    },
  );
}

/// The stateful widget for the dialog content.
class SetDefaultNumberDialog extends StatefulWidget {
  // final SaveNumberCallback onSave;
  final String devicePhoneNumber;
  final String devicePassword;

  const SetDefaultNumberDialog({
    super.key,
    required this.devicePhoneNumber,
    required this.devicePassword,
    // required this.onSave,
  });

  @override
  _SetDefaultNumberDialogState createState() => _SetDefaultNumberDialogState();
}

class _SetDefaultNumberDialogState extends State<SetDefaultNumberDialog> {
  bool _showInput = false;
  final TextEditingController _numberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final SMSController _smsController =
      SMSController(); // Instantiate SMS controller

  @override
  void dispose() {
    _numberController.dispose();
    _smsController.dispose(); // Dispose SMS controller
    super.dispose();
  }

  // Handles sending the SMS command
  void _sendSetDefaultNumberCommand() {
    // Validate the input field
    if (!(_formKey.currentState?.validate() ?? false)) {
      return; // Don't proceed if invalid
    }

    final String defaultNumberEntered = _numberController.text;
    // Remove '+' if present for the command string
    final String numberForCommand =
        defaultNumberEntered.startsWith('+')
            ? defaultNumberEntered.substring(1)
            : defaultNumberEntered;

    // Construct the command
    final String command =
        "${widget.devicePassword}#TEL00$numberForCommand#001#";

    // Use the context available in the state
    final currentContext = context;

    // Close the dialog first
    Navigator.of(currentContext).pop();

    // Send the command using the *device's* phone number
    _smsController.sendCommandWithResponse(
      context: currentContext, // Pass the captured context
      phoneNumber: widget.devicePhoneNumber,
      command: command,
      onMessage: (message) {
        // Show intermediate messages if needed (e.g., "Sending SMS...")
        if (currentContext.mounted) {
          // Check mount status before showing snackbar
          ScaffoldMessenger.of(currentContext).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      onResult: (success, response) {
        if (!currentContext.mounted) return; // Check mount status again
        // Show final result
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'تم تعيين الرقم الافتراضي بنجاح ${response != null ? "($response)" : ""}'
                  : 'فشل تعيين الرقم الافتراضي',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        // Optionally call the original onSave callback if it was kept and needed
        // if(success) { widget.onSave(defaultNumberEntered); }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      title: Text(
        !_showInput ? 'تعيين رقم افتراضي؟' : 'أدخل الرقم الافتراضي',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          fontSize: 18,
        ),
      ),
      content: SingleChildScrollView(
        // Prevents overflow if keyboard appears
        child:
            !_showInput
                ? const Text(
                  'هل ترغب في تعيين رقم هاتف افتراضي للتحكم السريع بالجهاز؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                )
                : Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _numberController,
                    keyboardType: TextInputType.phone,
                    // Consider using IntlPhoneField for better UX if needed later
                    decoration: InputDecoration(
                      hintText: '+212XXXXXXXXX',
                      prefixIcon: Icon(
                        Icons.phone,
                        color: theme.colorScheme.primary.withOpacity(0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: theme.dividerColor.withOpacity(0.8),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 15,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال رقم هاتف';
                      }
                      // Basic validation - enhance if needed (e.g., regex for +212 format)
                      if (!value.startsWith('+212') || value.length < 13) {
                        return 'الرجاء إدخال رقم مغربي صحيح (+212...)';
                      }
                      return null;
                    },
                  ),
                ),
      ),
      actionsAlignment: MainAxisAlignment.spaceAround, // Space out buttons
      actionsPadding: const EdgeInsets.only(
        bottom: 10.0,
        left: 10.0,
        right: 10.0,
      ),
      actions:
          !_showInput
              ? [
                // Actions for the initial question
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: theme.textTheme.bodySmall?.color,
                  ),
                  child: const Text('لاحقا'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('نعم'),
                  onPressed: () => setState(() => _showInput = true),
                ),
              ]
              : [
                // Actions for the input field
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: theme.textTheme.bodySmall?.color,
                  ),
                  child: const Text('إلغاء'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _sendSetDefaultNumberCommand,
                  child: const Text(
                    'حفظ الرقم',
                  ), // Call the new SMS sending function
                ),
              ],
    );
  }
}
