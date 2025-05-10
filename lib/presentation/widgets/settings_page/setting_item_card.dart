import 'package:flutter/material.dart';

class SettingItemCard extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final VoidCallback onPressed;
  final IconData? icon;
  final String? Function(String?)? validator;
  final TextAlign textAlign;

  const SettingItemCard({
    super.key,
    required this.title,
    required this.controller,
    this.keyboardType,
    required this.onPressed,
    this.icon,
    this.validator,
    this.textAlign = TextAlign.right,
  });

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
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                prefixIcon: Icon(icon),
                alignLabelWithHint: true,
              ),
              validator: validator,
              keyboardType: keyboardType,
              textAlign: textAlign,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                onPressed: onPressed,
                child: const Text('تحديث'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
