import 'package:flutter/material.dart';

/// A simple widget to display a styled header text.
///
/// Uses the primary color from the current theme.
class Header extends StatelessWidget {
  /// The text content of the header.
  final String title;

  /// Creates a Header widget.
  const Header({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // Use the primary color from the theme for consistency
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Text(
      title,
      style: TextStyle(
        color: primaryColor, // Use theme color
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
