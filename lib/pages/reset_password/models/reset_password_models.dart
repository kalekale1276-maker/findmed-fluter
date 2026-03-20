/// Models and constants for reset password functionality
class ResetPasswordConstants {
  // UI labels
  static const String pageTitle = 'Reset Password';
  static const String emailLabel = 'Email';
  static const String otpLabel = 'OTP code';
  static const String newPasswordLabel = 'New Password';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String defaultPasswordLabel = 'Enter Default Password';
  static const String telegramChatIdLabel = 'Telegram Chat ID';
  
  // Button labels
  static const String requestResetLabel = 'Request Reset';
  static const String connectTelegramLabel = 'Connect Telegram';
  static const String requestAdminLabel = 'Request Admin';
  static const String getDefaultPasswordLabel = 'Get Default Password';
  static const String linkTelegramLabel = 'Link Telegram';
  static const String confirmResetLabel = 'Confirm Reset';
  static const String resendOtpLabel = 'Resend OTP';
  static const String changeAndSavePasswordLabel = 'Change and Save Password';
  static const String resetViaTelegramLabel = 'Reset via Telegram';
  static const String cancelLabel = 'Cancel';
  static const String copyLabel = 'Copy';
  static const String copyLinkLabel = 'Copy link';
  static const String copyUsernameLabel = 'Copy username';
  static const String copyPasswordLabel = 'Copy password';
  
  // Messages
  static const String checkingEmailMessage = 'Checking email...';
  static const String emailNotRegisteredMessage = 'Email not registered';
  static const String telegramLinkedMessage = 'Telegram successfully linked!';
  static const String telegramLinkCopiedMessage = 'Telegram link copied!';
  static const String telegramUsernameCopiedMessage = 'Bot username copied!';
  static const String passwordCopiedMessage = 'Password copied!';
  static const String defaultPasswordCorrectMessage = 'Default password is correct! You are now logged in.';
  static const String defaultPasswordIncorrectMessage = 'Default password is incorrect.';
  static const String passwordResetSuccessfulMessage = 'Password reset successful. Please login.';
  static const String chatIdAvailableMessage = 'Chat ID is available!';
  static const String waitingAdminResetMessage = 'Waiting for admin to reset your password. Once admin resets, the default password will be shown below.';
  static const String defaultPasswordMessage = 'Default password: ';
  
  // Telegram instructions
  static const String telegramBotLink = 'https://t.me/Findmed_Ethiopiabot';
  static const String telegramBotUsername = '@Findmed_Ethiopiabot';
  static const String telegramInstruction1 = '1. Open Telegram and search for our bot:';
  static const String telegramInstruction2 = '2. Start the bot and send /start.';
  static const String telegramInstruction3 = '3. Enter your Telegram Chat ID below:';
  
  // Error messages
  static const String enterValidEmailMessage = 'Enter a valid email before requesting reset.';
  static const String enterChatIdMessage = 'Enter your Telegram Chat ID';
  static const String chatIdAlreadyLinkedMessage = 'This chat ID is already linked to another account.';
  static const String failedToCheckChatIdMessage = 'Failed to check chat ID.';
  static const String failedToLinkTelegramMessage = 'Failed to link Telegram.';
  static const String failedToRequestAdminResetMessage = 'Failed to request admin reset.';
  static const String failedToRequestResetMessage = 'Request failed: ';
  static const String failedToDeliverOtpMessage = 'Failed to deliver OTP via Telegram. Contact admin.';
  static const String userNotLinkedToTelegramMessage = 'User not linked to Telegram. Please contact admin to reset your password.';
  static const String otpSentToTelegramMessage = 'Reset code sent to Telegram. Check your Telegram messages for the OTP.';
  static const String pleaseEnterBothPasswordFieldsMessage = 'Please enter both password fields.';
  static const String passwordsDoNotMatchMessage = 'Passwords do not match.';
  static const String failedToUpdatePasswordMessage = 'Failed to update password.';
  static const String errorPrefix = 'Error: ';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int otpLength = 6;
  
  // Animation durations
  static const int animationDurationMs = 300;
  static const int messageDisplayDuration = 3;
  static const int adminPollingIntervalSeconds = 2;
  static const int loginDelayMs = 800;
  
  // API endpoints
  static const String checkEmailEndpoint = '/users/check';
  static const String checkTelegramEndpoint = '/users/check-telegram';
  static const String registerTelegramEndpoint = '/users/telegram/register-contact';
  static const String requestAdminResetEndpoint = '/users/request-admin-reset';
  static const String requestResetEndpoint = '/users/request-reset';
  static const String confirmResetEndpoint = '/users/confirm-reset';
  static const String loginEndpoint = '/users/login';
  static const String profileEndpoint = '/users/profile';
}

