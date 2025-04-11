import 'package:flutter/material.dart';

class RecentActivityWidget extends StatelessWidget {
  const RecentActivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text("سجل الأنشطة الأخيرة", style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
