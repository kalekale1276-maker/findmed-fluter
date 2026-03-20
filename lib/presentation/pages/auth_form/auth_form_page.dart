import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';

class AuthFormPage extends StatelessWidget {
  const AuthFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication Form'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.app_registration,
                size: context.responsiveText2Xl,
                color: TailwindColors.medical500,
              ),
              SizedBox(height: context.responsiveGap),
              Text(
                'Authentication Form',
                style: TextStyle(
                  fontSize: context.responsiveTextLg,
                  fontWeight: FontWeight.bold,
                  color: TailwindColors.gray900,
                ),
              ),
              SizedBox(height: context.responsiveGapSm),
              Text(
                'Multi-step authentication process',
                style: TextStyle(
                  fontSize: context.responsiveText,
                  color: TailwindColors.gray600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
