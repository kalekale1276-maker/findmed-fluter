import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.login,
                size: context.responsiveText2Xl,
                color: TailwindColors.medical500,
              ),
              SizedBox(height: context.responsiveGap),
              Text(
                'Login Page',
                style: TextStyle(
                  fontSize: context.responsiveTextLg,
                  fontWeight: FontWeight.bold,
                  color: TailwindColors.gray900,
                ),
              ),
              SizedBox(height: context.responsiveGapSm),
              Text(
                'Sign in to your account',
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
