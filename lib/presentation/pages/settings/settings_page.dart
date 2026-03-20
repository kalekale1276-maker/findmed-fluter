import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../shared/providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Card(
                child: Column(
                  children: [
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return ListTile(
                          leading: Icon(
                            themeProvider.isDarkMode
                                ? Icons.dark_mode
                                : themeProvider.isLightMode
                                    ? Icons.light_mode
                                    : Icons.brightness_auto,
                            color: AppColors.primary,
                          ),
                          title: const Text('Theme'),
                          subtitle: Text(_getThemeText(themeProvider.themeMode)),
                          trailing: DropdownButton<ThemeMode>(
                            value: themeProvider.themeMode,
                            onChanged: (ThemeMode? value) {
                              if (value != null) {
                                themeProvider.setThemeMode(value);
                              }
                            },
                            items: const [
                              DropdownMenuItem(
                                value: ThemeMode.light,
                                child: Text('Light'),
                              ),
                              DropdownMenuItem(
                                value: ThemeMode.dark,
                                child: Text('Dark'),
                              ),
                              DropdownMenuItem(
                                value: ThemeMode.system,
                                child: Text('System'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.language, color: AppColors.primary),
                      title: const Text('Language'),
                      subtitle: const Text('English'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // TODO: Implement language selection
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                      title: const Text('Notifications'),
                      subtitle: const Text('Enabled'),
                      trailing: Switch(
                        value: true, // TODO: Get from settings
                        onChanged: (value) {
                          // TODO: Toggle notifications
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                      title: const Text('Location Services'),
                      subtitle: const Text('While using app'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // TODO: Navigate to location settings
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock_outline, color: AppColors.primary),
                      title: const Text('Privacy'),
                      subtitle: const Text('Manage your privacy settings'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // TODO: Navigate to privacy settings
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.security_outlined, color: AppColors.primary),
                      title: const Text('Security'),
                      subtitle: const Text('Password and authentication'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // TODO: Navigate to security settings
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.help_outline, color: AppColors.primary),
                      title: const Text('Help & Support'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // TODO: Navigate to help
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: AppColors.primary),
                      title: const Text('About'),
                      subtitle: const Text('Version 1.0.0'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // TODO: Navigate to about
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getThemeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}
