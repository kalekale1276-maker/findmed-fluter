import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/utils/tailwind_extensions.dart';
import '../core/utils/app_assets.dart';

/// Branding and Loading Widgets - Comprehensive logo and loading system
class BrandingWidgets {
  /// App Logo Widget - Responsive logo with theme support
  static Widget buildAppLogo({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    VoidCallback? onTap,
    bool showShadow = false,
  }) {
    Widget logo = AppAssets.getLogo(
      width: width ?? 120,
      height: height ?? 40,
      fit: fit,
    );

    if (showShadow) {
      logo = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: logo,
      );
    }

    if (onTap != null) {
      logo = GestureDetector(
        onTap: onTap,
        child: logo,
      );
    }

    return logo;
  }

  /// App Logo Icon Widget - Small logo icon
  static Widget buildAppLogoIcon({
    double? size,
    Color? color,
    VoidCallback? onTap,
  }) {
    Widget icon = AppAssets.getLogoIcon(
      size: size ?? 40,
      color: color,
    );

    if (onTap != null) {
      icon = GestureDetector(
        onTap: onTap,
        child: icon,
      );
    }

    return icon;
  }

  /// Loading Animation Widget - Animated loading with branding
  static Widget buildLoadingAnimation({
    double? width,
    double? height,
    String? message,
    bool showLogo = true,
    Color? backgroundColor,
  }) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLogo) ...[
            AppAssets.getLogo(width: 80, height: 30),
            SizedBox(height: 24.h),
          ],
          AppAssets.getLoadingAnimation(width: 60, height: 60),
          if (message != null) ...[
            SizedBox(height: 16.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Full Screen Loading Widget - Full page loading with branding
  static Widget buildFullScreenLoading({
    String? message,
    bool showProgress = false,
    double? progress,
    Color? backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            backgroundColor?.withOpacity(0.95) ?? Colors.white.withOpacity(0.95),
            backgroundColor?.withOpacity(0.98) ?? Colors.grey[50]!.withOpacity(0.98),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo at top
          AppAssets.getSplashScreen(width: 200, height: 200),
          
          SizedBox(height: 48.h),
          
          // Loading animation
          AppAssets.getLoadingAnimation(width: 80, height: 80),
          
          SizedBox(height: 24.h),
          
          // Loading message
          Text(
            message ?? 'Loading...',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          
          if (showProgress && progress != null) ...[
            SizedBox(height: 16.h),
            Container(
              width: 200.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(2.r),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Splash Screen Widget - App splash screen with branding
  static Widget buildSplashScreen({
    VoidCallback? onComplete,
    Duration duration = const Duration(seconds: 3),
  }) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade600,
              Colors.blue.shade800,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Main logo
            Hero(
              tag: 'app_logo',
              child: AppAssets.getLogo(width: 150, height: 50),
            ),
            
            SizedBox(height: 32.h),
            
            // App name
            Text(
              'FindMed Ethiopia',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            
            SizedBox(height: 8.h),
            
            // Tagline
            Text(
              'Healthcare at your fingertips',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white70,
                letterSpacing: 0.5,
              ),
            ),
            
            SizedBox(height: 64.h),
            
            // Loading animation
            AppAssets.getLoadingAnimation(width: 60, height: 60),
            
            SizedBox(height: 16.h),
            
            // Loading text
            Text(
              'Initializing...',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Brand Header Widget - Header with logo and title (for AppBar usage)
  static PreferredSizeWidget buildBrandHeader({
    required String title,
    String? subtitle,
    bool showBackButton = false,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return PreferredSize(
      preferredSize: Size.fromHeight(60.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            if (showBackButton)
              Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBackPressed,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: textColor ?? Colors.black87,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: textColor ?? Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            if (actions != null) ...actions,
          ],
        ),
      ),
    );
  }

  /// Brand Header Widget - Header with logo and title (for regular widget usage)
  static Widget buildBrandHeaderWidget({
    required String title,
    String? subtitle,
    bool showBackButton = false,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (showBackButton)
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBackPressed,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor ?? Colors.black87,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: textColor ?? Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          if (actions != null) ...actions,
        ],
      ),
    );
  }

  /// Emergency Branding Widget - Emergency page specific branding
  static Widget buildEmergencyBranding({
    String title = 'Emergency Services',
    String? subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade400,
            Colors.red.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              AppAssets.getEmergencyIcon(size: 40, color: Colors.white),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// SOS Button Widget - Animated SOS button with branding
  static Widget buildSOSButton({
    required VoidCallback onPressed,
    bool isActivated = false,
    double? size,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size?.w ?? 120.w,
      height: size?.w ?? 120.w,
      decoration: BoxDecoration(
        color: isActivated ? Colors.red.shade700 : Colors.red,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: isActivated 
                ? Colors.red.withOpacity(0.5)
                : Colors.red.withOpacity(0.3),
            blurRadius: isActivated ? 30 : 20,
            spreadRadius: isActivated ? 8 : 5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(60.r),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emergency,
                  size: (size?.w ?? 120.w) * 0.4,
                  color: Colors.white,
                ),
                SizedBox(height: 4.h),
                Text(
                  'SOS',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Medical Branding Widget - Medical page specific branding
  static Widget buildMedicalBranding({
    required String title,
    String? subtitle,
    bool showIcon = true,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          if (showIcon)
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: AppAssets.getHealthIcon(size: 40, color: Colors.green),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.green.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Loading Overlay Widget - Overlay loading with branding
  static Widget buildLoadingOverlay({
    required bool isLoading,
    String? message,
    Widget? child,
  }) {
    return Stack(
      children: [
        child ?? const SizedBox.shrink(),
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: buildLoadingAnimation(
                message: message,
                showLogo: true,
                backgroundColor: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  /// Brand Footer Widget - Footer with branding
  static Widget buildBrandFooter({
    bool showLogo = true,
    bool showVersion = true,
    String version = '1.0.0',
    Color? textColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          if (showLogo)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: AppAssets.getLogo(width: 80, height: 25),
            ),
          if (showVersion)
            Text(
              'Version $version',
              style: TextStyle(
                fontSize: 12.sp,
                color: textColor ?? Colors.grey[600],
              ),
            ),
          SizedBox(height: 4.h),
          Text(
            '© 2024 FindMed Ethiopia',
            style: TextStyle(
              fontSize: 10.sp,
              color: textColor ?? Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// Empty State Widget - Empty state with branding
  static Widget buildEmptyState({
    required String message,
    String? subtitle,
    IconData? icon,
    VoidCallback? onAction,
    String? actionText,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or icon
            AppAssets.getLogo(width: 80, height: 30),
            
            SizedBox(height: 24.h),
            
            // Empty state icon
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64.w,
              color: Colors.grey[400],
            ),
            
            SizedBox(height: 16.h),
            
            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            
            if (subtitle != null) ...[
              SizedBox(height: 8.h),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            if (onAction != null && actionText != null) ...[
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Helper class to get context safely
class Get {
  static BuildContext? _context;
  
  static BuildContext? get context {
    return _context;
  }
  
  static void setContext(BuildContext context) {
    _context = context;
  }
  
  static void clearContext() {
    _context = null;
  }
}
