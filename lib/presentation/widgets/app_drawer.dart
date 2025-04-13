import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/theme_cubit.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Center(
                child: Image.asset(
                  'assets/icon/icon.png',
                  width: 100,
                  height: 100,
                  color: Colors.white,
                ),
              ),
            ),
            BlocBuilder<ThemeCubit, bool>(
              builder: (context, isDarkMode) {
                return SwitchListTile(
                  title: const Text('الوضع الداكن'),
                  value: isDarkMode,
                  onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
                  secondary: Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.info,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('حول التطبيق'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'AgroSys',
                  applicationVersion: '1.0.0',
                  applicationIcon: Image.asset(
                    'assets/icon/icon.png',
                    width: 50,
                    height: 50,
                  ),
                  children: [
                    const Text(
                      'تطبيق للتحكم في أنظمة الري عن بعد باستخدام الرسائل القصيرة.',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '© 2024 AgroSys',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}