import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../models/login_models.dart';
import '../services/login_services.dart';

/// UI components for login functionality
class LoginWidgets {
  /// Build login card
  static Widget buildLoginCard({
    required Widget child,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: LoginConstants.cardMaxWidth),
        child: Card(
          elevation: LoginConstants.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LoginConstants.cardBorderRadius),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  /// Build login header
  static Widget buildHeader({
    String title = LoginConstants.signInTitle,
    String subtitle = '',
  }) {
    return Column(
      children: [
        Icon(
          Icons.login,
          size: 48.w,
          color: Theme.of(Get.context!).colorScheme.primary,
        ),
        SizedBox(height: 12.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
          ),
        ],
      ],
    );
  }

  /// Build email field
  static Widget buildEmailField({
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: LoginConstants.emailLabel,
        hintText: LoginConstants.emailHint,
        prefixIcon: Icon(Icons.email_outlined, size: 20.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          borderSide: BorderSide(
            color: Get.context!.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          borderSide: BorderSide(
            color: Theme.of(Get.context!).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: validator,
      style: TextStyle(
        fontSize: 15.sp,
        color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
      ),
    );
  }

  /// Build password field
  static Widget buildPasswordField({
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool isVisible = false,
    bool enabled = true,
    required VoidCallback onVisibilityToggle,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: LoginConstants.passwordLabel,
        hintText: LoginConstants.passwordHint,
        prefixIcon: Icon(Icons.lock_outline, size: 20.w),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            size: 20.w,
            color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
          ),
          onPressed: onVisibilityToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          borderSide: BorderSide(
            color: Get.context!.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          borderSide: BorderSide(
            color: Theme.of(Get.context!).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
      validator: validator,
      style: TextStyle(
        fontSize: 15.sp,
        color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
      ),
    );
  }

  /// Build remember me checkbox
  static Widget buildRememberMeCheckbox({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(Get.context!).colorScheme.primary,
        ),
        Text(
          LoginConstants.rememberMeLabel,
          style: TextStyle(
            fontSize: 14.sp,
            color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray700,
          ),
        ),
      ],
    );
  }

  /// Build forgot password link
  static Widget buildForgotPasswordLink({
    required VoidCallback onTap,
  }) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onTap,
        child: Text(
          LoginConstants.forgotPasswordLabel,
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(Get.context!).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Build login button
  static Widget buildLoginButton({
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isValid = false,
    String label = LoginConstants.loginButtonLabel,
  }) {
    return Container(
      width: double.infinity,
      height: 48.h,
      margin: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        gradient: isValid
            ? LinearGradient(
                colors: [
                  Theme.of(Get.context!).colorScheme.primary,
                  Theme.of(Get.context!).colorScheme.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isValid ? null : Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray300,
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        boxShadow: isValid
            ? [
                BoxShadow(
                  color: Theme.of(Get.context!).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isValid && !isLoading ? onPressed : null,
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isValid ? Colors.white : (Get.context!.isDarkMode ? Colors.white54 : TailwindColors.gray500),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// Build social login buttons
  static Widget buildSocialLoginButtons({
    required List<SocialLoginProvider> providers,
    required Function(String) onProviderTap,
  }) {
    if (providers.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDivider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'OR',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                ),
              ),
            ),
            Expanded(child: _buildDivider()),
          ],
        ),
        SizedBox(height: 16.h),
        ...providers.map((provider) => 
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildSocialLoginButton(
              provider: provider,
              onTap: () => onProviderTap(provider.id),
            ),
          ),
        ),
      ],
    );
  }

  /// Build divider
  static Widget _buildDivider() {
    return Container(
      height: 1.h,
      color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray300,
    );
  }

  /// Build social login button
  static Widget _buildSocialLoginButton({
    required SocialLoginProvider provider,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 44.h,
      decoration: BoxDecoration(
        color: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray300,
        ),
        boxShadow: [TailwindShadows.sm],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  provider.icon,
                  size: 20.w,
                  color: provider.color,
                ),
                SizedBox(width: 12.w),
                Text(
                  provider.label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build alternative actions
  static Widget buildAlternativeActions({
    required bool showRegister,
    required bool showGuest,
    required VoidCallback onRegisterTap,
    required VoidCallback onGuestTap,
  }) {
    return Column(
      children: [
        if (showRegister) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                LoginConstants.noAccountText,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                ),
              ),
              TextButton(
                onPressed: onRegisterTap,
                child: Text(
                  LoginConstants.signUpText,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(Get.context!).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (showGuest) ...[
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            height: 44.h,
            decoration: BoxDecoration(
              color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray100,
              borderRadius: BorderRadius.circular(TailwindRadius.lg),
              border: Border.all(
                color: Get.context!.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray300,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onGuestTap,
                borderRadius: BorderRadius.circular(TailwindRadius.lg),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 20.w,
                        color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        LoginConstants.guestButtonLabel,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Build features showcase
  static Widget buildFeaturesShowcase({
    required List<LoginFeature> features,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: Theme.of(Get.context!).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why Choose FindMed?',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          SizedBox(height: 12.h),
          ...features.map((feature) => 
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: feature.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      feature.icon,
                      size: 16.w,
                      color: feature.color,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          feature.description,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build error message
  static Widget buildErrorMessage(String error) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: TailwindColors.red50,
        borderRadius: BorderRadius.circular(TailwindRadius.md),
        border: Border.all(color: TailwindColors.red200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: TailwindColors.red500,
            size: 20.w,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: TailwindColors.red500,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build success message
  static Widget buildSuccessMessage(String message) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: TailwindColors.green50,
        borderRadius: BorderRadius.circular(TailwindRadius.md),
        border: Border.all(color: TailwindColors.green200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: TailwindColors.green500,
            size: 20.w,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: TailwindColors.green500,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build loading indicator
  static Widget buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(Get.context!).colorScheme.primary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Signing in...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build spacing
  static Widget buildSpacing({double height = 16}) {
    return SizedBox(height: height.h);
  }

  /// Build section divider
  static Widget buildSectionDivider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.h),
      height: 1.h,
      color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
    );
  }
}

/// Helper class to get context
class Get {
  static BuildContext? _context;
  
  static BuildContext get context {
    if (_context == null) {
      throw Exception('Context not set. Call setContext() first.');
    }
    return _context!;
  }
  
  static void setContext(BuildContext context) {
    _context = context;
  }
  
  static void clearContext() {
    _context = null;
  }
}
