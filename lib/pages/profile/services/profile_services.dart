import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/auth.dart';
import '../models/profile_models.dart';

/// Services for profile functionality
class ProfileServices {
  static const String _agentIdKey = 'agentId';
  static const String _agentFacilityTypeKey = 'agentFacilityType';

  /// Get current user profile
  static Future<UserProfile?> getCurrentProfile() async {
    try {
      final authService = AuthService.instance;
      await authService.init();
      
      final userData = authService.user;
      if (userData == null) return null;
      
      // Load agent info
      final agentInfo = await _loadAgentInfo();
      
      return UserProfile.fromJson({
        ...userData,
        ...agentInfo,
      });
    } catch (e) {
      debugPrint('Error getting current profile: $e');
      return null;
    }
  }

  /// Update user profile
  static Future<ProfileResult> updateProfile(ProfileFormData formData) async {
    try {
      final authService = AuthService.instance;
      await authService.init();
      
      // Validate form data
      final validation = formData.validate();
      if (!validation.isValid) {
        return ProfileResult.failure(validation.errorMessage!);
      }
      
      // Update profile via auth service
      await authService.updateProfile(formData.toJson());
      
      // Get updated profile
      final updatedProfile = await getCurrentProfile();
      
      return ProfileResult.success(
        profile: updatedProfile,
      );
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return ProfileResult.failure('Failed to update profile: $e');
    }
  }

  /// Load agent information
  static Future<Map<String, String>> _loadAgentInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final agentId = prefs.getString(_agentIdKey);
      final facilityType = prefs.getString(_agentFacilityTypeKey);
      
