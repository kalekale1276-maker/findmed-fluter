/// Models and constants for settings functionality
import 'package:flutter/material.dart';

class SettingsConstants {
  // UI labels
  static const String pageTitle = 'Settings';
  static const String accountSectionTitle = 'Account';
  static const String preferencesSectionTitle = 'Preferences';
  static const String medicalSectionTitle = 'Medical';
  static const String dataSectionTitle = 'Data';
  static const String systemSectionTitle = 'System';
  static const String supportSectionTitle = 'Support';
  
  // Account labels
  static const String manageAccountLabel = 'Manage';
  static const String signInLabel = 'Sign in';
  static const String notSignedInLabel = 'Not signed in';
  static const String myAccountLabel = 'My Account';
  
  // Preferences labels
  static const String enableNotificationsLabel = 'Enable notifications';
  static const String darkThemeLabel = 'Dark theme (app-level)';
  static const String enableAnalyticsLabel = 'Enable analytics';
  
  // Medical labels
  static const String editMedicalProfileLabel = 'Edit medical profile';
  
  // Data labels
  static const String exportDataLabel = 'Export data';
  static const String exportDataSubtitle = 'Generate a backup of saved facilities and profile';
  static const String clearLocalCacheLabel = 'Clear local cache';
  static const String clearCacheSubtitle = 'Removes local-only stored data (not server)';
  
  // System labels
  static const String serverSettingsLabel = 'Server settings';
  static const String syncLabel = 'Sync';
  static const String maintenanceModeLabel = 'Maintenance mode';
  static const String businessModeLabel = 'Business mode';
  static const String mapProviderLabel = 'Map provider';
  static const String backendHostLabel = 'Backend host / IP';
  static const String editLabel = 'Edit';
  static const String backupIntervalLabel = 'Backup interval';
  
  // Support labels
  static const String aboutAppLabel = 'About this app';
  static const String sendFeedbackLabel = 'Send feedback';
  static const String sendLogsLabel = 'Send logs / report issue';
  static const String sendLogsSubtitle = 'Attach debug logs to help troubleshooting';
  
  // Messages
  static const String serverSettingsSyncedMessage = 'Server settings synced';
  static const String failedToFetchServerSettingsMessage = 'Failed to fetch server settings';
  static const String backendHostClearedMessage = 'Backend host cleared (using default)';
  static const String backendHostSavedMessage = 'Backend host saved';
  static const String localCacheClearedMessage = 'Local cache cleared';
  static const String logsSentPlaceholderMessage = 'Logs sent (placeholder)';
  static const String serviceNotAvailableMessage = 'Service not available at this time';
  static const String failedToCheckServiceMessage = 'Failed to check service';
  
  // Dialog labels
  static const String okLabel = 'OK';
  static const String cancelLabel = 'Cancel';
  static const String saveLabel = 'Save';
  static const String useDefaultLabel = 'Use default';
  static const String sendLabel = 'Send';
  
  // Business mode messages
  static const String businessModeOnMessage = 'On - Enjoy booking features';
  static const String businessModeOffAdminMessage = 'Off - Turn on to access booking features';
  static const String businessModeOffServiceMessage = 'Service not available at this time';
  static const String businessModeBenefits = 'Benefits:\n• Book appointments at facilities\n• Access to exclusive services\n• Priority support';
  
  // Server status messages
  static const String unknownServerStatusMessage = 'Unknown (tap Sync)';
  static const String notSetServerStatusMessage = 'Not set';
  static const String notConfiguredMessage = 'Not configured';
  static const String usingDefaultHostMessage = 'Using default (emulator / localhost)';
  
  // Animation durations
  static const int animationDurationMs = 300;
  static const int snackBarDurationSeconds = 3;
  
  // SharedPreferences keys
  static const String notificationsKey = 'notifications';
  static const String darkThemeKey = 'darkTheme';
  static const String analyticsKey = 'analytics';
  
  // Default values
  static const bool defaultNotifications = true;
  static const bool defaultDarkTheme = false;
  static const bool defaultAnalytics = false;
  static const bool defaultBusinessMode = false;
}

/// Setting category enum
enum SettingCategory {
  account,
  preferences,
  medical,
  data,
  system,
  support,
}

