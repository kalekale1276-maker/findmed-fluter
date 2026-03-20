import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/utils/tailwind_extensions.dart';
import '../widgets/branding_widgets.dart';

/// Login Page - User authentication
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandingWidgets.buildBrandHeader(
        title: 'Login',
        showBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Center(
        child: BrandingWidgets.buildEmptyState(
          message: 'Login Page',
          subtitle: 'Login functionality will be implemented here',
          icon: Icons.login,
        ),
      ),
    );
  }
}
