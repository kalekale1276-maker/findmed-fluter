import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// App Assets Manager - Handles all app images and branding
class AppAssets {
  // Logo assets
  static const String _logoPath = 'assets/images/logo.png';
  static const String _logoDarkPath = 'assets/images/logo_dark.png';
  static const String _logoIconPath = 'assets/images/logo_icon.png';
  
  // Loading assets
  static const String _loadingAnimationPath = 'assets/images/loading_animation.gif';
  static const String _loadingImagePath = 'assets/images/loading_image.png';
  static const String _splashScreenPath = 'assets/images/splash_screen.png';
  
  // App branding assets
  static const String _appIconPath = 'assets/images/app_icon.png';
  static const String _brandImagePath = 'assets/images/brand_image.png';
  
  // Emergency assets
  static const String _emergencyIconPath = 'assets/images/emergency_icon.png';
  static const String _sosButtonPath = 'assets/images/sos_button.png';
  
  // Medical assets
  static const String _medicalLogoPath = 'assets/images/medical_logo.png';
  static const String _healthIconPath = 'assets/images/health_icon.png';

  /// Get logo image based on theme
  static Widget getLogo({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Color? color,
    BuildContext? context,
  }) {
    final isDarkMode = context != null 
        ? Theme.of(context).brightness == Brightness.dark
        : WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    
    final logoPath = isDarkMode ? _logoDarkPath : _logoPath;
    
    return Image.asset(
      logoPath,
      width: width?.w,
      height: height?.h,
      fit: fit,
      color: color,
      errorBuilder: (context, error, stackTrace) => _buildDefaultLogo(width, height, color),
    );
  }

  /// Get logo icon
  static Widget getLogoIcon({
    double? size,
    Color? color,
  }) {
    return Image.asset(
      _logoIconPath,
      width: size?.w,
      height: size?.h,
      color: color,
      errorBuilder: (context, error, stackTrace) => _buildDefaultLogoIcon(size, color),
    );
  }

  /// Get loading animation
  static Widget getLoadingAnimation({
    double? width,
    double? height,
  }) {
    return Image.asset(
      _loadingAnimationPath,
      width: width?.w,
      height: height?.h,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => _buildDefaultLoadingIndicator(width, height),
    );
  }

