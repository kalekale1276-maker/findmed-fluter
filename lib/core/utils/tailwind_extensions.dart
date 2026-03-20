import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Extension for responsive scaling using Tailwind-inspired utilities
extension TailwindExtensions on BuildContext {
  /// Get responsive font size
  double get responsiveText => MediaQuery.of(this).size.width * 0.04;
  
  double get responsiveTextSm => MediaQuery.of(this).size.width * 0.03;
  double get responsiveTextLg => MediaQuery.of(this).size.width * 0.05;
  double get responsiveTextXl => MediaQuery.of(this).size.width * 0.06;
  double get responsiveText2Xl => MediaQuery.of(this).size.width * 0.07;
  
  /// Get responsive padding
  double get responsivePadding => MediaQuery.of(this).size.width * 0.04;
  
  /// Get responsive spacing
  double get p4 => MediaQuery.of(this).size.width * 0.01;
  double get m8 => MediaQuery.of(this).size.width * 0.02;
  double get l16 => MediaQuery.of(this).size.width * 0.04;
  
  /// Get responsive text sizes
  double get responsiveTextXs => MediaQuery.of(this).size.width * 0.025;
  double get responsiveTextMd => MediaQuery.of(this).size.width * 0.04;
  
  /// Get responsive margin
  double get responsiveMargin => MediaQuery.of(this).size.width * 0.04;
  double get responsiveMarginSm => MediaQuery.of(this).size.width * 0.03;
  
  /// Get responsive spacing
  double get responsiveGap => MediaQuery.of(this).size.width * 0.04;
  double get responsiveGapSm => MediaQuery.of(this).size.width * 0.03;
  double get responsiveGapLg => MediaQuery.of(this).size.width * 0.05;
  
  /// Get responsive height
  double get responsiveHeight => MediaQuery.of(this).size.height * 0.06;
  double get responsiveHeightSm => MediaQuery.of(this).size.height * 0.04;
  double get responsiveHeightLg => MediaQuery.of(this).size.height * 0.08;
  
  /// Get responsive width
  double get responsiveWidth => MediaQuery.of(this).size.width * 0.9;
  double get responsiveWidthSm => MediaQuery.of(this).size.width * 0.8;
  double get responsiveWidthLg => MediaQuery.of(this).size.width * 0.95;
  
  /// Screen size breakpoints
  bool get isMobile => MediaQuery.of(this).size.width < 768;
  bool get isTablet => MediaQuery.of(this).size.width >= 768 && MediaQuery.of(this).size.width < 1024;
  bool get isDesktop => MediaQuery.of(this).size.width >= 1024;
  
  /// Dark mode detection
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  /// Aspect ratio utilities
  double get aspectRatio16_9 => 16.0 / 9.0;
  double get aspectRatio4_3 => 4.0 / 3.0;
  double get aspectRatio1_1 => 1.0;
}

/// Color utilities inspired by Tailwind
class TailwindColors {
  static const Color blue50 = Color(0xFFeff6ff);
  static const Color primary50 = Color(0xFFe8f5e8);
  static const Color primary100 = Color(0xFFc8e6c9);
  static const Color primary200 = Color(0xFFa5d6a7);
  static const Color primary300 = Color(0xFF6b7280);
  static const Color primary400 = Color(0xFF4b5563);
  static const Color primary500 = Color(0xFF374151);
  static const Color primary600 = Color(0xFF1f2937);
  static const Color primary700 = Color(0xFF111827);
  static const Color primary800 = Color(0xFF030712);
  static const Color primary900 = Color(0xFF000000);
  
  static const Color medical50 = Color(0xFFf0fdf4);
  static const Color medical100 = Color(0xFFdcfce7);
  static const Color medical200 = Color(0xFFbbf7d0);
  static const Color medical300 = Color(0xFF86efac);
  static const Color medical400 = Color(0xFF4ade80);
  static const Color medical500 = Color(0xFF22c55e);
  static const Color medical600 = Color(0xFF16a34a);
  static const Color medical700 = Color(0xFF15803d);
  static const Color medical800 = Color(0xFF166534);
  static const Color medical900 = Color(0xFF14532d);
  
  static const Color gray50 = Color(0xFFf9fafb);
  static const Color gray100 = Color(0xFFf3f4f6);
  static const Color gray200 = Color(0xFFe5e7eb);
  static const Color gray300 = Color(0xFFd1d5db);
  static const Color gray400 = Color(0xFF9ca3af);
  static const Color gray500 = Color(0xFF6b7280);
  static const Color gray600 = Color(0xFF4b5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1f2937);
  static const Color gray900 = Color(0xFF111827);
  
  static const Color red50 = Color(0xFFfef2f2);
  static const Color red100 = Color(0xFFfee2e2);
  static const Color red200 = Color(0xFFfecaca);
  static const Color red300 = Color(0xFFfca5a5);
  static const Color red400 = Color(0xFFf87171);
  static const Color red500 = Color(0xFFef4444);
  static const Color red600 = Color(0xFFdc2626);
  static const Color red700 = Color(0xFFb91c1c);
  static const Color red800 = Color(0xFF991b1b);
  static const Color red900 = Color(0xFF7f1d1d);
}

/// Spacing utilities
class TailwindSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

/// Border radius utilities
class TailwindRadius {
  static const double none = 0.0;
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 20.0;
  static const double full = 9999.0;
}

/// Shadow utilities
class TailwindShadows {
  static const BoxShadow sm = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 1,
    offset: Offset(0, 1),
  );
  
  static const BoxShadow md = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 2,
    offset: Offset(0, 2),
  );
  
  static const BoxShadow lg = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );
  
  static const BoxShadow xl = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 16,
    offset: Offset(0, 8),
  );
}
