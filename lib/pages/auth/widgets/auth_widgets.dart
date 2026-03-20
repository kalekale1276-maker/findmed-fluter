import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../models/auth_models.dart';
import '../services/auth_services.dart';

/// UI components for authentication forms
class AuthWidgets {
  /// Build error message container
  static Widget buildErrorContainer(String message, {bool isCredential = false}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: TailwindColors.red50,
        border: Border.all(color: TailwindColors.red200),
        borderRadius: BorderRadius.circular(TailwindRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: TailwindColors.red500, size: 20.w),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: TailwindColors.red500,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build text form field with consistent styling
  static Widget buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required BuildContext context,
    String? hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    VoidCallback? onChanged,
  }) {
    final inputFill = Theme.of(context).colorScheme.onSurface.withAlpha((0.03 * 255).toInt());
    
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: inputFill,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
        labelStyle: TextStyle(
          fontSize: 14.sp,
          color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
        ),
      ),
      style: TextStyle(
        fontSize: 15.sp,
        color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
      ),
    );
  }

  /// Build email field with checking indicator
  static Widget buildEmailField({
    required TextEditingController controller,
    required BuildContext context,
    required bool isChecking,
    required EmailCheckResult? result,
    required VoidCallback onEmailChanged,
  }) {
    return Column(
      children: [
        buildTextFormField(
          controller: controller,
          labelText: 'Email',
          context: context,
          validator: AuthServices.validateEmail,
          suffixIcon: Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: SizedBox(
              width: 24.w,
              height: 24.w,
              child: Center(
                child: isChecking
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : (result?.exists == true
                        ? Icon(Icons.check_circle, color: Colors.green, size: 18.w)
                        : (result?.exists == false
                            ? Icon(Icons.cancel, color: Colors.red, size: 18.w)
                            : const SizedBox.shrink())),
              ),
            ),
          ),
        ),
        SizedBox(height: 6.h),
        _buildEmailStatusIndicator(isChecking: isChecking, result: result),
      ],
    );
  }

  /// Build email status indicator
  static Widget _buildEmailStatusIndicator({
    required bool isChecking,
    required EmailCheckResult? result,
  }) {
    if (isChecking) {
      return const Row(children: [
        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
        SizedBox(width: 8),
        Text('Checking email...')
      ]);
    } else if (result?.exists == true) {
      return Row(children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            result?.note ?? 'Email registered',
            style: const TextStyle(color: Colors.green),
          ),
        ),
      ]);
    } else if (result?.exists == false) {
      return const Row(children: [
        Icon(Icons.error, color: Colors.red, size: 16),
        SizedBox(width: 8),
        Expanded(
          child: Text('Email not registered', style: TextStyle(color: Colors.red)),
        ),
      ]);
    }
    return const SizedBox.shrink();
  }

  /// Build password field with visibility toggle
  static Widget buildPasswordField({
    required TextEditingController controller,
    required BuildContext context,
    bool isVisible = false,
    VoidCallback? onVisibilityChanged,
    String? Function(String?)? validator,
  }) {
    return buildTextFormField(
      controller: controller,
      labelText: 'Password',
      context: context,
      obscureText: !isVisible,
      validator: validator,
      suffixIcon: IconButton(
        icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
        onPressed: onVisibilityChanged,
      ),
    );
  }

  /// Build password strength indicator
  static Widget buildPasswordStrengthIndicator(PasswordStrength strength) {
    if (strength.label.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: EdgeInsets.only(top: 4.h, left: 4.w),
      child: Text(
        'Password strength: ${strength.label}',
        style: TextStyle(
          color: strength.color,
          fontSize: 13.sp,
        ),
      ),
    );
  }

  /// Build country code dropdown
  static Widget buildCountryCodeDropdown({
    required CountryCode selectedCode,
    required ValueChanged<CountryCode?> onChanged,
  }) {
    return DropdownButton<CountryCode>(
      value: selectedCode,
      items: AuthServices.getCountryCodes().map((code) => 
        DropdownMenuItem(value: code, child: Text('${code.flag} ${code.code}'))
      ).toList(),
      onChanged: onChanged,
      underline: const SizedBox(),
      icon: const SizedBox(),
    );
  }

  /// Build phone input row
  static Widget buildPhoneInputRow({
    required TextEditingController phoneController,
    required CountryCode selectedCode,
    required ValueChanged<CountryCode?> onCountryCodeChanged,
    required BuildContext context,
  }) {
    return Row(
      children: [
        buildCountryCodeDropdown(
          selectedCode: selectedCode,
          onChanged: onCountryCodeChanged,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: buildTextFormField(
            controller: phoneController,
            labelText: 'Phone number',
            context: context,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
            validator: AuthServices.validatePhone,
          ),
        ),
      ],
    );
  }

  /// Build submit button
  static Widget buildSubmitButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isLoading,
    double? height,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size.fromHeight(height ?? 44.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        backgroundColor: Theme.of(Get.context!).primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
      ),
      onPressed: onPressed,
      child: isLoading
          ? SizedBox(
              width: 16.w,
              height: 16.w,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  /// Build navigation button
  static Widget buildNavigationButton({
    required String text,
    required VoidCallback? onPressed,
    bool isPrimary = true,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: isPrimary 
            ? Theme.of(Get.context!).primaryColor 
            : Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }

  /// Build form spacing
  static Widget buildSpacing({double height = 12}) {
    return SizedBox(height: height.h);
  }

  /// Build age field
  static Widget buildAgeField({
    required TextEditingController controller,
    required BuildContext context,
  }) {
    return buildTextFormField(
      controller: controller,
      labelText: 'Age',
      context: context,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: AuthServices.validateAge,
    );
  }

  /// Build name field
  static Widget buildNameField({
    required TextEditingController controller,
    required BuildContext context,
  }) {
    return buildTextFormField(
      controller: controller,
      labelText: 'Full name',
      context: context,
      validator: AuthServices.validateName,
    );
  }

  /// Build confirm password field
  static Widget buildConfirmPasswordField({
    required TextEditingController controller,
    required String password,
    required BuildContext context,
  }) {
    return buildTextFormField(
      controller: controller,
      labelText: 'Confirm password',
      context: context,
      obscureText: true,
      validator: (v) => AuthServices.validateConfirmPassword(password, v),
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
