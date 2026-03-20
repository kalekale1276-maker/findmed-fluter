/// Models and constants for authentication forms
class AuthConstants {
  // Form validation rules
  static const int minPasswordLength = 6;
  static const int minRegisterPasswordLength = 8;
  static const int minAge = 10;
  static const int maxAge = 100;
  static const int minNameLength = 2;
  static const int minPhoneLength = 9;
  
  // Email checking debounce time
  static const int emailCheckDebounceMs = 500;
  
  // Country codes
  static const List<CountryCode> countryCodes = [
    CountryCode(code: '+251', flag: '🇪🇹', name: 'Ethiopia'),
    CountryCode(code: '+1', flag: '🇺🇸', name: 'United States'),
    CountryCode(code: '+44', flag: '🇬🇧', name: 'United Kingdom'),
    CountryCode(code: '+91', flag: '🇮🇳', name: 'India'),
  ];
  
  // Password strength requirements
  static const String passwordPattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$';
  static const String specialCharsPattern = r'[!@#\$&*~]';
  static const String uppercasePattern = r'[A-Z]';
  static const String lowercasePattern = r'[a-z]';
  static const String digitPattern = r'\d';
}

/// Country code model
class CountryCode {
  final String code;
  final String flag;
  final String name;

  const CountryCode({
    required this.code,
    required this.flag,
    required this.name,
  });
}

/// Email check result model
class EmailCheckResult {
  final bool exists;
  final bool telegramLinked;
  final String? telegramUsername;
  final String? note;

  EmailCheckResult({
    required this.exists,
    this.telegramLinked = false,
    this.telegramUsername,
    this.note,
  });

  factory EmailCheckResult.fromJson(Map<String, dynamic> json) {
    final exists = json['exists'] == true;
    final telegramLinked = json['telegramLinked'] == true;
    final telegramUsername = json['telegramUsername'] as String?;
    
    String? note;
    if (exists) {
      if (telegramLinked && telegramUsername != null && telegramUsername.isNotEmpty) {
        note = 'Registered; Telegram linked: @$telegramUsername';
      } else if (telegramLinked) {
        note = 'Registered; Telegram linked';
      } else {
        note = 'Registered';
      }
    }
    
    return EmailCheckResult(
      exists: exists,
      telegramLinked: telegramLinked,
      telegramUsername: telegramUsername,
      note: note,
    );
  }
}

/// Password strength model
class PasswordStrength {
  final String label;
  final Color color;
  final int score;

  const PasswordStrength({
    required this.label,
    required this.color,
    required this.score,
  });

  static PasswordStrength calculate(String password) {
    final hasUpper = RegExp(AuthConstants.uppercasePattern).hasMatch(password);
    final hasLower = RegExp(AuthConstants.lowercasePattern).hasMatch(password);
    final hasDigit = RegExp(AuthConstants.digitPattern).hasMatch(password);
    final hasSpecial = RegExp(AuthConstants.specialCharsPattern).hasMatch(password);
    
    if (password.length >= 12 && hasUpper && hasLower && hasDigit && hasSpecial) {
      return const PasswordStrength(label: 'Strong', color: Colors.green, score: 4);
    } else if (password.length >= 8 && hasUpper && hasLower && hasDigit) {
      return const PasswordStrength(label: 'Medium', color: Colors.orange, score: 3);
    } else if (password.length >= 6) {
      return const PasswordStrength(label: 'Weak', color: Colors.red, score: 2);
    } else {
      return const PasswordStrength(label: '', color: Colors.red, score: 1);
    }
  }

  static String? validatePassword(String password) {
    if (password.length < AuthConstants.minRegisterPasswordLength) {
      return 'Minimum 8 characters';
    }
    
    final hasUpper = RegExp(AuthConstants.uppercasePattern).hasMatch(password);
    if (!hasUpper) {
      return 'Include at least one uppercase letter';
    }
    
    final hasLower = RegExp(AuthConstants.lowercasePattern).hasMatch(password);
    if (!hasLower) {
      return 'Include at least one lowercase letter';
    }
    
    final hasDigit = RegExp(AuthConstants.digitPattern).hasMatch(password);
    if (!hasDigit) {
      return 'Include at least one number';
    }
    
    final hasSpecial = RegExp(AuthConstants.specialCharsPattern).hasMatch(password);
    if (!hasSpecial) {
      return 'Include at least one special character (!@#\$&*~)';
    }
    
    return null;
  }
}

/// Registration data model
class RegistrationData {
  final String fullName;
  final int age;
  final String email;
  final String password;
  final String phone;

  RegistrationData({
    required this.fullName,
    required this.age,
    required this.email,
    required this.password,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName.trim(),
      'age': age,
      'email': email.trim(),
      'password': password.trim(),
      'phone': phone.trim(),
    };
  }

  static String normalizePhone(String? raw) {
    if (raw == null) return '';
    var p = raw.trim();
    p = p.replaceAll(RegExp(r'[^0-9+]'), '');
    if (p.startsWith('0') && p.length == 10) return '+251${p.substring(1)}';
    if (p.startsWith('9') && p.length == 9) return '+251$p';
    return p;
  }
}

/// Form validation result
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  static const ValidationResult valid = ValidationResult(isValid: true);
  
  ValidationResult.invalid(String message) 
      : isValid = false, errorMessage = message;
}
