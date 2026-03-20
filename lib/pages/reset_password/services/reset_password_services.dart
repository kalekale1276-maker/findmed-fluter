import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../services/api.dart';
import '../models/reset_password_models.dart';

/// Services for reset password functionality
class ResetPasswordServices {
  static const String _checkEmailEndpoint = ResetPasswordConstants.checkEmailEndpoint;
  static const String _checkTelegramEndpoint = ResetPasswordConstants.checkTelegramEndpoint;
  static const String _registerTelegramEndpoint = ResetPasswordConstants.registerTelegramEndpoint;
  static const String _requestAdminResetEndpoint = ResetPasswordConstants.requestAdminResetEndpoint;
  static const String _requestResetEndpoint = ResetPasswordConstants.requestResetEndpoint;
  static const String _confirmResetEndpoint = ResetPasswordConstants.confirmResetEndpoint;
  static const String _loginEndpoint = ResetPasswordConstants.loginEndpoint;
  static const String _profileEndpoint = ResetPasswordConstants.profileEndpoint;

  /// Check if email is registered and Telegram status
  static Future<Map<String, dynamic>> checkEmailAndTelegram(String email) async {
    try {
      final response = await Api.get(_checkEmailEndpoint, params: {'email': email});
      
      return {
        'exists': response['exists'] == true,
        'telegramLinked': response['telegramLinked'] == true,
        'telegramChatId': response['telegramChatId'],
        'telegramUsername': response['telegramUsername'],
      };
    } catch (e) {
      debugPrint('Error checking email: $e');
      rethrow;
    }
  }

  /// Check if Telegram chat ID is available
  static Future<ChatIdValidationResult> checkChatIdAvailability(String chatId, String email) async {
    try {
      final response = await Api.get(_checkTelegramEndpoint, params: {'chatId': chatId});
      
      if (response['linked'] == true && response['email'] != email) {
        return ChatIdValidationResult.validNotAvailable;
      }
      
      return const ChatIdValidationResult.validAvailable;
    } catch (e) {
      debugPrint('Error checking chat ID: $e');
      return ChatIdValidationResult.invalid(ResetPasswordConstants.failedToCheckChatIdMessage);
    }
  }

  /// Link Telegram account
  static Future<ResetPasswordResult> linkTelegram({
    required String email,
    required String chatId,
    String? telegramUsername,
  }) async {
    try {
      final response = await Api.post(_registerTelegramEndpoint, {
        'email': email.trim(),
        'chatId': chatId.trim(),
        'telegramUsername': telegramUsername,
      });
      
      if (response['ok'] == true) {
        return ResetPasswordResult.success(
          message: ResetPasswordConstants.telegramLinkedMessage,
          nextStep: ResetPasswordStep.telegramOtp,
        );
      } else {
        return ResetPasswordResult.failure(
          response['message'] ?? ResetPasswordConstants.failedToLinkTelegramMessage,
        );
      }
    } catch (e) {
      debugPrint('Error linking Telegram: $e');
      
      final message = e.toString().contains('already linked')
          ? ResetPasswordConstants.chatIdAlreadyLinkedMessage
          : ResetPasswordConstants.failedToLinkTelegramMessage;
      
      return ResetPasswordResult.failure(message);
    }
  }

  /// Request admin password reset
  static Future<ResetPasswordResult> requestAdminReset(String email) async {
    try {
      final response = await Api.post(_requestAdminResetEndpoint, {'email': email});
      
      if (response['ok'] == true) {
        return ResetPasswordResult.success(
          message: ResetPasswordConstants.waitingAdminResetMessage,
          nextStep: ResetPasswordStep.adminPassword,
        );
      } else {
        return ResetPasswordResult.failure(
          response['message'] ?? ResetPasswordConstants.failedToRequestAdminResetMessage,
        );
      }
    } catch (e) {
      debugPrint('Error requesting admin reset: $e');
      return ResetPasswordResult.failure(ResetPasswordConstants.failedToRequestAdminResetMessage);
    }
  }

