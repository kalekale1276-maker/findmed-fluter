# FindMed Branding Integration Guide

## 🎨 Complete Branding System Integration

This guide shows how to integrate your logo and loading images throughout the FindMed app using the comprehensive branding system we've created.

## 📁 Files Created

### Core Branding Files
- `lib/core/utils/app_assets.dart` - Asset management system
- `lib/widgets/branding_widgets.dart` - Branding UI components
- `lib/pages/splash/splash_page.dart` - Splash screen implementation
- `assets/README.md` - Asset documentation

### Updated Pages
- `lib/pages/emergency/emergency_page.dart` - Updated with branding
- `lib/pages/notifications/notifications_page.dart` - Updated with branding

## 🚀 Quick Start

### 1. Add Assets to pubspec.yaml

```yaml
flutter:
  assets:
    - assets/images/
    - assets/images/logo.png
    - assets/images/logo_dark.png
    - assets/images/logo_icon.png
    - assets/images/loading_animation.gif
    - assets/images/loading_image.png
    - assets/images/splash_screen.png
    - assets/images/app_icon.png
    - assets/images/brand_image.png
    - assets/images/emergency_icon.png
    - assets/images/sos_button.png
    - assets/images/medical_logo.png
    - assets/images/health_icon.png
```

### 2. Use Branding in Your Pages

```dart
import 'package:flutter/material.dart';
import '../../../../widgets/branding_widgets.dart';

class YourPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandingWidgets.buildBrandHeader(
        title: 'Your Page Title',
        showBackButton: true,
      ),
      body: BrandingWidgets.buildLoadingOverlay(
        isLoading: _isLoading,
        message: 'Loading...',
        child: _buildContent(),
      ),
    );
  }
}
```

## 🎯 Branding Components Available

### 📱 Logo Components

#### App Logo
```dart
// Main logo with theme support
BrandingWidgets.buildAppLogo(
  width: 120,
  height: 40,
  onTap: () => print('Logo tapped!'),
  showShadow: true,
)

// Small logo icon
BrandingWidgets.buildAppLogoIcon(
  size: 40,
  onTap: () => print('Icon tapped!'),
)
```

#### Brand Headers
```dart
// Header with logo and title
BrandingWidgets.buildBrandHeader(
  title: 'Emergency Services',
  subtitle: 'Find nearby hospitals',
  showBackButton: true,
  onBackPressed: () => Navigator.pop(context),
  actions: [
    IconButton(
      onPressed: () => print('Action tapped!'),
      icon: Icon(Icons.refresh),
    ),
  ],
)
```

### 🔄 Loading Components

#### Loading Animation
```dart
// Animated loading with logo
BrandingWidgets.buildLoadingAnimation(
  message: 'Loading facilities...',
  showLogo: true,
  backgroundColor: Colors.white,
)

// Full screen loading
BrandingWidgets.buildFullScreenLoading(
  message: 'Initializing app...',
  showProgress: true,
  progress: 0.75,
)

// Loading overlay
BrandingWidgets.buildLoadingOverlay(
  isLoading: _isLoading,
  message: 'Saving changes...',
  child: YourContent(),
)
```

#### Splash Screen
```dart
// Complete splash screen
SplashPage()

// Custom splash with branding
BrandingWidgets.buildSplashScreen(
  onComplete: () => navigateToMainApp(),
  duration: Duration(seconds: 3),
)
```

### 🚨 Emergency Components

#### Emergency Branding
```dart
// Emergency header with styling
BrandingWidgets.buildEmergencyBranding(
  title: 'Emergency Services',
  subtitle: '24/7 emergency care available',
)
```

#### SOS Button
```dart
// Animated SOS button
BrandingWidgets.buildSOSButton(
  onPressed: () => activateEmergency(),
  isActivated: _isEmergencyActive,
  size: 120,
)
```

### 🏥 Medical Components