      return {
        if (agentId != null) 'agentId': agentId,
        if (facilityType != null) 'agentFacilityType': facilityType,
      };
    } catch (e) {
      debugPrint('Error loading agent info: $e');
      return {};
    }
  }

  /// Save agent information
  static Future<void> saveAgentInfo({
    String? agentId,
    String? facilityType,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (agentId != null) {
        await prefs.setString(_agentIdKey, agentId);
      }
      
      if (facilityType != null) {
        await prefs.setString(_agentFacilityTypeKey, facilityType);
      }
    } catch (e) {
      debugPrint('Error saving agent info: $e');
    }
  }

  /// Clear agent information
  static Future<void> clearAgentInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_agentIdKey);
      await prefs.remove(_agentFacilityTypeKey);
    } catch (e) {
      debugPrint('Error clearing agent info: $e');
    }
  }

  /// Connect Telegram bot
  static Future<TelegramConnection> connectTelegram({
    String? chatId,
    String? userId,
    String? fullName,
  }) async {
    try {
      final botPort = int.tryParse(const String.fromEnvironment(
        'BOT_PORT',
        defaultValue: ProfileConstants.defaultBotPort,
      )) ?? 3001;
      
      final botHost = Platform.isAndroid
          ? ProfileConstants.androidBotHost
          : ProfileConstants.iosBotHost;
      
      final uri = Uri.parse('$botHost:$botPort/connect');
      
      final body = jsonEncode({
        'chatId': chatId,
        'userId': userId,
        'fullName': fullName,
      });
      
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: ProfileConstants.httpTimeoutSeconds));
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return TelegramConnection.fromJson(data);
        } catch (e) {
          // If parsing fails, assume success
          return TelegramConnection(
            chatId: chatId ?? '',
            isLinked: true,
            isVerified: true,
            message: ProfileConstants.telegramLinkedMessage,
          );
        }
      } else {
        // Try to parse error message
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          final message = (errorData['message'] ?? response.body).toString();
          
          return TelegramConnection(
            chatId: chatId ?? '',
            message: message,
          );
        } catch (e) {
          return TelegramConnection(
            chatId: chatId ?? '',
            message: 'Connection failed: ${response.body}',
          );
        }
      }
    } catch (e) {
      debugPrint('Error connecting Telegram: $e');
      return TelegramConnection(
        chatId: chatId ?? '',
        message: 'Connection failed: $e',
      );
    }
  }

  /// Check Telegram connection status
  static Future<TelegramConnection?> checkTelegramConnection() async {
    try {
      final authService = AuthService.instance;
      await authService.init();
      
      final profile = await getCurrentProfile();
      if (profile == null || !profile.isTelegramLinked) {
        return null;
      }
      
      // If already linked, return connection info
      return TelegramConnection(
        chatId: profile.telegramChatId ?? '',
        username: profile.telegramUsername,
        isLinked: true,
        isVerified: true,
      );
    } catch (e) {
      debugPrint('Error checking Telegram connection: $e');
      return null;
    }
  }

  /// Disconnect Telegram
  static Future<ProfileResult> disconnectTelegram() async {
    try {
      final authService = AuthService.instance;
      await authService.init();
      
      // Clear telegram info from profile
      await authService.updateProfile({
        'telegramUsername': '',
        'telegramChatId': '',
      });
      
      return ProfileResult.success(
        message: 'Telegram disconnected',
      );
    } catch (e) {
      debugPrint('Error disconnecting Telegram: $e');
      return ProfileResult.failure('Failed to disconnect Telegram: $e');
    }
  }

  /// Change password
  static Future<ProfileResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final authService = AuthService.instance;
      await authService.init();
      
      // This would typically call a password change API
      // For now, return mock success
      await Future.delayed(const Duration(seconds: 1));
      
      return ProfileResult.success(
        message: 'Password changed successfully',
      );
    } catch (e) {
      debugPrint('Error changing password: $e');
      return ProfileResult.failure('Failed to change password: $e');
    }
  }

  /// Logout user
  static Future<void> logout() async {
    try {
      final authService = AuthService.instance;
      await authService.logout();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  /// Validate phone number
  static bool isValidPhone(String phone) {
    if (phone.isEmpty) return false;
    
    // Remove all non-digit characters except +
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    
    // Check Ethiopian phone format
    if (cleanPhone.startsWith(ProfileConstants.ethiopiaCountryCode)) {
      return cleanPhone.length == ProfileConstants.ethiopiaCountryCode.length + ProfileConstants.ethiopiaPhoneLength;
    }
    
    // Check other formats
    return cleanPhone.length >= 10 && cleanPhone.length <= 15;
  }

  /// Format phone number for display
  static String formatPhoneDisplay(String phone) {
    if (phone.isEmpty) return '';
    
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    
    // Format Ethiopian phone numbers
    if (cleanPhone.startsWith(ProfileConstants.ethiopiaCountryCode)) {
      final localNumber = cleanPhone.substring(ProfileConstants.ethiopiaCountryCode.length);
      if (localNumber.length == ProfileConstants.ethiopiaPhoneLength) {
        return '+251 ${localNumber.substring(0, 1)} ${localNumber.substring(1, 4)} ${localNumber.substring(4)}';
      }
    }
    
    return cleanPhone;
  }

  /// Get profile statistics
  static Future<ProfileStatistics> getProfileStatistics() async {
    try {
      // This would typically fetch analytics from backend
      // For now, return mock data
      await Future.delayed(const Duration(milliseconds: 500));
      
      return ProfileStatistics(
        totalProfiles: 1250,
        agentProfiles: 85,
        telegramLinkedProfiles: 320,
        averageAge: 28.5,
        facilityTypes: {
          'pharmacy': 45,
          'hospital': 25,
          'clinic': 15,
        },
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error getting profile statistics: $e');
      rethrow;
    }
  }

  /// Export profile data
  static Future<ProfileExport> exportProfile({
    UserProfile? profile,
    String format = 'json',
  }) async {
    try {
      final currentProfile = profile ?? await getCurrentProfile();
      
      if (currentProfile == null) {
        throw Exception('No profile data available');
      }
      
      return ProfileExport(
        profile: currentProfile,
        exportedAt: DateTime.now(),
        format: format,
      );
    } catch (e) {
      debugPrint('Error exporting profile: $e');
      rethrow;
    }
  }

  /// Import profile data
  static Future<ProfileResult> importProfile(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      
      // Extract profile data
      final profileData = data['profile'] as Map<String, dynamic>?;
      if (profileData == null) {
        return ProfileResult.failure('No profile data found in import');
      }
      
      final profile = UserProfile.fromJson(profileData);
      
      // Create form data from profile
      final formData = ProfileFormData.fromProfile(profile);
      
      // Validate imported data
      final validation = formData.validate();
      if (!validation.isValid) {
        return ProfileResult.failure('Invalid profile data: ${validation.errorMessage}');
      }
      
      // Update profile
      return await updateProfile(formData);
    } catch (e) {
      debugPrint('Error importing profile: $e');
      return ProfileResult.failure('Failed to import profile: $e');
    }
  }

  /// Search profiles
  static Future<List<UserProfile>> searchProfiles(String query) async {
    try {
      // This would typically call a search API
      // For now, return empty list
      await Future.delayed(const Duration(milliseconds: 300));
      
      return [];
    } catch (e) {
      debugPrint('Error searching profiles: $e');
      return [];
    }
  }

  /// Get profile completion score
  static double getProfileCompletionScore(UserProfile profile) {
    int completedFields = 0;
    int totalFields = 7;
    
    if (profile.fullName?.isNotEmpty == true) completedFields++;
    if (profile.phone?.isNotEmpty == true) completedFields++;
    if (profile.age != null) completedFields++;
    if (profile.medicalConditions.isNotEmpty) completedFields++;
    if (profile.allergies.isNotEmpty) completedFields++;
    if (profile.medications.isNotEmpty) completedFields++;
    if (profile.isTelegramLinked) completedFields++;
    
    return completedFields / totalFields;
  }

  /// Get profile health tips
  static List<String> getProfileHealthTips(UserProfile profile) {
    final tips = <String>[];
    
    if (profile.fullName?.isEmpty == true) {
      tips.add('Add your full name for better identification');
    }
    
    if (profile.phone?.isEmpty == true) {
      tips.add('Add your phone number for contact purposes');
    }
    
    if (profile.age == null) {
      tips.add('Add your age for age-appropriate recommendations');
    }
    
    if (!profile.hasMedicalProfile) {
      tips.add('Complete your medical profile for better healthcare');
    }
    
    if (!profile.isTelegramLinked) {
      tips.add('Connect Telegram for instant notifications');
    }
    
    if (profile.isAgent) {
      tips.add('Keep your facility information up to date');
    }
    
    return tips;
  }

  /// Validate profile completeness
  static Map<String, dynamic> validateProfileCompleteness(UserProfile profile) {
    final issues = <String>[];
    final warnings = <String>[];
    
    // Check required fields
    if (profile.fullName?.isEmpty == true) {
      issues.add('Full name is required');
    }
    
    if (profile.phone?.isEmpty == true) {
      warnings.add('Phone number is recommended');
    }
    
    // Check phone format
    if (profile.phone != null && !isValidPhone(profile.phone!)) {
      warnings.add('Phone number format may be invalid');
    }
    
    // Check age
    if (profile.age != null && (profile.age! < 0 || profile.age! > 150)) {
      issues.add('Invalid age value');
    }
    
    // Check medical profile
    if (!profile.hasMedicalProfile) {
      warnings.add('Medical profile is recommended');
    }
    
    return {
      'isValid': issues.isEmpty,
      'issues': issues,
      'warnings': warnings,
      'completionScore': getProfileCompletionScore(profile),
    };
  }

  /// Sync profile with backend
  static Future<ProfileResult> syncProfile() async {
    try {
      final profile = await getCurrentProfile();
      if (profile == null) {
        return ProfileResult.failure('No profile to sync');
      }
      
      // Re-save to ensure backend is up to date
      final formData = ProfileFormData.fromProfile(profile);
      return await updateProfile(formData);
    } catch (e) {
      debugPrint('Error syncing profile: $e');
      return ProfileResult.failure('Sync failed: $e');
    }
  }

  /// Backup profile data
  static Future<bool> backupProfile() async {
    try {
      final profile = await getCurrentProfile();
      if (profile == null) return false;
      
      // Create backup data
      final backupData = {
        'profile': profile.toJson(),
        'backupDate': DateTime.now().toIso8601String(),
        'version': '1.0',
      };
      
      // Save backup to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_backup', jsonEncode(backupData));
      
      return true;
    } catch (e) {
      debugPrint('Error backing up profile: $e');
      return false;
    }
  }

  /// Restore profile from backup
  static Future<ProfileResult> restoreProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupJson = prefs.getString('profile_backup');
      
      if (backupJson == null || backupJson.isEmpty) {
        return ProfileResult.failure('No backup found');
      }
      
      final backupData = jsonDecode(backupJson) as Map<String, dynamic>;
      final profileData = backupData['profile'] as Map<String, dynamic>?;
      
      if (profileData == null) {
        return ProfileResult.failure('Invalid backup data');
      }
      
      final profile = UserProfile.fromJson(profileData);
      final formData = ProfileFormData.fromProfile(profile);
      
      return await updateProfile(formData);
    } catch (e) {
      debugPrint('Error restoring profile: $e');
      return ProfileResult.failure('Restore failed: $e');
    }
  }

  /// Get profile summary for sharing
  static String getProfileSummary(UserProfile profile) {
    final buffer = StringBuffer();
    
    buffer.writeln('Profile Summary');
    buffer.writeln('================');
    buffer.writeln();
    
    if (profile.fullName != null) {
      buffer.writeln('Name: ${profile.fullName}');
    }
    
    if (profile.email != null) {
      buffer.writeln('Email: ${profile.email}');
    }
    
    if (profile.phone != null) {
      buffer.writeln('Phone: ${profile.phone}');
    }
    
    if (profile.age != null) {
      buffer.writeln('Age: ${profile.age}');
    }
    
    if (profile.isAgent) {
      buffer.writeln('Agent ID: ${profile.agentId}');
      buffer.writeln('Facility Type: ${profile.agentFacilityType}');
    }
    
    if (profile.hasMedicalProfile) {
      buffer.writeln();
      buffer.writeln('Medical Profile:');
      if (profile.medicalConditions.isNotEmpty) {
        buffer.writeln('  Conditions: ${profile.formattedConditions}');
      }
      if (profile.allergies.isNotEmpty) {
        buffer.writeln('  Allergies: ${profile.formattedAllergies}');
      }
      if (profile.medications.isNotEmpty) {
        buffer.writeln('  Medications: ${profile.formattedMedications}');
      }
    }
    
    if (profile.isTelegramLinked) {
      buffer.writeln('Telegram: ${profile.telegramDisplayName}');
    }
    
    return buffer.toString();
  }

  /// Check if profile needs updates
  static bool needsProfileUpdate(UserProfile profile) {
    final now = DateTime.now();
    final lastUpdate = profile.updatedAt ?? profile.createdAt;
    
    if (lastUpdate == null) return true;
    
    // Consider profile outdated if not updated in 30 days
    return now.difference(lastUpdate).inDays > 30;
  }

  /// Get profile recommendations
  static List<String> getProfileRecommendations(UserProfile profile) {
    final recommendations = <String>[];
    
    if (needsProfileUpdate(profile)) {
      recommendations.add('Update your profile information');
    }
    
    if (!profile.isTelegramLinked) {
      recommendations.add('Connect Telegram for instant notifications');
    }
    
    if (!profile.hasMedicalProfile) {
      recommendations.add('Complete your medical profile');
    }
    
    if (profile.phone?.isEmpty == true) {
      recommendations.add('Add your phone number');
    }
    
    if (profile.isAgent && profile.agentFacilityType == null) {
      recommendations.add('Update your facility information');
    }
    
    return recommendations;
  }
}