  /// Poll for admin reset password
  static Future<String?> pollAdminResetPassword(String email) async {
    try {
      final response = await Api.get(_checkEmailEndpoint, params: {'email': email});
      
      final password = response['adminResetPassword'];
      final expires = response['adminResetPasswordExpires'];
      
      if (password != null && expires != null) {
        final expiry = DateTime.tryParse(expires);
        final now = DateTime.now();
        
        if (expiry != null && now.isBefore(expiry)) {
          return password;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error polling admin reset password: $e');
      return null;
    }
  }

  /// Request password reset via Telegram
  static Future<ResetPasswordResult> requestTelegramReset(String email) async {
    try {
      final response = await Api.post(_requestResetEndpoint, {'email': email});
      
      final via = response['via'] as String? ?? 'none';
      final ok = response['ok'] == true;
      final chatId = response['telegramChatId'] ?? '';
      final username = response['telegramUsername'] ?? '';
      
      if (via == 'telegram' && ok) {
        String message;
        if (username.isNotEmpty) {
          message = 'Reset code sent to @$username on Telegram. Check your Telegram messages for the OTP.';
        } else {
          message = 'Reset code sent to your Telegram (chat id: $chatId). Check your Telegram messages for the OTP.';
        }
        
        return ResetPasswordResult.success(
          message: message,
          nextStep: ResetPasswordStep.telegramOtp,
        );
      } else if (via == 'telegram' && !ok) {
        return ResetPasswordResult.failure(
          response['message'] ?? ResetPasswordConstants.failedToDeliverOtpMessage,
        );
      } else {
        return ResetPasswordResult.failure(
          response['message'] ?? ResetPasswordConstants.userNotLinkedToTelegramMessage,
        );
      }
    } catch (e) {
      debugPrint('Error requesting Telegram reset: $e');
      
      String message = e.toString();
      try {
        final raw = message.replaceFirst('Exception: ', '').trim();
        final parsed = jsonDecode(raw);
        if (parsed is Map && parsed['message'] != null) {
          message = parsed['message'].toString();
        } else {
          message = raw;
        }
      } catch (_) {}
      
      return ResetPasswordResult.failure('${ResetPasswordConstants.failedToRequestResetMessage}$message');
    }
  }

  /// Confirm password reset with OTP
  static Future<ResetPasswordResult> confirmReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await Api.post(_confirmResetEndpoint, {
        'email': email.trim(),
        'otp': otp.trim(),
        'newPassword': newPassword,
      });
      
      if (response['ok'] == true) {
        return ResetPasswordResult.success(
          message: ResetPasswordConstants.passwordResetSuccessfulMessage,
          nextStep: ResetPasswordStep.completed,
        );
      } else {
        return ResetPasswordResult.failure(response.toString());
      }
    } catch (e) {
      debugPrint('Error confirming reset: $e');
      return ResetPasswordResult.failure(e.toString());
    }
  }

  /// Verify admin default password
  static Future<bool> verifyAdminDefaultPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await Api.post(_loginEndpoint, {
        'email': email.trim(),
        'password': password.trim(),
      });
      