#### Medical Branding
```dart
// Medical services branding
BrandingWidgets.buildMedicalBranding(
  title: 'Medical Services',
  subtitle: 'Quality healthcare providers',
  showIcon: true,
)
```

### 📄 Empty States

#### Branded Empty States
```dart
// Empty state with branding
BrandingWidgets.buildEmptyState(
  message: 'No facilities found',
  subtitle: 'Try adjusting your search criteria',
  icon: Icons.search_off,
  onAction: () => refreshData(),
  actionText: 'Refresh',
)
```

### 🦶 Footer Components

#### Brand Footer
```dart
// Footer with logo and version
BrandingWidgets.buildBrandFooter(
  showLogo: true,
  showVersion: true,
  version: '1.0.0',
)
```

## 🔧 Page Integration Examples

### Emergency Page Integration

```dart
class EmergencyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BrandingWidgets.buildLoadingOverlay(
        isLoading: _isLoading,
        message: 'Finding emergency facilities...',
        child: Column(
          children: [
            // Emergency branding header
            BrandingWidgets.buildEmergencyBranding(
              title: 'Emergency Services',
              subtitle: 'Find nearby hospitals and emergency care',
            ),
            
            // SOS button
            BrandingWidgets.buildSOSButton(
              onPressed: _activateSOS,
              isActivated: _isSOSActive,
            ),
            
            // Rest of content...
          ],
        ),
      ),
    );
  }
}
```

### Notifications Page Integration

```dart
class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandingWidgets.buildBrandHeader(
        title: 'Notifications',
        showBackButton: false,
      ),
      body: BrandingWidgets.buildLoadingOverlay(
        isLoading: _isLoading,
        message: 'Loading notifications...',
        child: _buildNotificationsList(),
      ),
    );
  }
  
  Widget _buildNotificationsList() {
    if (_notifications.isEmpty) {
      return BrandingWidgets.buildEmptyState(
        message: 'No notifications',
        subtitle: 'You\'re all caught up!',
        icon: Icons.notifications_none,
        onAction: _refreshNotifications,
        actionText: 'Refresh',
      );
    }
    return ListView.builder(...);
  }
}
```

### Profile Page Integration

```dart
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandingWidgets.buildBrandHeader(
        title: 'Profile',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Profile header with logo
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                BrandingWidgets.buildAppLogoIcon(size: 60),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('John Doe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('john.doe@example.com', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Rest of profile content...
        ],
      ),
    );
  }
}
```

## 🎨 Customization Options

### Theme Adaptation
The branding system automatically adapts to light/dark themes:

```dart
// Automatic theme detection
BrandingWidgets.buildAppLogo() // Uses light/dark theme automatically

// Manual theme override
BrandingWidgets.buildAppLogo(color: Colors.blue) // Force specific color
```

### Responsive Sizing
All components use flutter_screenutil for responsive design:

```dart
// Responsive sizing
BrandingWidgets.buildAppLogo(
  width: context.responsiveSizeLg, // Responsive size
  height: context.responsiveSizeMd,
)
```

### Custom Styling
You can customize the appearance of all components:

```dart
// Custom background color
BrandingWidgets.buildLoadingAnimation(
  backgroundColor: Colors.blue.shade50,
)

// Custom text color
BrandingWidgets.buildBrandHeader(
  textColor: Colors.blue.shade700,
)
```

## 🔍 Advanced Usage

### Custom Asset Handling
If you have custom images, extend the AppAssets class:

```dart
class CustomAppAssets extends AppAssets {
  static Widget getCustomLogo({
    double? width,
    double? height,
  }) {
    return Image.asset(
      'assets/images/custom_logo.png',
      width: width?.w,
      height: height?.h,
    );
  }
}
```

### Animation Integration
Combine branding with custom animations:

```dart
class AnimatedLogo extends StatefulWidget {
  @override
  _AnimatedLogoState createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: BrandingWidgets.buildAppLogo(width: 100, height: 35),
        );
      },
    );
  }
}
```

## 🚀 Performance Tips

