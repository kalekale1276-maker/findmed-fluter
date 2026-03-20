import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../core/utils/navigation_service.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../../../../app/constants/route_constants.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      NavigationService.pushReplacementNamed(RouteConstants.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryVariant],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with animation
                Container(
                  padding: EdgeInsets.all(context.responsivePaddingLg),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(context.responsiveMarginLg),
                  ),
                  child: Icon(
                    Icons.local_hospital,
                    size: context.isMobile ? 60.w : 80.w,
                    color: Colors.white,
                  ),
                ),
                
                SizedBox(height: context.responsiveGap),
                
                // App name with text animation
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'FindMed',
                        style: TextStyle(
                          fontSize: context.isMobile ? 28.sp : 32.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    );
                  },
                ),
                
                SizedBox(height: context.responsiveGapSm),
                
                // Tagline
                Text(
                  'Your Healthcare Companion',
                  style: TextStyle(
                    fontSize: context.isMobile ? 14.sp : 16.sp,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w300,
                  ),
                ),
                
                SizedBox(height: context.responsiveGapLg),
                
                // Loading indicator with custom styling
                Container(
                  padding: EdgeInsets.all(context.responsivePadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(context.responsiveRadiusXl),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: context.isMobile ? 20.w : 24.w,
                        height: context.isMobile ? 20.w : 24.w,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        ),
                      ),
                      SizedBox(height: context.responsiveGapSm),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: context.isMobile ? 12.sp : 14.sp,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
