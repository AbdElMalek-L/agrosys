import 'package:flutter/material.dart';

// Callback type for when the user confirms and saves the number
typedef SaveNumberCallback = void Function(String phoneNumber);

/// Shows the 'Set Default Number' dialog.
///
/// [context]: The build context to show the dialog in.
/// [onSave]: The callback function to execute when the user saves the number.
Future<void> showSetDefaultNumberPopup(
  BuildContext context,
  SaveNumberCallback onSave,
) async {
  // Ensure the context is still mounted before showing the dialog
  if (!context.mounted) return;

  await showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside initially
    builder: (BuildContext dialogContext) {
      // Pass the context and callback to the stateful dialog widget
      return SetDefaultNumberDialog(onSave: onSave);
    },
  );
}

/// The stateful widget for the dialog content.
class SetDefaultNumberDialog extends StatefulWidget {
  final SaveNumberCallback onSave;

  const SetDefaultNumberDialog({super.key, required this.onSave});

  @override
  _SetDefaultNumberDialogState createState() => _SetDefaultNumberDialogState();
}

class _SetDefaultNumberDialogState extends State<SetDefaultNumberDialog> {
  bool _showInput = false;
  final TextEditingController _numberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  // Handles saving the number
  void _saveNumber() {
    // Validate the input field
    if (_formKey.currentState?.validate() ?? false) {
      // Call the provided callback with the entered number
      widget.onSave(_numberController.text);
      // Close the dialog using the correct context
      Navigator.of(context).pop();
    }
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
                  child: const Text('حفظ الرقم'),
                  onPressed: _saveNumber,
                ),
              ],
    );
  }
}