### Image Optimization
1. Use appropriate image formats (WebP for better compression)
2. Implement image caching
3. Use placeholder images during loading
4. Optimize for different screen densities

### Loading States
1. Show loading overlays for better UX
2. Use skeleton loaders for content
3. Implement progressive loading
4. Add timeout handling

### Memory Management
1. Dispose controllers properly
2. Use const widgets where possible
3. Implement image cleanup
4. Monitor memory usage

## 📱 Testing

### Widget Testing
```dart
testWidgets('Branding widgets render correctly', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: BrandingWidgets.buildAppLogo(width: 100, height: 30),
      ),
    ),
  );
  
  expect(find.byType(Image), findsOneWidget);
});
```

### Integration Testing
```dart
testWidgets('Loading overlay shows and hides correctly', (WidgetTester tester) async {
  bool isLoading = false;
  
  await tester.pumpWidget(
    MaterialApp(
      home: StatefulBuilder(
        builder: (context, setState) {
          return Scaffold(
            body: BrandingWidgets.buildLoadingOverlay(
              isLoading: isLoading,
              message: 'Loading...',
              child: Container(),
            ),
          );
        },
      ),
    ),
  );
  
  // Test loading state
  setState(() => isLoading = true);
  await tester.pump();
  expect(find.text('Loading...'), findsOneWidget);
});
```

## 🔧 Troubleshooting

### Common Issues
1. **Images not loading**: Check pubspec.yaml configuration
2. **Theme switching**: Ensure both light/dark variants exist
3. **Performance**: Optimize image sizes and formats
4. **Memory usage**: Implement proper image disposal

### Debug Mode
Enable debugging for asset loading:

```dart
// In debug mode, show image loading errors
if (kDebugMode) {
  BrandingWidgets.buildAppLogo(
    errorBuilder: (context, error, stackTrace) {
      debugPrint('Image loading error: $error');
      return Container(
        color: Colors.red,
        child: Text('Image Error'),
      );
    },
  );
}
```

## 📈 Analytics Integration

Track branding interactions:

```dart
// Track logo taps
BrandingWidgets.buildAppLogo(
  onTap: () {
    Analytics.trackEvent('logo_tapped', {
      'page': 'emergency',
      'timestamp': DateTime.now().toIso8601String(),
    });
  },
);

// Track loading times
final stopwatch = Stopwatch()..start();
await _loadData();
stopwatch.stop();
Analytics.trackPerformance('page_load_time', {
  'page': 'notifications',
  'duration_ms': stopwatch.elapsedMilliseconds,
});
```

## 🎯 Best Practices

### 1. Consistent Usage
- Use branding components consistently across all pages
- Maintain consistent sizing and spacing
- Follow the established color schemes

### 2. Performance
- Use loading overlays for better perceived performance
- Implement proper error handling
- Cache images appropriately

### 3. Accessibility
- Provide alt text for images
- Ensure good contrast ratios
- Support screen readers

### 4. Responsive Design
- Test on different screen sizes
- Use responsive sizing utilities
- Ensure proper scaling

## 🔄 Migration Guide

### From Custom Components
Replace custom logo and loading components:

```dart
// Before
Image.asset('assets/logo.png', width: 120, height: 40)
CircularProgressIndicator()

// After
BrandingWidgets.buildAppLogo(width: 120, height: 40)
BrandingWidgets.buildLoadingAnimation()
```

### From Manual Loading
Replace manual loading states:

```dart
// Before
if (_isLoading) {
  return CircularProgressIndicator();
}
return YourContent();

// After
return BrandingWidgets.buildLoadingOverlay(
  isLoading: _isLoading,
  message: 'Loading...',
  child: YourContent(),
);
```

## 📞 Support

For branding-related issues:
1. Check asset paths in pubspec.yaml
2. Verify image formats and sizes
3. Test on different devices and themes
4. Monitor performance and memory usage

---

**Result**: Your FindMed app now has a comprehensive branding system with logo integration, loading animations, and consistent theming across all pages! 🎉
