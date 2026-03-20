import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../services/auth.dart';
import '../../../../services/api.dart';
import '../models/auth_models.dart';

/// Services for authentication functionality
class AuthServices {
  static final AuthService _auth = AuthService.instance;

  /// Check if email exists
  static Future<EmailCheckResult> checkEmail(String email) async {
    try {
      final res = await Api.get('/users/check', params: {'email': email});
      return EmailCheckResult.fromJson(res);
    } catch (e) {
      debugPrint('Error checking email: $e');
      rethrow;
    }
  }

  /// Login user
  static Future<void> login(String email, String password) async {
    try {
      await _auth.login(email.trim(), password.trim());
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  /// Register new user
  static Future<void> register(RegistrationData data) async {
    try {
      await _auth.register(data.toJson());
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }

  /// Validate email format
  static ValidationResult validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return ValidationResult.invalid('Enter a valid email');
    }
    if (!email.contains('@')) {
      return ValidationResult.invalid('Enter a valid email');
    }
    return ValidationResult.valid;
  }

  /// Validate password for login
  static ValidationResult validateLoginPassword(String? password) {
    if (password == null || password.length < AuthConstants.minPasswordLength) {
      return ValidationResult.invalid('Min ${AuthConstants.minPasswordLength} chars');
    }
    return ValidationResult.valid;
  }

  /// Validate full name
  static ValidationResult validateName(String? name) {
    if (name == null || name.trim().length < AuthConstants.minNameLength) {
      return ValidationResult.invalid('Enter name');
    }
    return ValidationResult.valid;
  }

  /// Validate age
  static ValidationResult validateAge(String? age) {
    if (age == null || age.isEmpty) {
      return ValidationResult.invalid('Enter age');
    }
    
    final n = int.tryParse(age);
    if (n == null) {
      return ValidationResult.invalid('Enter a valid number');
    }
    if (n < AuthConstants.minAge || n > AuthConstants.maxAge) {
      return ValidationResult.invalid('Age must be between ${AuthConstants.minAge} and ${AuthConstants.maxAge}');
    }
    return ValidationResult.valid;
  }

  /// Validate phone number
  static ValidationResult validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return ValidationResult.invalid('Enter phone number');
    }
    
    if (RegExp(r'[A-Za-z]').hasMatch(phone)) {
      return ValidationResult.invalid('Letters are not allowed in phone number');
    }
    
    if (phone.length < AuthConstants.minPhoneLength) {
      return ValidationResult.invalid('Enter a valid phone number');
    }
    return ValidationResult.valid;
  }

  /// Validate confirm password
  static ValidationResult validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword != password) {
      return ValidationResult.invalid('Passwords do not match');
    }
    return ValidationResult.valid;
  }

  /// Check if error is credential-related
  static bool isCredentialError(String? error) {
    if (error == null) return false;
    final lowerError = error.toLowerCase();
    return lowerError.contains('invalid credentials') || 
           lowerError.contains('wrong password');
  }

  /// Get error message for credential errors
  static String getCredentialErrorMessage() {
    return 'Invalid credentials or wrong password';
  }

  /// Check if email should be validated (debounced)
  static bool shouldValidateEmail(String email) {
    final val = email.trim();
    return val.isNotEmpty && val.contains('@');
  }

  /// Create email checking timer
  static Timer createEmailCheckTimer(VoidCallback callback) {
    return Timer(const Duration(milliseconds: AuthConstants.emailCheckDebounceMs), callback);
  }

  /// Get country codes
  static List<CountryCode> getCountryCodes() {
    return AuthConstants.countryCodes;
  }

  /// Get default country code
  static CountryCode getDefaultCountryCode() {
    return AuthConstants.countryCodes.first;
  }
}

/// Email checking manager
class EmailCheckManager {
  Timer? _timer;
  bool _isChecking = false;
  EmailCheckResult? _result;

  bool get isChecking => _isChecking;
  EmailCheckResult? get result => _result;

  void dispose() {
    _timer?.cancel();
  }

  Future<void> checkEmail(String email, VoidCallback onResult) async {
    _timer?.cancel();
    
    if (!AuthServices.shouldValidateEmail(email)) {
      _resetState();
      onResult();
      return;
    }

    _timer = AuthServices.createEmailCheckTimer(() async {
      _isChecking = true;
      _result = null;
      onResult();

      try {
        _result = await AuthServices.checkEmail(email.trim());
      } catch (e) {
        _result = null;
        debugPrint('Email check failed: $e');
      } finally {
        _isChecking = false;
        onResult();
      }
    });
  }

  void _resetState() {
    _isChecking = false;
    _result = null;
  }
}
