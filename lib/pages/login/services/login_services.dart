import 'package:flutter/foundation.dart';
import '../../../../services/auth.dart';
import '../models/login_models.dart';

/// Services for login functionality
class LoginServices {
  static final AuthService _auth = AuthService.instance;

  /// Perform email and password login
  static Future<LoginResult> performLogin({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      // Initialize auth service if needed
      await _auth.init();
      
      // Perform login
      final success = await _auth.login(email, password);
      
      if (success && _auth.isLoggedIn) {
        final user = _auth.user;
        
        // Store remember me preference
        if (rememberMe) {
          await _saveRememberMePreference(email);
        } else {
          await _clearRememberMePreference();
        }
        
        return LoginResult.success(
          userId: user?['id']?.toString() ?? user?['_id']?.toString(),
          userData: user,
        );
      } else {
        return LoginResult.failure(LoginConstants.invalidCredentialsMessage);
      }
    } catch (e) {
      debugPrint('Login error: $e');
      
      // Handle different error types
      if (e.toString().contains('network')) {
        return LoginResult.failure(LoginConstants.networkErrorMessage);
      } else if (e.toString().contains('server')) {
        return LoginResult.failure(LoginConstants.serverErrorMessage);
      } else {
        return LoginResult.failure(LoginConstants.loginFailedMessage);
      }
    }
  }

  /// Perform social login
  static Future<LoginResult> performSocialLogin({
    required String provider,
    String? token,
    Map<String, dynamic>? userData,
  }) async {
    try {
      // Initialize auth service if needed
      await _auth.init();
      
      // This would typically integrate with social login SDKs
      // For now, return mock success
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock user data for social login
      final mockUserData = {
        'id': 'social_${provider}_${DateTime.now().millisecondsSinceEpoch}',
        'email': userData?['email'] ?? 'user@${provider}.com',
        'name': userData?['name'] ?? 'Social User',
        'provider': provider,
        'avatar': userData?['avatar'],
        'verified': true,
      };
      
      // Set mock user in auth service (this would normally be handled by the SDK)
      // For demonstration purposes only
      
      return LoginResult.success(
        userId: mockUserData['id'] as String,
        userData: mockUserData,
        message: 'Successfully logged in with $provider',
      );
    } catch (e) {
      debugPrint('Social login error: $e');
      return LoginResult.failure('Failed to login with $provider');
    }
  }

  /// Perform guest login
  static Future<LoginResult> performGuestLogin() async {
    try {
      // Initialize auth service if needed
      await _auth.init();
      
      // Create guest user data
      final guestUserData = {
        'id': 'guest_${DateTime.now().millisecondsSinceEpoch}',
        'email': 'guest@findmed.local',
        'name': 'Guest User',
        'isGuest': true,
        'permissions': ['read'],
      };
      
      // Set guest user in auth service (this would normally be handled by the backend)
      // For demonstration purposes only
      
      return LoginResult.success(
        userId: guestUserData['id'] as String,
        userData: guestUserData,
        message: 'Continuing as guest',
      );
    } catch (e) {
      debugPrint('Guest login error: $e');
      return LoginResult.failure('Failed to continue as guest');
    }
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// Validate password strength
  static PasswordStrength validatePasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.empty;
    
    int score = 0;
    
    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    
    // Character variety
    if (password.contains(RegExp(r'[a-z]'))) score++; // lowercase
    if (password.contains(RegExp(r'[A-Z]'))) score++; // uppercase
    if (password.contains(RegExp(r'[0-9]'))) score++; // numbers
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++; // special chars
    
    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  /// Get password strength description
  static String getPasswordStrengthDescription(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.empty:
        return 'Enter a password';
      case PasswordStrength.weak:
        return 'Weak password';
      case PasswordStrength.medium:
        return 'Medium strength';
      case PasswordStrength.strong:
        return 'Strong password';
    }
  }

  /// Get password strength color
  static Color getPasswordStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.empty:
        return Colors.grey;
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  /// Save remember me preference
  static Future<void> _saveRememberMePreference(String email) async {
    try {
      // This would typically use shared_preferences
      // For now, just log the preference
      debugPrint('Saving remember me preference for: $email');
      
      // Mock implementation
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint('Error saving remember me preference: $e');
    }
  }

  /// Clear remember me preference
  static Future<void> _clearRememberMePreference() async {
    try {
      // This would typically use shared_preferences
      // For now, just log the action
      debugPrint('Clearing remember me preference');
      
      // Mock implementation
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint('Error clearing remember me preference: $e');
    }
  }