  /// Get loading image
  static Widget getLoadingImage({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return Image.asset(
      _loadingImagePath,
      width: width?.w,
      height: height?.h,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildDefaultLoadingImage(width, height),
    );
  }

  /// Get splash screen image
  static Widget getSplashScreen({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return Image.asset(
      _splashScreenPath,
      width: width?.w,
      height: height?.h,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildDefaultSplashScreen(width, height),
    );
  }

  /// Get app icon
  static Widget getAppIcon({
    double? size,
    Color? color,
  }) {
    return Image.asset(
      _appIconPath,
      width: size?.w,
      height: size?.h,
      color: color,
      errorBuilder: (context, error, stackTrace) => _buildDefaultAppIcon(size, color),
    );
  }

  /// Get brand image
  static Widget getBrandImage({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return Image.asset(
      _brandImagePath,
      width: width?.w,
      height: height?.h,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildDefaultBrandImage(width, height),
    );
  }

  /// Get emergency icon
  static Widget getEmergencyIcon({
    double? size,
    Color? color,
  }) {
    return Image.asset(
      _emergencyIconPath,
      width: size?.w,
      height: size?.h,
      color: color,
      errorBuilder: (context, error, stackTrace) => _buildDefaultEmergencyIcon(size, color),
    );
  }

  /// Get SOS button image
  static Widget getSOSButton({
    double? width,
    double? height,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Image.asset(
        _sosButtonPath,
        width: width?.w,
        height: height?.h,
        errorBuilder: (context, error, stackTrace) => _buildDefaultSOSButton(width, height, onPressed),
      ),
    );
  }

  /// Get medical logo
  static Widget getMedicalLogo({
    double? width,
    double? height,
    Color? color,
  }) {
    return Image.asset(
      _medicalLogoPath,
      width: width?.w,
      height: height?.h,
      color: color,
      errorBuilder: (context, error, stackTrace) => _buildDefaultMedicalLogo(width, height, color),
    );
  }

  /// Get health icon
  static Widget getHealthIcon({
    double? size,
    Color? color,
  }) {
    return Image.asset(
      _healthIconPath,
      width: size?.w,
      height: size?.h,
      color: color,
      errorBuilder: (context, error, stackTrace) => _buildDefaultHealthIcon(size, color),
    );
  }

  // Default fallback widgets when images fail to load
  static Widget _buildDefaultLogo(double? width, double? height, Color? color) {
    return Container(
      width: width?.w ?? 120.w,
      height: height?.h ?? 40.h,
      decoration: BoxDecoration(
        color: color ?? Colors.blue,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Text(
          'FindMed',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static Widget _buildDefaultLogoIcon(double? size, Color? color) {
    return Container(
      width: size?.w ?? 40.w,
      height: size?.h ?? 40.h,
      decoration: BoxDecoration(
        color: color ?? Colors.blue,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'FM',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static Widget _buildDefaultLoadingIndicator(double? width, double? height) {
    return SizedBox(
      width: width?.w ?? 40.w,
      height: height?.h ?? 40.h,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }

  static Widget _buildDefaultLoadingImage(double? width, double? height) {
    return Container(
      width: width?.w ?? 200.w,
      height: height?.h ?? 200.h,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_services, size: 40.w, color: Colors.blue),
          SizedBox(height: 8.h),
          Text(
            'Loading...',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  static Widget _buildDefaultSplashScreen(double? width, double? height) {
    return Container(
      width: width?.w ?? double.infinity,
      height: height?.h ?? double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_services, size: 80.w, color: Colors.white),
          SizedBox(height: 16.h),
          Text(
            'FindMed',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your Health Companion',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDefaultAppIcon(double? size, Color? color) {
    return Container(
      width: size?.w ?? 60.w,
      height: size?.h ?? 60.h,
      decoration: BoxDecoration(
        color: color ?? Colors.blue,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Icon(
          Icons.medical_services,
          size: (size?.w ?? 60.w) * 0.6,
          color: Colors.white,
        ),
      ),
    );
  }

  static Widget _buildDefaultBrandImage(double? width, double? height) {
    return Container(
      width: width?.w ?? 300.w,
      height: height?.h ?? 100.h,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 40.w, color: Colors.red),
            SizedBox(height: 8.h),
            Text(
              'FindMed Ethiopia',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            Text(
              'Healthcare at your fingertips',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.blue.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDefaultEmergencyIcon(double? size, Color? color) {
    return Container(
      width: size?.w ?? 50.w,
      height: size?.h ?? 50.h,
      decoration: BoxDecoration(
        color: color ?? Colors.red,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.emergency,
        size: (size?.w ?? 50.w) * 0.6,
        color: Colors.white,
      ),
    );
  }

  static Widget _buildDefaultSOSButton(double? width, double? height, VoidCallback? onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width?.w ?? 120.w,
        height: height?.h ?? 120.h,
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emergency,
                size: (width?.w ?? 120.w) * 0.4,
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
    );
  }

  static Widget _buildDefaultMedicalLogo(double? width, double? height, Color? color) {
    return Container(
      width: width?.w ?? 100.w,
      height: height?.h ?? 40.h,
      decoration: BoxDecoration(
        color: color ?? Colors.green,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services, size: 20.w, color: Colors.white),
            SizedBox(width: 8.w),
            Text(
              'Medical',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDefaultHealthIcon(double? size, Color? color) {
    return Container(
      width: size?.w ?? 40.w,
      height: size?.h ?? 40.h,
      decoration: BoxDecoration(
        color: color ?? Colors.green,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.favorite,
        size: (size?.w ?? 40.w) * 0.6,
        color: Colors.white,
      ),
    );
  }
}
