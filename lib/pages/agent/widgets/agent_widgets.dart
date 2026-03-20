import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../state/agent_state_manager.dart';

/// UI components for agent functionality
class AgentWidgets {
  // Main app bar
  static PreferredSizeWidget buildAppBar(BuildContext context, AgentStateManager state) {
    return AppBar(
      title: Text(
        'Agent Portal',
        style: TextStyle(
          fontSize: context.responsiveTextLg,
          fontWeight: FontWeight.bold,
          color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
        ),
      ),
      backgroundColor: context.isDarkMode ? TailwindColors.gray800 : Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(
        color: context.isDarkMode ? Colors.white : TailwindColors.gray700,
        size: context.isMobile ? 22.w : 24.w,
      ),
      actions: [
        if (state.facilityId != null)
          Container(
            margin: EdgeInsets.only(right: context.responsivePadding),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.badge,
                  size: context.isMobile ? 18.w : 20.w,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: context.responsiveGapSm),
                Text(
                  'ID: ${state.facilityId}',
                  style: TextStyle(
                    fontSize: context.responsiveTextSm,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Header section
  static Widget buildHeaderSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.responsivePadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(TailwindRadius.xl),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.local_hospital,
            size: context.isMobile ? 48.w : 56.w,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(height: context.responsiveGap),
          Text(
            'Healthcare Facility Portal',
            style: TextStyle(
              fontSize: context.responsiveTextXl,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveGapSm),
          Text(
            'Register or manage your healthcare facility',
            style: TextStyle(
              fontSize: context.responsiveText,
              color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Choice card
  static Widget buildChoiceCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: context.isMobile ? 400.w : 500.w),
      child: Material(
        elevation: TailwindShadows.md[0],
        borderRadius: BorderRadius.circular(TailwindRadius.xl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TailwindRadius.xl),
          child: Container(
            padding: EdgeInsets.all(context.responsivePaddingLg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TailwindRadius.xl),
              gradient: isPrimary
                  ? LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isPrimary
                  ? null
                  : context.isDarkMode
                      ? TailwindColors.gray800
                      : Colors.white,
              border: Border.all(
                color: isPrimary
                    ? Colors.transparent
                    : context.isDarkMode
                        ? TailwindColors.gray700
                        : TailwindColors.gray200,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(context.responsivePadding),
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? Colors.white.withOpacity(0.2)
                        : Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(TailwindRadius.lg),
                  ),
                  child: Icon(
                    icon,
                    size: context.isMobile ? 32.w : 40.w,
                    color: isPrimary
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: context.responsiveGap),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: context.responsiveTextLg,
                    fontWeight: FontWeight.bold,
                    color: isPrimary
                        ? Colors.white
                        : context.isDarkMode
                            ? Colors.white
                            : TailwindColors.gray900,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.responsiveGapSm),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: context.responsiveTextSm,
                    color: isPrimary
                        ? Colors.white70
                        : context.isDarkMode
                            ? Colors.white70
                            : TailwindColors.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Form card
  static Widget buildFormCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.responsivePaddingLg),
      decoration: BoxDecoration(
        color: context.isDarkMode ? TailwindColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(TailwindRadius.xl),
        boxShadow: [TailwindShadows.lg],
        border: Border.all(
          color: context.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: context.responsiveTextXl,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          SizedBox(height: context.responsiveGapSm),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: context.responsiveTextSm,
              color: context.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
          ),
          SizedBox(height: context.responsiveGapLg),
          child,
        ],
      ),
    );
  }

  // Text form field
  static Widget buildTextFormField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(
        fontSize: context.responsiveText,
        color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          size: context.isMobile ? 20.w : 22.w,
          color: context.isDarkMode ? Colors.white70 : TailwindColors.gray500,
        ),
        labelStyle: TextStyle(
          fontSize: context.responsiveTextSm,
          color: context.isDarkMode ? Colors.white70 : TailwindColors.gray500,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          borderSide: BorderSide(
            color: context.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          borderSide: BorderSide(color: TailwindColors.red500),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          borderSide: BorderSide(color: TailwindColors.red500, width: 2),
        ),
        filled: true,
        fillColor: context.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray50,
      ),
    );
  }

  // Choice chip
  static Widget buildChoiceChip({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onSelected,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => onSelected(!selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: context.responsivePadding,
          vertical: context.responsivePaddingSm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).primaryColor
              : context.isDarkMode
                  ? TailwindColors.gray700
                  : TailwindColors.gray100,
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          border: Border.all(
            color: selected
                ? Theme.of(context).primaryColor
                : context.isDarkMode
                    ? TailwindColors.gray600
                    : TailwindColors.gray300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: context.isMobile ? 18.w : 20.w,
              color: selected
                  ? Colors.white
                  : context.isDarkMode
                      ? Colors.white70
                      : TailwindColors.gray600,
            ),
            SizedBox(width: context.responsiveGapSm),
            Text(
              label,
              style: TextStyle(
                fontSize: context.responsiveTextSm,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : context.isDarkMode
                        ? Colors.white70
                        : TailwindColors.gray700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Submit button
  static Widget buildSubmitButton({
    required BuildContext context,
    required String text,
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return Container(
      height: context.isMobile ? 48.h : 56.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: context.isMobile ? 20.w : 24.w,
                    height: context.isMobile ? 20.w : 24.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: context.responsiveText,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // Message widget
  static Widget buildMessageWidget({
    required BuildContext context,
    required String message,
    required bool isError,
  }) {
    return Container(
      padding: EdgeInsets.all(context.responsivePadding),
      decoration: BoxDecoration(
        color: isError 
            ? TailwindColors.red50 
            : TailwindColors.green50,
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: isError 
              ? TailwindColors.red200 
              : TailwindColors.green200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            size: context.isMobile ? 18.w : 20.w,
            color: isError 
                ? TailwindColors.red600 
                : TailwindColors.green600,
          ),
          SizedBox(width: context.responsiveGapSm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: context.responsiveTextSm,
                color: isError 
                    ? TailwindColors.red800 
                    : TailwindColors.green800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Back button
  static Widget buildBackButton({
    required BuildContext context,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        '← Back',
        style: TextStyle(
          fontSize: context.responsiveText,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