  /// Load remember me preference
  static Future<String?> loadRememberMePreference() async {
    try {
      // This would typically use shared_preferences
      // For now, return null as mock
      await Future.delayed(const Duration(milliseconds: 100));
      return null;
    } catch (e) {
      debugPrint('Error loading remember me preference: $e');
      return null;
    }
  }

  /// Check if user is already logged in
  static bool isLoggedIn() {
    try {
      return _auth.isLoggedIn;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  /// Get current user data
  static Map<String, dynamic>? getCurrentUser() {
    try {
      return _auth.user;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  /// Logout user
  static Future<void> logout() async {
    try {
      await _auth.logout();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  /// Reset password
  static Future<bool> resetPassword(String email) async {
    try {
      // This would typically call a password reset API
      // For now, return mock success
      await Future.delayed(const Duration(seconds: 1));
      
      debugPrint('Password reset requested for: $email');
      return true;
    } catch (e) {
      debugPrint('Error resetting password: $e');
      return false;
    }
  }

  /// Get login analytics (mock implementation)
  static Future<LoginAnalytics> getLoginAnalytics() async {
    try {
      // This would typically fetch analytics from backend
      // For now, return mock data
      await Future.delayed(const Duration(milliseconds: 300));
      
      return LoginAnalytics(
        totalAttempts: 1250,
        successfulLogins: 1180,
        failedLogins: 70,
        providerUsage: {
          'email': 800,
          'google': 350,
          'facebook': 30,
        },
        lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
        averageTimeToLogin: 15.5,
      );
    } catch (e) {
      debugPrint('Error getting login analytics: $e');
      rethrow;
    }
  }

  /// Record login attempt (for analytics)
  static Future<void> recordLoginAttempt({
    String? provider,
    bool success = false,
    double? duration,
  }) async {
    try {
      // This would typically send analytics to backend
      debugPrint('Login attempt recorded: provider=$provider, success=$success, duration=$duration');
      
      // Mock API call
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint('Error recording login attempt: $e');
    }
  }

  /// Check if social login is available
  static Future<bool> isSocialLoginAvailable(String provider) async {
    try {
      // This would typically check if the social login SDK is available
      // For now, return true for enabled providers
      await Future.delayed(const Duration(milliseconds: 100));
      
      final enabledProviders = SocialLoginProvider.getEnabledProviders();
      return enabledProviders.any((p) => p.id == provider);
    } catch (e) {
      debugPrint('Error checking social login availability: $e');
      return false;
    }
  }

  /// Initialize social login providers
  static Future<void> initializeSocialProviders() async {
    try {
      // This would typically initialize social login SDKs
      // For now, just log the initialization
      debugPrint('Initializing social login providers');
      
      final providers = SocialLoginProvider.getAllProviders();
      for (final provider in providers) {
        if (provider.isEnabled) {
          debugPrint('Initializing ${provider.name} login');
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
    } catch (e) {
      debugPrint('Error initializing social providers: $e');
    }
  }

  /// Get login security tips
  static List<String> getSecurityTips() {
    return [
      'Use a strong, unique password',
      'Enable two-factor authentication when available',
      'Never share your login credentials',
      'Always log out on shared devices',
      'Keep your app updated for latest security features',
      'Use a secure internet connection',
    ];
  }

  /// Validate login form data
  static Map<String, String> validateLoginForm(LoginFormData formData) {
    return formData.getValidationErrors();
  }

  /// Check if email domain is allowed
  static bool isEmailDomainAllowed(String email) {
    // This could be used to restrict to specific domains
    // For now, allow all domains
    return true;
  }

  /// Get supported social login providers
  static List<SocialLoginProvider> getSupportedProviders() {
    return SocialLoginProvider.getEnabledProviders();
  }

  /// Check if guest mode is enabled
  static bool isGuestModeEnabled() {
    // This could be controlled by app configuration
    return true;
  }

  /// Get login features for display
  static List<LoginFeature> getLoginFeatures() {
    return LoginFeature.getAllFeatures();
  }

  /// Generate secure session token
  static String generateSessionToken() {
    // This would typically use a proper cryptographic method
    // For now, return a mock token
    return 'session_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  /// Validate session token
  static bool validateSessionToken(String token) {
    // This would typically validate the token against server
    // For now, return true for mock tokens
    return token.startsWith('session_');
  }

  /// Refresh session token
  static Future<String?> refreshSessionToken() async {
    try {
      // This would typically refresh the token with the server
      await Future.delayed(const Duration(milliseconds: 500));
      return generateSessionToken();
    } catch (e) {
      debugPrint('Error refreshing session token: $e');
      return null;
    }
  }
}

/// Password strength enum
enum PasswordStrength {
  empty,
  weak,
  medium,
  strong,
}
