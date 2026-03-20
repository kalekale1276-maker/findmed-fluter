/// Import required icons
import 'package:flutter/material.dart';

/// Models and constants for login functionality
class LoginConstants {
  // UI labels
  static const String pageTitle = 'Login';
  static const String signInTitle = 'Sign in to continue';
  static const String welcomeTitle = 'Welcome Back';
  static const String subtitle = 'Access your FindMed account';
  
  // Form labels
  static const String emailLabel = 'Email';
  static const String emailHint = 'Enter your email';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'Enter your password';
  static const String forgotPasswordLabel = 'Forgot password?';
  static const String rememberMeLabel = 'Remember me';
  static const String loginButtonLabel = 'Sign In';
  static const String registerButtonLabel = 'Create Account';
  static const String guestButtonLabel = 'Continue as Guest';
  
  // Validation messages
  static const String emailRequiredError = 'Email is required';
  static const String emailInvalidError = 'Please enter a valid email';
  static const String passwordRequiredError = 'Password is required';
  static const String passwordMinLengthError = 'Password must be at least 6 characters';
  
  // Success messages
  static const String loginSuccessMessage = 'Login successful';
  static const String registrationSuccessMessage = 'Registration successful';
  
  // Error messages
  static const String loginFailedMessage = 'Login failed';
  static const String networkErrorMessage = 'Network error';
  static const String serverErrorMessage = 'Server error';
  static const String invalidCredentialsMessage = 'Invalid email or password';
  
  // Social login labels
  static const String googleLoginLabel = 'Sign in with Google';
  static const String facebookLoginLabel = 'Sign in with Facebook';
  static const String appleLoginLabel = 'Sign in with Apple';
  static const String twitterLoginLabel = 'Sign in with Twitter';
  
  // Alternative actions
  static const String noAccountText = "Don't have an account?";
  static const String haveAccountText = "Already have an account?";
  static const String signUpText = 'Sign up';
  static const String signInText = 'Sign in';
  
  // Feature descriptions
  static const String guestModeDescription = 'Limited access without registration';
  static const String socialLoginDescription = 'Quick sign in with your social account';
  
  // Animation durations
  static const int animationDurationMs = 300;
  static const int buttonAnimationDelayMs = 100;
  static const int formAnimationDelayMs = 200;
  
  // Form settings
  static const int passwordMinLength = 6;
  static const int emailMaxLength = 255;
  static const int passwordMaxLength = 128;
  
  // Card settings
  static const double cardMaxWidth = 720.0;
  static const double cardBorderRadius = 12.0;
  static const double cardElevation = 4.0;
}

/// Login form data model
class LoginFormData {
  final String email;
  final String password;
  final bool rememberMe;
  final bool isValid;

  LoginFormData({
    required this.email,
    required this.password,
    this.rememberMe = false,
    this.isValid = false,
  });

  LoginFormData copyWith({
    String? email,
    String? password,
    bool? rememberMe,
    bool? isValid,
  }) {
    return LoginFormData(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      isValid: isValid ?? this.isValid,
    );
  }

  /// Validate form data
  LoginFormData validate() {
    final isEmailValid = email.isNotEmpty && _isValidEmail(email);
    final isPasswordValid = password.isNotEmpty && password.length >= LoginConstants.passwordMinLength;
    
    return copyWith(isValid: isEmailValid && isPasswordValid);
  }

  /// Check if email is valid
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// Get validation errors
  Map<String, String> getValidationErrors() {
    final errors = <String, String>{};
    
    if (email.isEmpty) {
      errors['email'] = LoginConstants.emailRequiredError;
    } else if (!_isValidEmail(email)) {
      errors['email'] = LoginConstants.emailInvalidError;
    }
    
    if (password.isEmpty) {
      errors['password'] = LoginConstants.passwordRequiredError;
    } else if (password.length < LoginConstants.passwordMinLength) {
      errors['password'] = LoginConstants.passwordMinLengthError;
    }
    
    return errors;
  }

  /// Check if form is dirty (has been modified)
  bool get isDirty => email.isNotEmpty || password.isNotEmpty;

  /// Clear form
  LoginFormData clear() {
    return const LoginFormData(
      email: '',
      password: '',
      rememberMe: false,
      isValid: false,
    );
  }
}

/// Login state model
class LoginState {
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final bool isPasswordVisible;
  final bool rememberMe;
  final LoginFormData formData;
  final bool showGuestOption;

