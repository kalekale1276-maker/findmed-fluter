import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/utils/tailwind_extensions.dart';
import '../../widgets/branding_widgets.dart';

/// Splash Screen - App launch screen with branding
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    _fadeController.forward();
    _scaleController.forward();
  }

  void _startSplashSequence() async {
    // Show splash for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    
    // Navigate to main app
    if (mounted) {
      _navigateToMainApp();
    }
  }

  void _navigateToMainApp() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: _buildSplashContent(),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSplashContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Main logo with hero animation
        Hero(
          tag: 'app_logo',
          child: BrandingWidgets.buildAppLogo(
            width: 200,
            height: 70,
            showShadow: true,
          ),
        ),
        
        SizedBox(height: 40.h),
        
        // App name
        Text(
          'FindMed Ethiopia',
          style: TextStyle(
            fontSize: 32.sp,
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
        
        SizedBox(height: 60.h),
        
        // Loading animation
        BrandingWidgets.buildLoadingAnimation(
          width: 80,
          height: 80,
          message: 'Initializing...',
        ),
        
        SizedBox(height: 40.h),
        
        // Progress indicator
        _buildProgressIndicator(),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      width: 200.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2.r),
      ),
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Splash Screen Controller - Manages splash screen flow
class SplashScreenController {
  static Future<void> showSplashScreen(BuildContext context) async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const SplashPage(),
      ),
    );
  }

  static Future<void> navigateToMainApp(BuildContext context) async {
    // This would navigate to your main app/home page
    // For now, we'll just show a placeholder
    await Navigator.of(context).pushReplacementNamed('/home');
  }

  static Widget buildCustomSplash({
    required Widget child,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onComplete,
  }) {
    return SplashScreen(
      duration: duration,
      onComplete: onComplete ?? () {},
      child: child,
    );
  }
}

/// Custom Splash Screen Widget
class SplashScreen extends StatefulWidget {
  final Duration duration;
  final VoidCallback onComplete;
  final Widget child;

  const SplashScreen({
    super.key,
    required this.duration,
    required this.onComplete,
    required this.child,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _startSplashSequence();
  }

  void _startSplashSequence() async {
    await Future.delayed(widget.duration);
    
    if (mounted) {
      _controller.forward().then((_) {
        widget.onComplete();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}
