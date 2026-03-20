import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../app/constants/route_constants.dart';
import '../../../../core/utils/navigation_service.dart';
import '../../../../core/utils/tailwind_extensions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement login logic
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        NavigationService.pushReplacementNamed(RouteConstants.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDarkMode ? TailwindColors.gray900 : TailwindColors.gray50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.responsivePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: context.responsiveHeight),
                
                // Header with back button
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, 
                        color: context.isDarkMode ? Colors.white : TailwindColors.gray900),
                      ),
                    const Spacer(),
                  ],
                ),
                
                SizedBox(height: context.responsiveGap),
                
                // Welcome section
                if (context.isMobile)
                  Column(
                    children: [
                      Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: context.responsiveTextXl,
                          fontWeight: FontWeight.bold,
                          color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
                        ),
                      ),
                      SizedBox(height: context.responsiveGapSm),
                      Text(
                        'Sign in to continue',
                        style: TextStyle(
                          fontSize: context.responsiveText,
                          color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                        ),
                      ),
                    ],
                  ),
                
                SizedBox(height: context.responsiveGapLg),
                
                // Email field
                Container(
                  decoration: BoxDecoration(
                    color: context.isDarkMode ? TailwindColors.gray800 : Colors.white,
                    borderRadius: BorderRadius.circular(TailwindRadius.lg),
                    border: Border.all(
                      color: context.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray300,
                    ),
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
                      fontSize: context.responsiveText,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email_outlined, 
                        color: context.isDarkMode ? TailwindColors.gray400 : TailwindColors.gray500),
                      border: InputBorder.none,
                      labelStyle: TextStyle(
                        color: context.isDarkMode ? TailwindColors.gray300 : TailwindColors.gray500,
                      ),
                      hintStyle: TextStyle(
                        color: context.isDarkMode ? TailwindColors.gray500 : TailwindColors.gray400,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                
                SizedBox(height: context.responsiveGap),
                
                // Password field
                Container(
                  decoration: BoxDecoration(
                    color: context.isDarkMode ? TailwindColors.gray800 : Colors.white,
                    borderRadius: BorderRadius.circular(TailwindRadius.lg),
                    border: Border.all(
                      color: context.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray300,
                    ),
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(
                      color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
                      fontSize: context.responsiveText,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: context.isDarkMode ? TailwindColors.gray400 : TailwindColors.gray500),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                ),
                
                SizedBox(height: context.responsiveGapSm),
                
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: context.responsiveTextSm,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: context.responsiveGapLg),
                
                // Login button
                Container(
                  width: double.infinity,
                  height: context.isMobile ? 50.h : 56.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryVariant],
                    ),
                    borderRadius: BorderRadius.circular(TailwindRadius.lg),
                    boxShadow: [
                      TailwindShadows.md,
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoading ? null : _login,
                      borderRadius: BorderRadius.circular(TailwindRadius.lg),
                      child: Center(
                        child: _isLoading
                            ? SizedBox(
                                width: context.isMobile ? 18.w : 20.w,
                                height: context.isMobile ? 18.w : 20.w,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              )
                            : Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: context.responsiveText,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: context.responsiveGap),
                
                // Divider and social login
                Row(
                  children: [
                    Expanded(child: Divider(color: context.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray300)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.responsivePadding),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          fontSize: context.responsiveTextSm,
                          color: context.isDarkMode ? TailwindColors.gray400 : TailwindColors.gray500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: context.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray300)),
                  ],
                ),
                
                SizedBox(height: context.responsiveGap),
                
                // Google Sign In button
                Container(
                  width: double.infinity,
                  height: context.isMobile ? 50.h : 56.h,
                  decoration: BoxDecoration(
                    color: context.isDarkMode ? TailwindColors.gray800 : Colors.white,
                    borderRadius: BorderRadius.circular(TailwindRadius.lg),
                    border: Border.all(
                      color: context.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray300,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // TODO: Implement Google Sign-In
                      },
                      borderRadius: BorderRadius.circular(TailwindRadius.lg),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.g_mobiledata, 
                            color: context.isDarkMode ? TailwindColors.gray300 : TailwindColors.gray700),
                          SizedBox(width: context.responsiveGapSm),
                          Text(
                            'Sign in with Google',
                            style: TextStyle(
                              color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
                              fontSize: context.responsiveText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: context.responsiveGap),
                
                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        fontSize: context.responsiveTextSm,
                        color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        NavigationService.pushNamed(RouteConstants.register);
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: context.responsiveTextSm,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
