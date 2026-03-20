import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/auth.dart';
import '../../../../services/theme_service.dart';
import '../../../../services/admin_api.dart';
import '../../../../services/app_config.dart';
import '../models/settings_models.dart';

/// Services for settings functionality
class SettingsServices {
  static const String _notificationsKey = SettingsConstants.notificationsKey;
  static const String _darkThemeKey = SettingsConstants.darkThemeKey;
  static const String _analyticsKey = SettingsConstants.analyticsKey;

  /// Load settings from SharedPreferences
  static Future<Map<String, bool>> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      return {
        _notificationsKey: prefs.getBool(_notificationsKey) ?? SettingsConstants.defaultNotifications,
        _darkThemeKey: prefs.getBool(_darkThemeKey) ?? SettingsConstants.defaultDarkTheme,
        _analyticsKey: prefs.getBool(_analyticsKey) ?? SettingsConstants.defaultAnalytics,
      };
    } catch (e) {
      debugPrint('Error loading preferences: $e');
      rethrow;
    }
  }

  /// Save boolean preference
  static Future<bool> saveBoolPreference(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(key, value);
    } catch (e) {
      debugPrint('Error saving preference $key: $e');
      return false;
    }
  }

  /// Load notification setting
  static Future<bool> loadNotificationSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_notificationsKey) ?? SettingsConstants.defaultNotifications;
    } catch (e) {
      debugPrint('Error loading notification setting: $e');
      return SettingsConstants.defaultNotifications;
    }
  }

  /// Save notification setting
  static Future<bool> saveNotificationSetting(bool value) async {
    return await saveBoolPreference(_notificationsKey, value);
  }

  /// Load dark theme setting
  static Future<bool> loadDarkThemeSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_darkThemeKey) ?? SettingsConstants.defaultDarkTheme;
    } catch (e) {
      debugPrint('Error loading dark theme setting: $e');
      return SettingsConstants.defaultDarkTheme;
    }
  }

  /// Save dark theme setting
  static Future<bool> saveDarkThemeSetting(bool value) async {
    try {
      // Update ThemeService
      await ThemeService.instance.setDark(value);
      
      // Save to SharedPreferences
      return await saveBoolPreference(_darkThemeKey, value);
    } catch (e) {
      debugPrint('Error saving dark theme setting: $e');
      return false;
    }
  }

  /// Load analytics setting
  static Future<bool> loadAnalyticsSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_analyticsKey) ?? SettingsConstants.defaultAnalytics;
    } catch (e) {
      debugPrint('Error loading analytics setting: $e');
      return SettingsConstants.defaultAnalytics;
    }
  }

  /// Save analytics setting
  static Future<bool> saveAnalyticsSetting(bool value) async {
    return await saveBoolPreference(_analyticsKey, value);
  }

  /// Load server settings
  static Future<ServerSettings> loadServerSettings() async {
    try {
      final settings = await AdminApi.getSettings();
      return ServerSettings.fromJson(settings);
    } catch (e) {
      debugPrint('Error loading server settings: $e');
      rethrow;
    }
  }

  /// Sync server settings
  static Future<SettingsResult> syncServerSettings() async {
    try {
      final settings = await AdminApi.getSettings();
      return SettingsResult.success(
        message: SettingsConstants.serverSettingsSyncedMessage,
        data: settings,
      );
    } catch (e) {
      debugPrint('Error syncing server settings: $e');
      return SettingsResult.failure('${SettingsConstants.failedToFetchServerSettingsMessage}: $e');
    }
  }

  /// Get current user info
  static Map<String, dynamic>? getCurrentUser() {
    try {
      final authService = AuthService.instance;
      return authService.user;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  /// Check if user is logged in
  static bool isUserLoggedIn() {
    try {
      final authService = AuthService.instance;
      return authService.isLoggedIn;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  /// Initialize auth service
  static Future<void> initializeAuth() async {
    try {
      final authService = AuthService.instance;
      await authService.init();
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      rethrow;
    }
  }

  /// Get business mode status
  static bool getBusinessModeStatus() {
    try {
      return AppConfig.instance.userBusinessMode.value;
    } catch (e) {
      debugPrint('Error getting business mode status: $e');
      return SettingsConstants.defaultBusinessMode;
    }
  }

  /// Get effective business mode status
  static bool getEffectiveBusinessModeStatus() {
    try {
      return AppConfig.instance.effectiveBusinessMode.value;
    } catch (e) {
      debugPrint('Error getting effective business mode status: $e');
      return false;
    }
  }

  /// Update business mode
  static Future<SettingsResult> updateBusinessMode(bool value) async {
    try {
      debugPrint('User toggling Business Mode to: $value');
      debugPrint('Current admin businessMode: ${AppConfig.instance.businessMode.value}');
      
      if (value) {
        // Check backend
        try {
          await AppConfig.instance.updateBusinessMode();
          debugPrint('After fetch, admin businessMode: ${AppConfig.instance.businessMode.value}');
          
          if (AppConfig.instance.businessMode.value) {
            await AppConfig.instance.setUserBusinessMode(true);
            return SettingsResult.success(message: 'Business mode enabled');
          } else {
            return SettingsResult.failure(SettingsConstants.serviceNotAvailableMessage);
          }
        } catch (e) {
          debugPrint('Error fetching businessMode: $e');
          return SettingsResult.failure('${SettingsConstants.failedToCheckServiceMessage}: $e');
        }
      } else {
        await AppConfig.instance.setUserBusinessMode(false);
        return SettingsResult.success(message: 'Business mode disabled');
      }
    } catch (e) {
      debugPrint('Error updating business mode: $e');
      return SettingsResult.failure('Failed to update business mode: $e');
    }
  }

  /// Get backend host
  static String? getBackendHost() {
    try {
      return AppConfig.instance.host.value;
    } catch (e) {
      debugPrint('Error getting backend host: $e');
      return null;
    }
  }

  /// Set backend host
  static Future<SettingsResult> setBackendHost(String? host) async {
    try {
      await AppConfig.instance.setHost(host);
      
      if (host?.isEmpty == true) {
        return SettingsResult.success(message: SettingsConstants.backendHostClearedMessage);
      } else {
        return SettingsResult.success(message: SettingsConstants.backendHostSavedMessage);
      }
    } catch (e) {
      debugPrint('Error setting backend host: $e');
      return SettingsResult.failure('Failed to set backend host: $e');
    }
  }

  /// Validate backend host
  static SettingsValidationResult validateBackendHost(String host) {
    return SettingsValidationResult.validateBackendHost(host);
  }

  /// Clear local cache
  static Future<SettingsResult> clearLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      return SettingsResult.success(message: SettingsConstants.localCacheClearedMessage);
    } catch (e) {
      debugPrint('Error clearing local cache: $e');
      return SettingsResult.failure('Failed to clear cache: $e');
    }
  }

  /// Export settings data
  static Future<SettingsExport> exportSettings() async {
    try {
      final preferences = await loadPreferences();
      final serverSettings = await loadServerSettings();
      final user = getCurrentUser();
      
      final state = SettingsState(
        notifications: preferences[_notificationsKey] ?? SettingsConstants.defaultNotifications,
        darkTheme: preferences[_darkThemeKey] ?? SettingsConstants.defaultDarkTheme,
        analytics: preferences[_analyticsKey] ?? SettingsConstants.defaultAnalytics,
        businessMode: getBusinessModeStatus(),
        effectiveBusinessMode: getEffectiveBusinessModeStatus(),
        serverSettings: serverSettings.toJson(),
        isLoggedIn: isUserLoggedIn(),
        user: user,
        backendHost: getBackendHost(),
      );
      
      return SettingsExport(
        state: state,
        serverSettings: serverSettings,
        exportedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error exporting settings: $e');
      rethrow;
    }
  }

  /// Import settings data
  static Future<SettingsResult> importSettings(SettingsExport export) async {
    try {
      // Import notification setting
      await saveNotificationSetting(export.state.notifications);
      
      // Import analytics setting
      await saveAnalyticsSetting(export.state.analytics);
      
      // Import backend host
      if (export.state.backendHost != null) {
        await setBackendHost(export.state.backendHost);
      }
      
      return const SettingsResult.success(message: 'Settings imported successfully');
    } catch (e) {
      debugPrint('Error importing settings: $e');
      return SettingsResult.failure('Failed to import settings: $e');
    }
  }

  /// Reset all settings to defaults
  static Future<SettingsResult> resetSettings() async {
    try {
      // Reset preferences
      await saveNotificationSetting(SettingsConstants.defaultNotifications);
      await saveDarkThemeSetting(SettingsConstants.defaultDarkTheme);
      await saveAnalyticsSetting(SettingsConstants.defaultAnalytics);
      
      // Reset backend host
      await setBackendHost(null);
      
      // Reset business mode
      await updateBusinessMode(SettingsConstants.defaultBusinessMode);
      
      return const SettingsResult.success(message: 'Settings reset to defaults');
    } catch (e) {
      debugPrint('Error resetting settings: $e');
      return SettingsResult.failure('Failed to reset settings: $e');
    }
  }

  /// Get settings analytics
  static Future<SettingsAnalytics> getAnalytics() async {
    try {
      // This would typically fetch analytics from backend
      // For now, return mock data
      await Future.delayed(const Duration(milliseconds: 500));
      
      return SettingsAnalytics(
        totalSettings: 15,
        enabledSettings: 8,
        categoryCounts: {
          SettingCategory.account: 2,
          SettingCategory.preferences: 3,
          SettingCategory.medical: 1,
          SettingCategory.data: 2,
          SettingCategory.system: 5,
          SettingCategory.support: 2,
        },
        typeCounts: {
          SettingType.toggle: 4,
          SettingType.navigation: 6,
          SettingType.action: 3,
          SettingType.info: 2,
        },
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error getting settings analytics: $e');
      rethrow;
    }
  }

  /// Get settings summary
  static String getSettingsSummary(SettingsState state) {
    final buffer = StringBuffer();
    
    buffer.writeln('Settings Summary');
    buffer.writeln('================');
    buffer.writeln();
    
    buffer.writeln('Preferences:');
    buffer.writeln('  Notifications: ${state.notifications ? 'On' : 'Off'}');
    buffer.writeln('  Dark Theme: ${state.darkTheme ? 'On' : 'Off'}');
    buffer.writeln('  Analytics: ${state.analytics ? 'On' : 'Off'}');
    buffer.writeln();
    
    buffer.writeln('System:');
    buffer.writeln('  Business Mode: ${state.businessMode ? 'On' : 'Off'}');
    buffer.writeln('  Effective Business Mode: ${state.effectiveBusinessMode ? 'On' : 'Off'}');
    buffer.writeln('  Backend Host: ${state.backendHostDisplay}');
    buffer.writeln();
    
    if (state.hasServerSettings) {
      buffer.writeln('Server Settings:');
      buffer.writeln('  App: ${state.serverStatusSubtitle}');
      buffer.writeln('  Maintenance Mode: ${state.maintenanceModeStatus}');
      buffer.writeln('  Map Provider: ${state.mapProvider}');
      buffer.writeln('  Backup Interval: ${state.backupIntervalDisplay}');
    }
    
    if (state.isLoggedIn) {
      buffer.writeln();
      buffer.writeln('User:');
      buffer.writeln('  Name: ${state.userDisplayName}');
      buffer.writeln('  Email: ${state.userEmail}');
    }
    
    return buffer.toString();
  }

  /// Get settings recommendations
  static List<String> getSettingsRecommendations(SettingsState state) {
    final recommendations = <String>[];
    
    if (!state.notifications) {
      recommendations.add('Enable notifications to stay updated with important information');
    }
    
    if (!state.analytics) {
      recommendations.add('Enable analytics to help us improve the app experience');
    }
    
    if (!state.effectiveBusinessMode) {
      recommendations.add('Business mode is available - enable it to access booking features');
    }
    
    if (state.backendHost?.isEmpty == true) {
      recommendations.add('Configure backend host for custom server connections');
    }
    
    if (!state.hasServerSettings) {
      recommendations.add('Sync server settings to get latest configuration');
    }
    
    return recommendations;
  }

  /// Get settings health score
  static double getSettingsHealthScore(SettingsState state) {
    double score = 0.0;
    
    // Basic settings
    score += state.notifications ? 1.0 : 0.0;
    score += state.analytics ? 0.5 : 0.0;
    
    // System settings
    score += state.effectiveBusinessMode ? 1.0 : 0.0;
    score += state.backendHost?.isNotEmpty == true ? 0.5 : 0.0;
    score += state.hasServerSettings ? 0.5 : 0.0;
    
    // User settings
    score += state.isLoggedIn ? 0.5 : 0.0;
    
    return score;
  }

  /// Get settings insights
  static Map<String, dynamic> getSettingsInsights(SettingsState state) {
    return {
      'healthScore': getSettingsHealthScore(state),
      'recommendations': getSettingsRecommendations(state),
      'summary': getSettingsSummary(state),
      'metrics': {
        'totalSettings': 15,
        'enabledSettings': state.notifications ? 1 : 0 + (state.analytics ? 1 : 0) + (state.businessMode ? 1 : 0),
        'serverConnected': state.hasServerSettings,
        'userLoggedIn': state.isLoggedIn,
        'businessModeAvailable': state.effectiveBusinessMode,
      },
    };
  }

  /// Create settings backup
  static Future<bool> createSettingsBackup() async {
    try {
      final export = await exportSettings();
      
      // This would save to local storage in a real app
      debugPrint('Creating settings backup with ${export.state.notifications} notifications enabled');
      return true;
    } catch (e) {
      debugPrint('Error creating settings backup: $e');
      return false;
    }
  }

  /// Restore settings from backup
  static Future<SettingsResult> restoreSettingsBackup() async {
    try {
      // This would load from local storage in a real app
      debugPrint('Restoring settings from backup');
      
      // For demonstration, just reset to defaults
      return await resetSettings();
    } catch (e) {
      debugPrint('Error restoring settings backup: $e');
      return SettingsResult.failure('Failed to restore backup: $e');
    }
  }

  /// Validate all settings
  static Map<String, SettingsValidationResult> validateAllSettings(SettingsState state) {
    final results = <String, SettingsValidationResult>{};
    
    // Validate backend host
    if (state.backendHost != null) {
      final hostValidation = validateBackendHost(state.backendHost!);
      results['backendHost'] = hostValidation;
    }
    
    // Add more validations as needed
    
    return results;
  }

  /// Get setting by category
  static List<Setting> getSettingsByCategory(List<Setting> settings, SettingCategory category) {
    return settings.where((setting) => setting.category == category).toList();
  }

  /// Get setting by type
  static List<Setting> getSettingsByType(List<Setting> settings, SettingType type) {
    return settings.where((setting) => setting.type == type).toList();
  }

  /// Search settings
  static List<Setting> searchSettings(List<Setting> settings, String query) {
    if (query.trim().isEmpty) return settings;
    
    final lowerQuery = query.toLowerCase();
    
    return settings.where((setting) {
      return setting.title.toLowerCase().contains(lowerQuery) ||
             (setting.subtitle?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Get enabled settings
  static List<Setting> getEnabledSettings(List<Setting> settings) {
    return settings.where((setting) => setting.isEnabled).toList();
  }

  /// Get disabled settings
  static List<Setting> getDisabledSettings(List<Setting> settings) {
    return settings.where((setting) => !setting.isEnabled).toList();
  }

  /// Count settings by category
  static Map<SettingCategory, int> countSettingsByCategory(List<Setting> settings) {
    final counts = <SettingCategory, int>{};
    
    for (final setting in settings) {
      counts[setting.category] = (counts[setting.category] ?? 0) + 1;
    }
    
    return counts;
  }

  /// Count settings by type
  static Map<SettingType, int> countSettingsByType(List<Setting> settings) {
    final counts = <SettingType, int>{};
    
    for (final setting in settings) {
      counts[setting.type] = (counts[setting.type] ?? 0) + 1;
    }
    
    return counts;
  }

  /// Get setting completion percentage
  static double getSettingCompletionPercentage(List<Setting> settings) {
    if (settings.isEmpty) return 0.0;
    
    final enabledCount = getEnabledSettings(settings).length;
    return enabledCount / settings.length;
  }

  /// Get most used category
  static SettingCategory? getMostUsedCategory(List<Setting> settings) {
    final counts = countSettingsByCategory(settings);
    
    if (counts.isEmpty) return null;
    
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Get most used type
  static SettingType? getMostUsedType(List<Setting> settings) {
    final counts = countSettingsByType(settings);
    
    if (counts.isEmpty) return null;
    
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Check if settings are healthy
  static bool areSettingsHealthy(SettingsState state) {
    return getSettingsHealthScore(state) >= 3.0;
  }

  /// Get settings health status
  static String getSettingsHealthStatus(SettingsState state) {
    final score = getSettingsHealthScore(state);
    
    if (score >= 4.0) return 'Excellent';
    if (score >= 3.0) return 'Good';
    if (score >= 2.0) return 'Fair';
    return 'Poor';
  }

  /// Simulate real-time settings updates
  static Stream<Map<String, dynamic>> simulateSettingsUpdates() {
    return Stream.periodic(const Duration(seconds: 30), (_) {
      // Simulate random settings updates
      final random = DateTime.now().millisecondsSinceEpoch % 10;
      
      return {
        'timestamp': DateTime.now().toIso8601String(),
        'update': random < 5 ? 'server_settings' : 'business_mode',
        'value': random % 2 == 0,
      };
    });
  }

  /// Create settings session
  static Map<String, dynamic> createSettingsSession() {
    return {
      'sessionId': DateTime.now().millisecondsSinceEpoch.toString(),
      'startedAt': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
  }

  /// Update settings session
  static Map<String, dynamic> updateSettingsSession(
    Map<String, dynamic> session,
    String action,
  ) {
    return {
      ...session,
      'lastAction': action,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Complete settings session
  static Map<String, dynamic> completeSettingsSession(Map<String, dynamic> session) {
    return {
      ...session,
      'completedAt': DateTime.now().toIso8601String(),
      'duration': DateTime.now().difference(DateTime.parse(session['startedAt'])).inSeconds,
    };
  }
}
