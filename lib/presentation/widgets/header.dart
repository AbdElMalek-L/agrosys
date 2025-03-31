import 'package:flutter/material.dart';

// TODO: Improve the style

class Header extends StatelessWidget {
  const Header({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xff009200),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
