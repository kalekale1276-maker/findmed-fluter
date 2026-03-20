import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/utils/tailwind_extensions.dart';
import '../widgets/branding_widgets.dart';

/// Register Page - User registration
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandingWidgets.buildBrandHeader(
        title: 'Register',
        showBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Center(
        child: BrandingWidgets.buildEmptyState(
          message: 'Register Page',
          subtitle: 'Registration functionality will be implemented here',
          icon: Icons.app_registration,
        ),
      ),
    );
  }
}