  const LoginState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.isPasswordVisible = false,
    this.rememberMe = false,
    this.formData = const LoginFormData(),
    this.showGuestOption = true,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool? isPasswordVisible,
    bool? rememberMe,
    LoginFormData? formData,
    bool? showGuestOption,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      rememberMe: rememberMe ?? this.rememberMe,
      formData: formData ?? this.formData,
      showGuestOption: showGuestOption ?? this.showGuestOption,
    );
  }

  /// Clear error
  LoginState clearError() => copyWith(error: null);

  /// Set loading
  LoginState setLoading(bool loading) => copyWith(isLoading: loading, error: null);

  /// Set submitting
  LoginState setSubmitting(bool submitting) => copyWith(isSubmitting: submitting, error: null);

  /// Set error
  LoginState setError(String error) => copyWith(isLoading: false, isSubmitting: false, error: error);

  /// Toggle password visibility
  LoginState togglePasswordVisibility() => copyWith(isPasswordVisible: !isPasswordVisible);

  /// Update remember me
  LoginState updateRememberMe(bool rememberMe) => copyWith(rememberMe: rememberMe);

  /// Update form data
  LoginState updateFormData(LoginFormData formData) => copyWith(formData: formData);

  /// Check if form is valid
  bool get isFormValid => formData.isValid;

  /// Check if has error
  bool get hasError => error != null;
}

/// Login result model
class LoginResult {
  final bool success;
  final String? message;
  final String? userId;
  final String? token;
  final Map<String, dynamic>? userData;

  LoginResult({
    required this.success,
    this.message,
    this.userId,
    this.token,
    this.userData,
  });

  factory LoginResult.success({
    String? message,
    String? userId,
    String? token,
    Map<String, dynamic>? userData,
  }) {
    return LoginResult(
      success: true,
      message: message ?? LoginConstants.loginSuccessMessage,
      userId: userId,
      token: token,
      userData: userData,
    );
  }

  factory LoginResult.failure(String message) {
    return LoginResult(
      success: false,
      message: message,
    );
  }
}

/// Social login provider model
class SocialLoginProvider {
  final String id;
  final String name;
  final String label;
  final IconData icon;
  final Color color;
  final bool isEnabled;

  SocialLoginProvider({
    required this.id,
    required this.name,
    required this.label,
    required this.icon,
    required this.color,
    this.isEnabled = true,
  });

  /// Get all available providers
  static List<SocialLoginProvider> getAllProviders() {
    return [
      SocialLoginProvider(
        id: 'google',
        name: 'Google',
        label: LoginConstants.googleLoginLabel,
        icon: Icons.g_mobiledata,
        color: const Color(0xFF4285F4),
      ),
      SocialLoginProvider(
        id: 'facebook',
        name: 'Facebook',
        label: LoginConstants.facebookLoginLabel,
        icon: Icons.facebook,
        color: const Color(0xFF1877F2),
      ),
      SocialLoginProvider(
        id: 'apple',
        name: 'Apple',
        label: LoginConstants.appleLoginLabel,
        icon: Icons.apple,
        color: const Color(0xFF000000),
      ),
      SocialLoginProvider(
        id: 'twitter',
        name: 'Twitter',
        label: LoginConstants.twitterLoginLabel,
        icon: Icons.alternate_email,
        color: const Color(0xFF1DA1F2),
        isEnabled: false, // Disabled by default
      ),
    ];
  }

  /// Get enabled providers
  static List<SocialLoginProvider> getEnabledProviders() {
    return getAllProviders().where((provider) => provider.isEnabled).toList();
  }
}

/// Login feature model
class LoginFeature {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  LoginFeature({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  /// Get all login features
  static List<LoginFeature> getAllFeatures() {
    return [
      LoginFeature(
        id: 'secure',
        title: 'Secure Login',
        description: 'Your data is protected with industry-standard encryption',
        icon: Icons.security,
        color: Colors.green,
      ),
      LoginFeature(
        id: 'quick',
        title: 'Quick Access',
        description: 'Save time with social login options',
        icon: Icons.speed,
        color: Colors.blue,
      ),
      LoginFeature(
        id: 'remember',
        title: 'Remember Me',
        description: 'Stay logged in on trusted devices',
        icon: Icons.save,
        color: Colors.orange,
      ),
      LoginFeature(
        id: 'guest',
        title: 'Guest Mode',
        description: 'Explore the app without registration',
        icon: Icons.person_outline,
        color: Colors.purple,
      ),
    ];
  }
}

/// Login analytics model
class LoginAnalytics {
  final int totalAttempts;
  final int successfulLogins;
  final int failedLogins;
  final Map<String, int> providerUsage;
  final DateTime lastLogin;
  final double averageTimeToLogin;

  LoginAnalytics({
    required this.totalAttempts,
    required this.successfulLogins,
    required this.failedLogins,
    required this.providerUsage,
    required this.lastLogin,
    required this.averageTimeToLogin,
  });

  /// Get success rate
  double get successRate {
    if (totalAttempts == 0) return 0.0;
    return successfulLogins / totalAttempts;
  }

  /// Get most used provider
  String? getMostUsedProvider() {
    if (providerUsage.isEmpty) return null;
    
    return providerUsage.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}
