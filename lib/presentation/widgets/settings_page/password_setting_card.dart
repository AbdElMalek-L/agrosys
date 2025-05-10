import 'package:flutter/material.dart';

class PasswordSettingCard extends StatelessWidget {
  final String title;
  final TextEditingController oldPasswordController;
  final TextEditingController newPasswordController;
  final VoidCallback onUpdatePassword;
  final String? Function(String?)? validator;
  final TextAlign textAlign;

  const PasswordSettingCard({
    super.key,
    required this.title,
    required this.oldPasswordController,
    required this.newPasswordController,
    required this.onUpdatePassword,
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
            const SizedBox(height: 20),
            TextFormField(
              controller: oldPasswordController,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور القديمة',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
              validator: validator,
              textAlign: textAlign,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
              validator: validator,
              textAlign: textAlign,
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                onPressed: onUpdatePassword,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
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
