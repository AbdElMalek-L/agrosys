import 'package:flutter/material.dart';

class CategoryHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;

  const CategoryHeader({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(width: 8),
          Icon(icon, color: iconColor ?? colorScheme.primary, size: 22),
        ],
      ),
    );
  }
}