/// Reset password step enum
enum ResetPasswordStep {
  emailEntry,
  telegramLinking,
  adminRequest,
  telegramOtp,
  adminPassword,
  completed,
}

/// Email verification status
enum EmailVerificationStatus {
  checking,
  exists,
  notExists,
  telegramLinked,
  telegramNotLinked,
  error,
}

/// Telegram linking status
enum TelegramLinkingStatus {
  idle,
  checking,
  available,
  notAvailable,
  linking,
  linked,
  error,
}

/// Admin reset status
enum AdminResetStatus {
  idle,
  requesting,
  waiting,
  passwordReady,
  completed,
  error,
}

/// Password reset model
class PasswordResetRequest {
  final String email;
  final String? otp;
  final String? newPassword;
  final String? telegramChatId;
  final String? adminDefaultPassword;
  final ResetPasswordStep currentStep;
  final DateTime? requestedAt;
  final DateTime? expiresAt;

  PasswordResetRequest({
    required this.email,
    this.otp,
    this.newPassword,
    this.telegramChatId,
    this.adminDefaultPassword,
    required this.currentStep,
    this.requestedAt,
    this.expiresAt,
  });

  /// Create copy with updated fields
  PasswordResetRequest copyWith({
    String? email,
    String? otp,
    String? newPassword,
    String? telegramChatId,
    String? adminDefaultPassword,
    ResetPasswordStep? currentStep,
    DateTime? requestedAt,
    DateTime? expiresAt,
  }) {
    return PasswordResetRequest(
      email: email ?? this.email,
      otp: otp ?? this.otp,
      newPassword: newPassword ?? this.newPassword,
      telegramChatId: telegramChatId ?? this.telegramChatId,
      adminDefaultPassword: adminDefaultPassword ?? this.adminDefaultPassword,
      currentStep: currentStep ?? this.currentStep,
      requestedAt: requestedAt ?? this.requestedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Check if request is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if request has valid OTP
  bool get hasValidOtp => otp != null && otp!.length == ResetPasswordConstants.otpLength;

  /// Check if request has valid password
  bool get hasValidPassword => 
      newPassword != null && 
      newPassword!.length >= ResetPasswordConstants.minPasswordLength &&
      newPassword!.length <= ResetPasswordConstants.maxPasswordLength;

  /// Get formatted requested date
  String get formattedRequestedAt {
    if (requestedAt == null) return '';
    return '${requestedAt!.day}/${requestedAt!.month}/${requestedAt!.year} ${requestedAt!.hour.toString().padLeft(2, '0')}:${requestedAt!.minute.toString().padLeft(2, '0')}';
  }
}

/// Telegram bot info model
class TelegramBotInfo {
  final String link;
  final String username;
  final String instructions;

  const TelegramBotInfo({
    required this.link,
    required this.username,
    required this.instructions,
  });

  /// Get default bot info
  factory TelegramBotInfo.defaultBot() {
    return const TelegramBotInfo(
      link: ResetPasswordConstants.telegramBotLink,
      username: ResetPasswordConstants.telegramBotUsername,
      instructions: 'FindMed Ethiopia Bot',
    );
  }
}

/// Reset password state model
class ResetPasswordState {
  final PasswordResetRequest? request;
  final EmailVerificationStatus emailStatus;
  final TelegramLinkingStatus telegramLinkingStatus;
  final AdminResetStatus adminResetStatus;
  final bool isLoading;
  final bool isViaTelegram;
  final String? adminResetPassword;
  final String? message;
  final List<String> messages;
  final Map<String, bool> passwordVisibility;

  const ResetPasswordState({
    this.request,
    this.emailStatus = EmailVerificationStatus.checking,
    this.telegramLinkingStatus = TelegramLinkingStatus.idle,
    this.adminResetStatus = AdminResetStatus.idle,
    this.isLoading = false,
    this.isViaTelegram = false,
    this.adminResetPassword,
    this.message,
    this.messages = const [],
    this.passwordVisibility = const {},
  });

  ResetPasswordState copyWith({
    PasswordResetRequest? request,
    EmailVerificationStatus? emailStatus,
    TelegramLinkingStatus? telegramLinkingStatus,
    AdminResetStatus? adminResetStatus,
    bool? isLoading,
    bool? isViaTelegram,
    String? adminResetPassword,
    String? message,
    List<String>? messages,
    Map<String, bool>? passwordVisibility,
  }) {
    return ResetPasswordState(
      request: request ?? this.request,
      emailStatus: emailStatus ?? this.emailStatus,
      telegramLinkingStatus: telegramLinkingStatus ?? this.telegramLinkingStatus,
      adminResetStatus: adminResetStatus ?? this.adminResetStatus,
      isLoading: isLoading ?? this.isLoading,
      isViaTelegram: isViaTelegram ?? this.isViaTelegram,
      adminResetPassword: adminResetPassword ?? this.adminResetPassword,
      message: message ?? this.message,
      messages: messages ?? this.messages,
      passwordVisibility: passwordVisibility ?? this.passwordVisibility,
    );
  }

  /// Clear message
  ResetPasswordState clearMessage() => copyWith(message: null);

  /// Set loading
  ResetPasswordState setLoading(bool loading) => copyWith(isLoading: loading, message: null);

  /// Set error
  ResetPasswordState setError(String error) => copyWith(isLoading: false, message: error);

  /// Add message
  ResetPasswordState addMessage(String message) {
    final updatedMessages = List<String>.from(messages)..add(message);
    return copyWith(messages: updatedMessages);
  }

  /// Remove message
  ResetPasswordState removeMessage(String message) {
    final updatedMessages = List<String>.from(messages)..remove(message);
    return copyWith(messages: updatedMessages);
  }

  /// Update password visibility
  ResetPasswordState updatePasswordVisibility(String field, bool visible) {
    final updatedVisibility = Map<String, bool>.from(passwordVisibility)..[field] = visible;
    return copyWith(passwordVisibility: updatedVisibility);
  }

  /// Check if has error
  bool get hasError => message != null;

  /// Check if is loading
  bool get isAnyLoading => isLoading;

  /// Check if email exists
  bool get emailExists => emailStatus == EmailVerificationStatus.exists;

  /// Check if email is checking
  bool get isEmailChecking => emailStatus == EmailVerificationStatus.checking;

  /// Check if telegram is linked
  bool get isTelegramLinked => emailStatus == EmailVerificationStatus.telegramLinked;

  /// Check if telegram linking is in progress
  bool get isTelegramLinking => telegramLinkingStatus == TelegramLinkingStatus.linking;

  /// Check if waiting for admin reset
  bool get isWaitingAdminReset => adminResetStatus == AdminResetStatus.waiting;

  /// Check if admin reset password is ready
  bool get isAdminPasswordReady => adminResetStatus == AdminResetStatus.passwordReady;

  /// Get password visibility
  bool getPasswordVisibility(String field, bool defaultValue) {
    return passwordVisibility[field] ?? defaultValue;
  }
}

/// Password validation result
class PasswordValidationResult {
  final bool isValid;
  final String? errorMessage;

  const PasswordValidationResult({required this.isValid, this.errorMessage});

  static const PasswordValidationResult valid = PasswordValidationResult(isValid: true);
  
  PasswordValidationResult.invalid(String message) 
      : isValid = false, errorMessage = message;

  /// Validate password
  static PasswordValidationResult validate(String password) {
    if (password.isEmpty) {
      return PasswordValidationResult.invalid('Password is required');
    }
    
    if (password.length < ResetPasswordConstants.minPasswordLength) {
      return PasswordValidationResult.invalid('Password must be at least ${ResetPasswordConstants.minPasswordLength} characters');
    }
    
    if (password.length > ResetPasswordConstants.maxPasswordLength) {
      return PasswordValidationResult.invalid('Password must be less than ${ResetPasswordConstants.maxPasswordLength} characters');
    }
    
    return const PasswordValidationResult.valid;
  }

  /// Validate password confirmation
  static PasswordValidationResult validateConfirmation(String password, String confirmation) {
    final passwordValidation = validate(password);
    if (!passwordValidation.isValid) {
      return passwordValidation;
    }
    
    if (password != confirmation) {
      return PasswordValidationResult.invalid(ResetPasswordConstants.passwordsDoNotMatchMessage);
    }
    
    return const PasswordValidationResult.valid;
  }
}

/// Email validation result
class EmailValidationResult {
  final bool isValid;
  final String? errorMessage;

  const EmailValidationResult({required this.isValid, this.errorMessage});

  static const EmailValidationResult valid = EmailValidationResult(isValid: true);
  
  EmailValidationResult.invalid(String message) 
      : isValid = false, errorMessage = message;

  /// Validate email
  static EmailValidationResult validate(String email) {
    if (email.trim().isEmpty) {
      return EmailValidationResult.invalid('Email is required');
    }
    
    if (!email.contains('@')) {
      return EmailValidationResult.invalid('Please enter a valid email address');
    }
    
    if (email.length < 5) {
      return EmailValidationResult.invalid('Email is too short');
    }
    
    return const EmailValidationResult.valid;
  }
}

/// OTP validation result
class OtpValidationResult {
  final bool isValid;
  final String? errorMessage;

  const OtpValidationResult({required this.isValid, this.errorMessage});

  static const OtpValidationResult valid = OtpValidationResult(isValid: true);
  
  OtpValidationResult.invalid(String message) 
      : isValid = false, errorMessage = message;

  /// Validate OTP
  static OtpValidationResult validate(String otp) {
    if (otp.trim().isEmpty) {
      return OtpValidationResult.invalid('OTP is required');
    }
    
    if (otp.length != ResetPasswordConstants.otpLength) {
      return OtpValidationResult.invalid('OTP must be ${ResetPasswordConstants.otpLength} digits');
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(otp)) {
      return OtpValidationResult.invalid('OTP must contain only digits');
    }
    
    return const OtpValidationResult.valid;
  }
}

/// Reset password result
class ResetPasswordResult {
  final bool success;
  final String? message;
  final ResetPasswordStep? nextStep;

  ResetPasswordResult({
    required this.success,
    this.message,
    this.nextStep,
  });

  factory ResetPasswordResult.success({
    String? message,
    ResetPasswordStep? nextStep,
  }) {
    return ResetPasswordResult(
      success: true,
      message: message,
      nextStep: nextStep,
    );
  }

  factory ResetPasswordResult.failure(String message) {
    return ResetPasswordResult(
      success: false,
      message: message,
    );
  }
}

/// Telegram chat ID validation result
class ChatIdValidationResult {
  final bool isValid;
  final bool isAvailable;
  final String? errorMessage;

  const ChatIdValidationResult({
    required this.isValid,
    required this.isAvailable,
    this.errorMessage,
  });

  static const ChatIdValidationResult validAvailable = ChatIdValidationResult(
    isValid: true,
    isAvailable: true,
  );
  
  static const ChatIdValidationResult validNotAvailable = ChatIdValidationResult(
    isValid: true,
    isAvailable: false,
  );

  ChatIdValidationResult.invalid(String message) 
      : isValid = false, isAvailable = false, errorMessage = message;

  /// Validate chat ID
  static ChatIdValidationResult validate(String chatId) {
    if (chatId.trim().isEmpty) {
      return ChatIdValidationResult.invalid('Chat ID is required');
    }
    
    if (!RegExp(r'^[0-9-]+$').hasMatch(chatId)) {
      return ChatIdValidationResult.invalid('Chat ID must contain only numbers and hyphens');
    }
    
    if (chatId.length < 5) {
      return ChatIdValidationResult.invalid('Chat ID is too short');
    }
    
    return const ChatIdValidationResult.validAvailable;
  }
}

/// Admin reset request model
class AdminResetRequest {
  final String email;
  final DateTime requestedAt;
  final String? adminResetPassword;
  final DateTime? adminResetPasswordExpires;
  final bool isCompleted;

  AdminResetRequest({
    required this.email,
    required this.requestedAt,
    this.adminResetPassword,
    this.adminResetPasswordExpires,
    this.isCompleted = false,
  });

  /// Check if admin reset password is valid
  bool get isPasswordValid {
    if (adminResetPassword == null || adminResetPasswordExpires == null) {
      return false;
    }
    
    return DateTime.now().isBefore(adminResetPasswordExpires!);
  }

  /// Get formatted expiry time
  String get formattedExpiryTime {
    if (adminResetPasswordExpires == null) return '';
    
    final now = DateTime.now();
    final expiry = adminResetPasswordExpires!;
    
    if (now.isAfter(expiry)) {
      return 'Expired';
    }
    
    final difference = expiry.difference(now);
    if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      return '${difference.inMinutes}m';
    }
  }
}

/// Reset password analytics
class ResetPasswordAnalytics {
  final int totalRequests;
  final int telegramResets;
  final int adminResets;
  final int successfulResets;
  final int failedResets;
  final double averageCompletionTime;
  final Map<ResetPasswordStep, int> stepDistribution;
  final DateTime lastUpdated;

  ResetPasswordAnalytics({
    required this.totalRequests,
    required this.telegramResets,
    required this.adminResets,
    required this.successfulResets,
    required this.failedResets,
    required this.averageCompletionTime,
    required this.stepDistribution,
    required this.lastUpdated,
  });

  /// Get success rate
  double get successRate {
    if (totalRequests == 0) return 0.0;
    return successfulResets / totalRequests;
  }

  /// Get telegram reset percentage
  double get telegramResetPercentage {
    if (totalRequests == 0) return 0.0;
    return telegramResets / totalRequests;
  }

  /// Get admin reset percentage
  double get adminResetPercentage {
    if (totalRequests == 0) return 0.0;
    return adminResets / totalRequests;
  }

  /// Check if has data
  bool get hasData => totalRequests > 0;
}
