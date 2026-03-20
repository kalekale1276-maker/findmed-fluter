# FindMed Assets

This directory contains all the images and assets used in the FindMed app.

## 📁 Asset Structure

```
assets/
├── images/
│   ├── logo.png              # Main app logo (light theme)
│   ├── logo_dark.png         # Main app logo (dark theme)
│   ├── logo_icon.png         # Small logo icon
│   ├── loading_animation.gif # Loading animation
│   ├── loading_image.png     # Loading screen image
│   ├── splash_screen.png     # Splash screen background
│   ├── app_icon.png          # App icon
│   ├── brand_image.png       # Brand image for marketing
│   ├── emergency_icon.png    # Emergency services icon
│   ├── sos_button.png        # SOS button image
│   ├── medical_logo.png      # Medical services logo
│   └── health_icon.png       # Health services icon
└── README.md                  # This file
```

## 🖼️ Image Descriptions

### Logo Assets
- **logo.png**: Main FindMed logo for light theme
- **logo_dark.png**: Main FindMed logo for dark theme
- **logo_icon.png**: Small circular logo icon for headers and buttons

### Loading Assets
- **loading_animation.gif**: Animated loading indicator
- **loading_image.png**: Static loading image for fallback
- **splash_screen.png**: Full-screen splash background

### App Branding
- **app_icon.png**: Main application icon
- **brand_image.png**: Brand image for marketing materials

### Feature-Specific Icons
- **emergency_icon.png**: Emergency services icon
- **sos_button.png**: SOS button image
- **medical_logo.png**: Medical services logo
- **health_icon.png**: Health services icon

## 📱 Usage in App

### Logo Usage
```dart
// Main logo
BrandingWidgets.buildAppLogo(width: 120, height: 40)

// Logo icon
BrandingWidgets.buildAppLogoIcon(size: 40)

// In headers
BrandingWidgets.buildBrandHeader(title: 'Page Title')
```

### Loading Usage
```dart
// Loading animation
BrandingWidgets.buildLoadingAnimation(message: 'Loading...')

// Full screen loading
BrandingWidgets.buildFullScreenLoading(message: 'Initializing...')

// Loading overlay
BrandingWidgets.buildLoadingOverlay(isLoading: true, child: content)
```

### Emergency Usage
```dart
// Emergency branding
BrandingWidgets.buildEmergencyBranding(title: 'Emergency Services')

// SOS button
BrandingWidgets.buildSOSButton(onPressed: handleSOS)
```

### Splash Screen Usage
```dart
// Custom splash screen
SplashPage()
```

## 🎨 Design Guidelines

### Logo Specifications
- **Primary Color**: Blue (#3B82F6)
- **Secondary Color**: Green (#10B981)
- **Emergency Color**: Red (#EF4444)
- **Text Color**: White (#FFFFFF) on dark backgrounds
- **Shadow**: Subtle shadow for depth

### Loading Animations
- **Duration**: 1-3 seconds
- **Frame Rate**: 24-30 FPS
- **Size**: 60x80 to 120x120 pixels
- **Format**: GIF or PNG sequence

### Image Sizes
- **Logo**: 120x40 pixels (scalable)
- **Logo Icon**: 40x40 pixels
- **Loading**: 80x80 pixels
- **SOS Button**: 120x120 pixels
- **App Icon**: 512x512 pixels (for app stores)

## 🔧 Implementation

### App Assets Integration
All images are automatically handled by the `AppAssets` class:

```dart
// Automatic theme detection
AppAssets.getLogo() // Uses dark/light theme automatically

// Fallback handling
AppAssets.getLogo(errorBuilder: (context, error, stackTrace) {
  return fallbackWidget;
})
```

### Responsive Design
All assets are responsive using `flutter_screenutil`:

```dart
// Responsive sizing
AppAssets.getLogo(width: 120.w, height: 40.h)

// Context-aware sizing
AppAssets.getLogo(size: context.responsiveSizeMd)
```

## 🚀 Deployment

### Android
- Place images in `android/app/src/main/res/drawable/`
- Update `android/app/src/main/AndroidManifest.xml`

### iOS
- Place images in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Update `ios/Runner/Info.plist`

### Web
- Images are automatically served from `assets/` directory
- Ensure `pubspec.yaml` includes assets section

## 📋 pubspec.yaml Configuration

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

## 🎯 Best Practices

### Image Optimization
- Use WebP format for better compression
- Implement lazy loading for large images
- Cache images appropriately
- Use appropriate image sizes for different contexts

### Theme Support
- Provide both light and dark theme variants
- Use automatic theme detection
- Ensure good contrast ratios

### Performance
- Use appropriate image formats
- Implement image caching
- Optimize for different screen densities
- Use placeholder images during loading

## 🔍 Troubleshooting

### Common Issues
1. **Images not loading**: Check `pubspec.yaml` configuration
2. **Theme switching**: Ensure both light/dark variants exist
3. **Performance**: Optimize image sizes and formats
4. **Memory usage**: Implement proper image disposal

### Debug Mode
Enable image debugging in development:

```dart
// In debug mode, show image loading errors
if (kDebugMode) {
  AppAssets.getLogo(
    errorBuilder: (context, error, stackTrace) {
      debugPrint('Image loading error: $error');
      return errorWidget;
    },
  );
}
```

## 📈 Analytics

Track image loading performance:

```dart
// Monitor image loading times
final stopwatch = Stopwatch()..start();
await AppAssets.getLogo();
stopwatch.stop();
Analytics.trackImageLoadTime('logo', stopwatch.elapsedMilliseconds);
```

## 🔄 Updates

When updating images:
1. Maintain consistent naming conventions
2. Update all theme variants
3. Test on different screen sizes
4. Verify performance impact
5. Update documentation

## 📞 Support

For asset-related issues:
1. Check file paths in `pubspec.yaml`
2. Verify image formats and sizes
3. Test on different devices
4. Check theme switching functionality
5. Monitor memory usage

---

**Note**: All images should be optimized for mobile use and follow the design guidelines provided.