      return response['token'] != null && response['id'] != null;
    } catch (e) {
      debugPrint('Error verifying admin password: $e');
      return false;
    }
  }

  /// Change password using admin default password
  static Future<ResetPasswordResult> changePasswordWithAdmin({
    required String email,
    required String adminPassword,
    required String newPassword,
  }) async {
    try {
      // Authenticate with admin default password
      final loginResponse = await Api.post(_loginEndpoint, {
        'email': email.trim(),
        'password': adminPassword.trim(),
      });
      
      if (loginResponse['token'] == null || loginResponse['id'] == null) {
        return ResetPasswordResult.failure(ResetPasswordConstants.defaultPasswordIncorrectMessage);
      }
      
      // Update password with token
      final updateResponse = await Api.post(
        _profileEndpoint,
        {
          'id': loginResponse['id'],
          'password': newPassword,
        },
        headers: {'Authorization': 'Bearer ${loginResponse['token']}'},
      );
      
      if ((updateResponse['ok'] == true) || (updateResponse['token'] != null)) {
        return ResetPasswordResult.success(
          message: 'Password changed successfully',
          nextStep: ResetPasswordStep.completed,
        );
      } else {
        return ResetPasswordResult.failure(ResetPasswordConstants.failedToUpdatePasswordMessage);
      }
    } catch (e) {
      debugPrint('Error changing password with admin: $e');
      
      String message = e.toString();
      if (message.contains('Invalid credentials')) {
        message = ResetPasswordConstants.defaultPasswordIncorrectMessage;
      }
      
      return ResetPasswordResult.failure('${ResetPasswordConstants.errorPrefix}$message');
    }
  }

  /// Validate email format
  static EmailValidationResult validateEmail(String email) {
    return EmailValidationResult.validate(email);
  }

  /// Validate password
  static PasswordValidationResult validatePassword(String password) {
    return PasswordValidationResult.validate(password);
  }

  /// Validate password confirmation
  static PasswordValidationResult validatePasswordConfirmation(String password, String confirmation) {
    return PasswordValidationResult.validateConfirmation(password, confirmation);
  }

  /// Validate OTP
  static OtpValidationResult validateOtp(String otp) {
    return OtpValidationResult.validate(otp);
  }

  /// Validate chat ID
  static ChatIdValidationResult validateChatId(String chatId) {
    return ChatIdValidationResult.validate(chatId);
  }

  /// Format error message
  static String formatErrorMessage(String error) {
    try {
      final raw = error.replaceFirst('Exception: ', '').trim();
      final parsed = jsonDecode(raw);
      if (parsed is Map && parsed['message'] != null) {
        return parsed['message'].toString();
      } else {
        return raw;
      }
    } catch (_) {
      return error;
    }
  }

  /// Get reset password analytics
  static Future<ResetPasswordAnalytics> getAnalytics() async {
    try {
      // In a real app, this would fetch from analytics API
      // For now, return mock data
      await Future.delayed(const Duration(milliseconds: 500));
      
      return ResetPasswordAnalytics(
        totalRequests: 1250,
        telegramResets: 850,
        adminResets: 400,
        successfulResets: 1180,
        failedResets: 70,
        averageCompletionTime: 3.5,
        stepDistribution: {
          ResetPasswordStep.emailEntry: 1250,
          ResetPasswordStep.telegramLinking: 150,
          ResetPasswordStep.adminRequest: 400,
          ResetPasswordStep.telegramOtp: 850,
          ResetPasswordStep.adminPassword: 400,
          ResetPasswordStep.completed: 1180,
        },
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error getting analytics: $e');
      rethrow;
    }
  }

  /// Get reset password recommendations
  static List<String> getRecommendations(ResetPasswordAnalytics analytics) {
    final recommendations = <String>[];
    
    if (analytics.telegramResetPercentage < 0.7) {
      recommendations.add('Consider promoting Telegram integration for faster password resets');
    }
    
    if (analytics.averageCompletionTime > 5.0) {
      recommendations.add('Average completion time is high - consider streamlining the process');
    }
    
    if (analytics.successRate < 0.9) {
      recommendations.add('Success rate could be improved - review failed reset attempts');
    }
    
    return recommendations;
  }

  /// Get reset password statistics
  static Map<String, dynamic> getStatistics(ResetPasswordAnalytics analytics) {
    return {
      'totalRequests': analytics.totalRequests,
      'telegramResets': analytics.telegramResets,
      'adminResets': analytics.adminResets,
      'successfulResets': analytics.successfulResets,
      'failedResets': analytics.failedResets,
      'successRate': (analytics.successRate * 100).toStringAsFixed(1) + '%',
      'telegramResetPercentage': (analytics.telegramResetPercentage * 100).toStringAsFixed(1) + '%',
      'adminResetPercentage': (analytics.adminResetPercentage * 100).toStringAsFixed(1) + '%',
      'averageCompletionTime': analytics.averageCompletionTime.toStringAsFixed(1) + ' minutes',
      'stepDistribution': analytics.stepDistribution.map((k, v) => MapEntry(k.toString(), v)),
      'recommendations': getRecommendations(analytics),
      'insights': {
        'mostUsedMethod': analytics.telegramResets > analytics.adminResets ? 'Telegram' : 'Admin',
        'completionRate': (analytics.successRate * 100).toStringAsFixed(1) + '%',
        'efficiency': analytics.averageCompletionTime < 5.0 ? 'Good' : 'Needs Improvement',
      },
    };
  }

  /// Create admin reset request tracker
  static Stream<String?> createAdminResetTracker(String email) {
    return Stream.periodic(
      const Duration(seconds: ResetPasswordConstants.adminPollingIntervalSeconds),
      (_) async => await pollAdminResetPassword(email),
    ).where((password) => password != null);
  }

  /// Validate reset flow completion
  static bool isResetFlowCompleted(ResetPasswordStep currentStep) {
    return currentStep == ResetPasswordStep.completed;
  }

  /// Get next step in reset flow
  static ResetPasswordStep getNextStep(ResetPasswordStep currentStep, bool isTelegramLinked) {
    switch (currentStep) {
      case ResetPasswordStep.emailEntry:
        return isTelegramLinked ? ResetPasswordStep.telegramOtp : ResetPasswordStep.telegramLinking;
      case ResetPasswordStep.telegramLinking:
        return ResetPasswordStep.adminRequest;
      case ResetPasswordStep.adminRequest:
        return ResetPasswordStep.adminPassword;
      case ResetPasswordStep.telegramOtp:
        return ResetPasswordStep.completed;
      case ResetPasswordStep.adminPassword:
        return ResetPasswordStep.completed;
      case ResetPasswordStep.completed:
        return ResetPasswordStep.completed;
    }
  }

  /// Check if step requires user input
  static bool stepRequiresInput(ResetPasswordStep step) {
    switch (step) {
      case ResetPasswordStep.emailEntry:
      case ResetPasswordStep.telegramLinking:
      case ResetPasswordStep.telegramOtp:
      case ResetPasswordStep.adminPassword:
        return true;
      case ResetPasswordStep.adminRequest:
      case ResetPasswordStep.completed:
        return false;
    }
  }

  /// Get step description
  static String getStepDescription(ResetPasswordStep step) {
    switch (step) {
      case ResetPasswordStep.emailEntry:
        return 'Enter your email address';
      case ResetPasswordStep.telegramLinking:
        return 'Link your Telegram account';
      case ResetPasswordStep.adminRequest:
        return 'Request admin password reset';
      case ResetPasswordStep.telegramOtp:
        return 'Enter OTP from Telegram';
      case ResetPasswordStep.adminPassword:
        return 'Use admin default password';
      case ResetPasswordStep.completed:
        return 'Password reset completed';
    }
  }

  /// Get step icon
  static String getStepIcon(ResetPasswordStep step) {
    switch (step) {
      case ResetPasswordStep.emailEntry:
        return 'email';
      case ResetPasswordStep.telegramLinking:
        return 'telegram';
      case ResetPasswordStep.adminRequest:
        return 'admin';
      case ResetPasswordStep.telegramOtp:
        return 'otp';
      case ResetPasswordStep.adminPassword:
        return 'password';
      case ResetPasswordStep.completed:
        return 'done';
    }
  }

  /// Export reset password data
  static String exportAnalytics(ResetPasswordAnalytics analytics) {
    final data = {
      'analytics': {
        'totalRequests': analytics.totalRequests,
        'telegramResets': analytics.telegramResets,
        'adminResets': analytics.adminResets,
        'successfulResets': analytics.successfulResets,
        'failedResets': analytics.failedResets,
        'successRate': analytics.successRate,
        'averageCompletionTime': analytics.averageCompletionTime,
        'stepDistribution': analytics.stepDistribution.map((k, v) => MapEntry(k.toString(), v)),
      },
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
    
    return _encodeJson(data);
  }

  /// Simple JSON encoder (avoiding dart:convert dependency)
  static String _encodeJson(Map<String, dynamic> data) {
    // This is a simplified JSON encoder for demonstration
    // In a real app, you would use dart:convert
    return '{\n'
        '  "analytics": {\n'
        '    "totalRequests": ${data['analytics']['totalRequests']},\n'
        '    "telegramResets": ${data['analytics']['telegramResets']},\n'
        '    "adminResets": ${data['analytics']['adminResets']},\n'
        '    "successfulResets": ${data['analytics']['successfulResets']},\n'
        '    "failedResets": ${data['analytics']['failedResets']},\n'
        '    "successRate": ${data['analytics']['successRate']},\n'
        '    "averageCompletionTime": ${data['analytics']['averageCompletionTime']},\n'
        '    "stepDistribution": {}\n'
        '  },\n'
        '  "exportedAt": "${data['exportedAt']}",\n'
        '  "version": "${data['version']}"\n'
        '}';
  }

  /// Simulate real-time admin reset updates
  static Stream<AdminResetRequest> simulateAdminResetUpdates(String email) {
    return Stream.periodic(const Duration(seconds: 3), (_) {
      // Simulate random admin reset updates
      final now = DateTime.now();
      final random = now.millisecondsSinceEpoch % 10;
      
      if (random < 3) {
        return AdminResetRequest(
          email: email,
          requestedAt: now.subtract(const Duration(minutes: 5)),
          adminResetPassword: 'temp123456',
          adminResetPasswordExpires: now.add(const Duration(minutes: 10)),
        );
      }
      
      return AdminResetRequest(
        email: email,
        requestedAt: now.subtract(const Duration(minutes: 5)),
      );
    });
  }

  /// Get reset password health metrics
  static Map<String, dynamic> getHealthMetrics(ResetPasswordAnalytics analytics) {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    
    return {
      'overallHealth': analytics.successRate > 0.9 ? 'Excellent' : 'Good',
      'telegramHealth': analytics.telegramResetPercentage > 0.7 ? 'Good' : 'Needs Attention',
      'adminHealth': analytics.adminResetPercentage < 0.5 ? 'Good' : 'High Load',
      'speedHealth': analytics.averageCompletionTime < 5.0 ? 'Fast' : 'Slow',
      'recommendations': getRecommendations(analytics),
      'metrics': {
        'successRate': (analytics.successRate * 100).toStringAsFixed(1) + '%',
        'telegramUsage': (analytics.telegramResetPercentage * 100).toStringAsFixed(1) + '%',
        'adminLoad': (analytics.adminResetPercentage * 100).toStringAsFixed(1) + '%',
        'averageTime': analytics.averageCompletionTime.toStringAsFixed(1) + ' min',
      },
    };
  }

  /// Create reset password session
  static Map<String, dynamic> createSession(String email) {
    return {
      'sessionId': DateTime.now().millisecondsSinceEpoch.toString(),
      'email': email,
      'startedAt': DateTime.now().toIso8601String(),
      'currentStep': ResetPasswordStep.emailEntry.toString(),
      'completedAt': null,
      'method': null,
    };
  }

  /// Update session step
  static Map<String, dynamic> updateSessionStep(
    Map<String, dynamic> session,
    ResetPasswordStep step,
  ) {
    return {
      ...session,
      'currentStep': step.toString(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Complete session
  static Map<String, dynamic> completeSession(
    Map<String, dynamic> session,
    String method,
  ) {
    return {
      ...session,
      'completedAt': DateTime.now().toIso8601String(),
      'method': method,
      'currentStep': ResetPasswordStep.completed.toString(),
    };
  }
}