/// Setting type enum
enum SettingType {
  toggle,
  navigation,
  action,
  info,
  dialog,
}

/// Setting model
class Setting {
  final String id;
  final String title;
  final String? subtitle;
  final SettingCategory category;
  final SettingType type;
  final IconData icon;
  final bool value;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;
  final String? dialogTitle;
  final String? dialogContent;
  final List<Setting>? subSettings;

  Setting({
    required this.id,
    required this.title,
    this.subtitle,
    required this.category,
    required this.type,
    required this.icon,
    this.value = false,
    this.onTap,
    this.onToggle,
    this.dialogTitle,
    this.dialogContent,
    this.subSettings,
  });

  /// Create toggle setting
  factory Setting.toggle({
    required String id,
    required String title,
    String? subtitle,
    required SettingCategory category,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onToggle,
  }) {
    return Setting(
      id: id,
      title: title,
      subtitle: subtitle,
      category: category,
      type: SettingType.toggle,
      icon: icon,
      value: value,
      onToggle: onToggle,
    );
  }

  /// Create navigation setting
  factory Setting.navigation({
    required String id,
    required String title,
    String? subtitle,
    required SettingCategory category,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Setting(
      id: id,
      title: title,
      subtitle: subtitle,
      category: category,
      type: SettingType.navigation,
      icon: icon,
      onTap: onTap,
    );
  }

  /// Create action setting
  factory Setting.action({
    required String id,
    required String title,
    String? subtitle,
    required SettingCategory category,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Setting(
      id: id,
      title: title,
      subtitle: subtitle,
      category: category,
      type: SettingType.action,
      icon: icon,
      onTap: onTap,
    );
  }

  /// Create info setting
  factory Setting.info({
    required String id,
    required String title,
    String? subtitle,
    required SettingCategory category,
    required IconData icon,
    String? value,
  }) {
    return Setting(
      id: id,
      title: title,
      subtitle: subtitle,
      category: category,
      type: SettingType.info,
      icon: icon,
      value: value?.isNotEmpty == true,
    );
  }

  /// Create dialog setting
  factory Setting.dialog({
    required String id,
    required String title,
    String? subtitle,
    required SettingCategory category,
    required IconData icon,
    required VoidCallback onTap,
    String? dialogTitle,
    String? dialogContent,
  }) {
    return Setting(
      id: id,
      title: title,
      subtitle: subtitle,
      category: category,
      type: SettingType.dialog,
      icon: icon,
      onTap: onTap,
      dialogTitle: dialogTitle,
      dialogContent: dialogContent,
    );
  }

  /// Check if setting is enabled
  bool get isEnabled => value;

  /// Check if setting has sub-settings
  bool get hasSubSettings => subSettings?.isNotEmpty == true;

  /// Get category display name
  String get categoryDisplayName {
    switch (category) {
      case SettingCategory.account:
        return SettingsConstants.accountSectionTitle;
      case SettingCategory.preferences:
        return SettingsConstants.preferencesSectionTitle;
      case SettingCategory.medical:
        return SettingsConstants.medicalSectionTitle;
      case SettingCategory.data:
        return SettingsConstants.dataSectionTitle;
      case SettingCategory.system:
        return SettingsConstants.systemSectionTitle;
      case SettingCategory.support:
        return SettingsConstants.supportSectionTitle;
    }
  }

  /// Get category icon
  IconData get categoryIcon {
    switch (category) {
      case SettingCategory.account:
        return Icons.person;
      case SettingCategory.preferences:
        return Icons.tune;
      case SettingCategory.medical:
        return Icons.medical_services;
      case SettingCategory.data:
        return Icons.storage;
      case SettingCategory.system:
        return Icons.settings;
      case SettingCategory.support:
        return Icons.help;
    }
  }
}

/// Settings state model
class SettingsState {
  final bool notifications;
  final bool darkTheme;
  final bool analytics;
  final bool businessMode;
  final bool effectiveBusinessMode;
  final Map<String, dynamic> serverSettings;
  final bool isLoadingServer;
  final bool isLoggedIn;
  final Map<String, dynamic>? user;
  final String? backendHost;
  final List<Setting> settings;

  const SettingsState({
    this.notifications = SettingsConstants.defaultNotifications,
    this.darkTheme = SettingsConstants.defaultDarkTheme,
    this.analytics = SettingsConstants.defaultAnalytics,
    this.businessMode = SettingsConstants.defaultBusinessMode,
    this.effectiveBusinessMode = false,
    this.serverSettings = const {},
    this.isLoadingServer = false,
    this.isLoggedIn = false,
    this.user,
    this.backendHost,
    this.settings = const [],
  });

  SettingsState copyWith({
    bool? notifications,
    bool? darkTheme,
    bool? analytics,
    bool? businessMode,
    bool? effectiveBusinessMode,
    Map<String, dynamic>? serverSettings,
    bool? isLoadingServer,
    bool? isLoggedIn,
    Map<String, dynamic>? user,
    String? backendHost,
    List<Setting>? settings,
  }) {
    return SettingsState(
      notifications: notifications ?? this.notifications,
      darkTheme: darkTheme ?? this.darkTheme,
      analytics: analytics ?? this.analytics,
      businessMode: businessMode ?? this.businessMode,
      effectiveBusinessMode: effectiveBusinessMode ?? this.effectiveBusinessMode,
      serverSettings: serverSettings ?? this.serverSettings,
      isLoadingServer: isLoadingServer ?? this.isLoadingServer,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
      backendHost: backendHost ?? this.backendHost,
      settings: settings ?? this.settings,
    );
  }

  /// Update notification setting
  SettingsState updateNotifications(bool value) {
    return copyWith(notifications: value);
  }

  /// Update dark theme setting
  SettingsState updateDarkTheme(bool value) {
    return copyWith(darkTheme: value);
  }

  /// Update analytics setting
  SettingsState updateAnalytics(bool value) {
    return copyWith(analytics: value);
  }

  /// Update business mode setting
  SettingsState updateBusinessMode(bool value) {
    return copyWith(businessMode: value);
  }

  /// Update effective business mode
  SettingsState updateEffectiveBusinessMode(bool value) {
    return copyWith(effectiveBusinessMode: value);
  }

  /// Update server settings
  SettingsState updateServerSettings(Map<String, dynamic> settings) {
    return copyWith(serverSettings: settings);
  }

  /// Set server loading state
  SettingsState setServerLoading(bool loading) {
    return copyWith(isLoadingServer: loading);
  }

  /// Update login state
  SettingsState updateLoginState(bool isLoggedIn, {Map<String, dynamic>? user}) {
    return copyWith(isLoggedIn: isLoggedIn, user: user);
  }

  /// Update backend host
  SettingsState updateBackendHost(String? host) {
    return copyWith(backendHost: host);
  }

  /// Update settings list
  SettingsState updateSettings(List<Setting> settings) {
    return copyWith(settings: settings);
  }

  /// Get user display name
  String get userDisplayName {
    if (!isLoggedIn || user == null) return SettingsConstants.notSignedInLabel;
    return user?['fullName'] ?? user?['name'] ?? SettingsConstants.myAccountLabel;
  }

  /// Get user email
  String get userEmail {
    if (!isLoggedIn || user == null) return '';
    return user?['email'] ?? '';
  }

  /// Get server status subtitle
  String get serverStatusSubtitle {
    if (serverSettings.isEmpty) return SettingsConstants.unknownServerStatusMessage;
    
    final name = serverSettings['appName'] ?? 'FindMed';
    final version = serverSettings['version'] ?? '';
    return '$name${version.isNotEmpty ? ' • v$version' : ''}';
  }

  /// Get maintenance mode status
  String get maintenanceModeStatus {
    return serverSettings['maintenanceModeMobile'] == true ? 'On' : 'Off';
  }

  /// Get map provider
  String get mapProvider {
    return serverSettings['mapProvider']?.toString() ?? SettingsConstants.notSetServerStatusMessage;
  }

  /// Get backend host display
  String get backendHostDisplay {
    if (backendHost?.isNotEmpty == true) {
      return backendHost!;
    }
    return SettingsConstants.usingDefaultHostMessage;
  }

  /// Get backup interval display
  String get backupIntervalDisplay {
    final days = serverSettings['backupIntervalDays'];
    return '${days ?? SettingsConstants.notConfiguredMessage} days';
  }

  /// Check if business mode is available
  bool get isBusinessModeAvailable => effectiveBusinessMode;

  /// Get business mode subtitle
  String get businessModeSubtitle {
    if (effectiveBusinessMode) {
      return SettingsConstants.businessModeOnMessage;
    } else {
      return businessMode 
          ? SettingsConstants.businessModeOffAdminMessage
          : SettingsConstants.businessModeOffServiceMessage;
    }
  }

  /// Check if has server settings
  bool get hasServerSettings => serverSettings.isNotEmpty;

  /// Check if is loading
  bool get isLoading => isLoadingServer;
}

/// Server settings model
class ServerSettings {
  final String appName;
  final String version;
  final bool maintenanceModeMobile;
  final String mapProvider;
  final int backupIntervalDays;
  final Map<String, dynamic> additionalSettings;

  ServerSettings({
    required this.appName,
    required this.version,
    required this.maintenanceModeMobile,
    required this.mapProvider,
    required this.backupIntervalDays,
    this.additionalSettings = const {},
  });

  factory ServerSettings.fromJson(Map<String, dynamic> json) {
    return ServerSettings(
      appName: json['appName']?.toString() ?? 'FindMed',
      version: json['version']?.toString() ?? '',
      maintenanceModeMobile: json['maintenanceModeMobile'] == true,
      mapProvider: json['mapProvider']?.toString() ?? '',
      backupIntervalDays: json['backupIntervalDays'] ?? 0,
      additionalSettings: json as Map<String, dynamic>? ?? {},
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'version': version,
      'maintenanceModeMobile': maintenanceModeMobile,
      'mapProvider': mapProvider,
      'backupIntervalDays': backupIntervalDays,
      ...additionalSettings,
    };
  }

  /// Create copy with updated fields
  ServerSettings copyWith({
    String? appName,
    String? version,
    bool? maintenanceModeMobile,
    String? mapProvider,
    int? backupIntervalDays,
    Map<String, dynamic>? additionalSettings,
  }) {
    return ServerSettings(
      appName: appName ?? this.appName,
      version: version ?? this.version,
      maintenanceModeMobile: maintenanceModeMobile ?? this.maintenanceModeMobile,
      mapProvider: mapProvider ?? this.mapProvider,
      backupIntervalDays: backupIntervalDays ?? this.backupIntervalDays,
      additionalSettings: additionalSettings ?? this.additionalSettings,
    );
  }

  /// Check if maintenance mode is on
  bool get isMaintenanceModeOn => maintenanceModeMobile;

  /// Get formatted version
  String get formattedVersion {
    return version.isNotEmpty ? 'v$version' : '';
  }

  /// Get display name with version
  String get displayNameWithVersion {
    final versionStr = formattedVersion;
    return '$appName${versionStr.isNotEmpty ? ' $versionStr' : ''}';
  }

  /// Check if has valid backup interval
  bool get hasValidBackupInterval => backupIntervalDays > 0;

  /// Get backup interval display
  String get backupIntervalDisplay {
    if (!hasValidBackupInterval) {
      return SettingsConstants.notConfiguredMessage;
    }
    return '$backupIntervalDays days';
  }
}

/// Settings action result
class SettingsResult {
  final bool success;
  final String? message;
  final dynamic data;

  SettingsResult({
    required this.success,
    this.message,
    this.data,
  });

  factory SettingsResult.success({
    String? message,
    dynamic data,
  }) {
    return SettingsResult(
      success: true,
      message: message,
      data: data,
    );
  }

  factory SettingsResult.failure(String message) {
    return SettingsResult(
      success: false,
      message: message,
    );
  }
}

/// Settings validation result
class SettingsValidationResult {
  final bool isValid;
  final String? errorMessage;

  const SettingsValidationResult({required this.isValid, this.errorMessage});

  static const SettingsValidationResult valid = SettingsValidationResult(isValid: true);
  
  SettingsValidationResult.invalid(String message) 
      : isValid = false, errorMessage = message;

  /// Validate backend host
  static SettingsValidationResult validateBackendHost(String host) {
    if (host.trim().isEmpty) {
      return const SettingsValidationResult.valid; // Empty means use default
    }
    
    // Basic validation for host format
    if (host.contains(' ') || host.length < 3) {
      return SettingsValidationResult.invalid('Invalid host format');
    }
    
    return const SettingsValidationResult.valid;
  }
}

/// Settings analytics model
class SettingsAnalytics {
  final int totalSettings;
  final int enabledSettings;
  final Map<SettingCategory, int> categoryCounts;
  final Map<SettingType, int> typeCounts;
  final DateTime lastUpdated;

  SettingsAnalytics({
    required this.totalSettings,
    required this.enabledSettings,
    required this.categoryCounts,
    required this.typeCounts,
    required this.lastUpdated,
  });

  /// Calculate analytics from settings
  factory SettingsAnalytics.fromSettings(List<Setting> settings) {
    final categoryCounts = <SettingCategory, int>{};
    final typeCounts = <SettingType, int>{};
    int enabledCount = 0;

    for (final setting in settings) {
      // Count by category
      categoryCounts[setting.category] = (categoryCounts[setting.category] ?? 0) + 1;
      
      // Count by type
      typeCounts[setting.type] = (typeCounts[setting.type] ?? 0) + 1;
      
      // Count enabled settings
      if (setting.isEnabled) enabledCount++;
    }

    return SettingsAnalytics(
      totalSettings: settings.length,
      enabledSettings: enabledCount,
      categoryCounts: categoryCounts,
      typeCounts: typeCounts,
      lastUpdated: DateTime.now(),
    );
  }

  /// Get enabled percentage
  double get enabledPercentage {
    if (totalSettings == 0) return 0.0;
    return enabledSettings / totalSettings;
  }

  /// Get most common category
  SettingCategory? get mostCommonCategory {
    if (categoryCounts.isEmpty) return null;
    
    return categoryCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Get most common type
  SettingType? get mostCommonType {
    if (typeCounts.isEmpty) return null;
    
    return typeCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Check if has data
  bool get hasData => totalSettings > 0;
}

/// Settings export data
class SettingsExport {
  final SettingsState state;
  final ServerSettings serverSettings;
  final DateTime exportedAt;
  final String format;

  SettingsExport({
    required this.state,
    required this.serverSettings,
    required this.exportedAt,
    this.format = 'json',
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'state': {
        'notifications': state.notifications,
        'darkTheme': state.darkTheme,
        'analytics': state.analytics,
        'businessMode': state.businessMode,
        'effectiveBusinessMode': state.effectiveBusinessMode,
        'backendHost': state.backendHost,
        'isLoggedIn': state.isLoggedIn,
        'user': state.user,
      },
      'serverSettings': serverSettings.toJson(),
      'exportedAt': exportedAt.toIso8601String(),
      'format': format,
      'version': '1.0',
    };
  }

  /// Export to JSON string
  String toJsonString() {
    final data = toJson();
    return '''
{
  "state": ${data['state']},
  "serverSettings": ${data['serverSettings']},
  "exportedAt": "${data['exportedAt']}",
  "format": "${data['format']}",
  "version": "${data['version']}"
}
''';
  }

  /// Export to CSV format
  String toCsvString() {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('Setting,Value');
    
    // State settings
    buffer.writeln('Notifications,${state.notifications}');
    buffer.writeln('Dark Theme,${state.darkTheme}');
    buffer.writeln('Analytics,${state.analytics}');
    buffer.writeln('Business Mode,${state.businessMode}');
    buffer.writeln('Backend Host,${state.backendHost ?? ''}');
    buffer.writeln('Logged In,${state.isLoggedIn}');
    
    // Server settings
    buffer.writeln('App Name,${serverSettings.appName}');
    buffer.writeln('Version,${serverSettings.version}');
    buffer.writeln('Maintenance Mode,${serverSettings.maintenanceModeMobile}');
    buffer.writeln('Map Provider,${serverSettings.mapProvider}');
    buffer.writeln('Backup Interval,${serverSettings.backupIntervalDays}');
    
    // Metadata
    buffer.writeln('Exported At,${exportedAt.toIso8601String()}');
    buffer.writeln('Format,$format');
    buffer.writeln('Version,1.0');
    
    return buffer.toString();
  }
}
