import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../models/settings_models.dart';
import '../services/settings_services.dart';

/// UI components for settings functionality
class SettingsWidgets {
  static BuildContext? _context;
  
  /// Set context for widget operations
  static void setContext(BuildContext context) {
    _context = context;
  }
  
  /// Clear stored context
  static void clearContext() {
    _context = null;
  }
  /// Build settings section header
  static Widget buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 6.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  /// Build account card
  static Widget buildAccountCard({
    required bool isLoggedIn,
    required String displayName,
    required String email,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.person,
            color: Theme.of(Get.context!).primaryColor,
          ),
        ),
        title: Text(
          displayName,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        subtitle: isLoggedIn && email.isNotEmpty
            ? Text(
                email,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                ),
              )
            : null,
        trailing: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(Get.context!).colorScheme.primary,
          ),
          onPressed: onTap,
          child: Text(
            isLoggedIn ? SettingsConstants.manageAccountLabel : SettingsConstants.signInLabel,
          ),
        ),
      ),
    );
  }

  /// Build toggle setting
  static Widget buildToggleSetting({
    required String title,
    String? subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon),
    );
  }

  /// Build navigation setting
  static Widget buildNavigationSetting({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  /// Build info setting
  static Widget buildInfoSetting({
    required String title,
    String? subtitle,
    required IconData icon,
    required String value,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
              ),
            ),
            if (onTap != null) ...[
              SizedBox(width: 8.w),
              const Icon(Icons.chevron_right),
            ],
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  /// Build action setting
  static Widget buildActionSetting({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  /// Build system settings card
  static Widget buildSystemSettingsCard({
    required Map<String, dynamic> serverSettings,
    required bool isLoading,
    required VoidCallback onSync,
    required VoidCallback onEditBackendHost,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.cloud),
            title: const Text(SettingsConstants.serverSettingsLabel),
            subtitle: Text(_getServerStatusSubtitle(serverSettings)),
            trailing: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(Get.context!).colorScheme.primary,
                    ),
                    onPressed: onSync,
                    child: const Text(SettingsConstants.syncLabel),
                  ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text(SettingsConstants.maintenanceModeLabel),
            subtitle: Text(serverSettings['maintenanceModeMobile'] == true ? 'On' : 'Off'),
          ),
          const Divider(height: 1),
          _buildBusinessModeSetting(),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text(SettingsConstants.mapProviderLabel),
            subtitle: Text(serverSettings['mapProvider']?.toString() ?? SettingsConstants.notSetServerStatusMessage),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text(SettingsConstants.backendHostLabel),
            subtitle: Text(_getBackendHostDisplay()),
            trailing: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(Get.context!).colorScheme.primary,
              ),
              onPressed: onEditBackendHost,
              child: const Text(SettingsConstants.editLabel),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text(SettingsConstants.backupIntervalLabel),
            subtitle: Text('${serverSettings['backupIntervalDays'] ?? SettingsConstants.notConfiguredMessage} days'),
          ),
        ],
      ),
    );
  }

  /// Build business mode setting
  static Widget _buildBusinessModeSetting() {
    return StatefulBuilder(
      builder: (context, setState) {
        final businessMode = SettingsServices.getBusinessModeStatus();
        final effectiveBusinessMode = SettingsServices.getEffectiveBusinessModeStatus();
        
        return Column(
          children: [
            SwitchListTile(
              title: const Text(SettingsConstants.businessModeLabel),
              subtitle: Text(_getBusinessModeSubtitle(effectiveBusinessMode, businessMode)),
              value: businessMode,
              onChanged: (value) async {
                final result = await SettingsServices.updateBusinessMode(value);
                if (!result.success) {
                  _showErrorMessage(result.message!);
                }
              },
              secondary: const Icon(Icons.business),
            ),
            if (effectiveBusinessMode)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  SettingsConstants.businessModeBenefits,
                  style: const TextStyle(fontSize: 14, color: Colors.green),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Build support settings card
  static Widget buildSupportSettingsCard({
    required VoidCallback onAbout,
    required VoidCallback onFeedback,
    required VoidCallback onSendLogs,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text(SettingsConstants.aboutAppLabel),
            onTap: onAbout,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text(SettingsConstants.sendFeedbackLabel),
            onTap: onFeedback,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text(SettingsConstants.sendLogsLabel),
            subtitle: const Text(SettingsConstants.sendLogsSubtitle),
            onTap: onSendLogs,
          ),
        ],
      ),
    );
  }

  /// Build data settings card
  static Widget buildDataSettingsCard({
    required VoidCallback onExportData,
    required VoidCallback onClearCache,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text(SettingsConstants.exportDataLabel),
            subtitle: const Text(SettingsConstants.exportDataSubtitle),
            onTap: onExportData,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text(SettingsConstants.clearLocalCacheLabel),
            subtitle: const Text(SettingsConstants.clearCacheSubtitle),
            onTap: onClearCache,
          ),
        ],
      ),
    );
  }

  /// Build backend host dialog
  static Widget buildBackendHostDialog({
    required TextEditingController controller,
    required VoidCallback onUseDefault,
    required VoidCallback onCancel,
    required VoidCallback onSave,
  }) {
    return AlertDialog(
      title: const Text(SettingsConstants.backendHostLabel),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
              'Enter the backend host or full URL so the app connects to your machine from other devices.'),
          SizedBox(height: 12.h),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Host or host:port (e.g. 192.168.43.1:5000)',
              hintText: '192.168.1.100:5000 or http://192.168.1.100:5000',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onUseDefault,
          child: const Text(SettingsConstants.useDefaultLabel),
        ),
        TextButton(
          onPressed: onCancel,
          child: const Text(SettingsConstants.cancelLabel),
        ),
        TextButton(
          onPressed: onSave,
          child: const Text(SettingsConstants.saveLabel),
        ),
      ],
    );
  }

  /// Build about dialog
  static Widget buildAboutDialog() {
    return const AboutDialog(
      applicationName: 'FindMed',
      applicationVersion: '1.0.0',
      children: [Text('Mobile app for finding medical facilities.')],
    );
  }

  /// Build feedback dialog
  static Widget buildFeedbackDialog() {
    return AlertDialog(
      title: const Text(SettingsConstants.sendFeedbackLabel),
      content: const Text('You can send feedback via the website or email.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(Get.context!),
          child: const Text(SettingsConstants.okLabel),
        ),
      ],
    );
  }

  /// Build send logs dialog
  static Widget buildSendLogsDialog() {
    return AlertDialog(
      title: const Text(SettingsConstants.sendLogsLabel),
      content: const Text(
          'This will attach debug logs and open an email composer (placeholder).'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(Get.context!),
          child: const Text(SettingsConstants.cancelLabel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(Get.context!);
            _showSuccessMessage(SettingsConstants.logsSentPlaceholderMessage);
          },
          child: const Text(SettingsConstants.sendLabel),
        ),
      ],
    );
  }

  /// Build export data dialog
  static Widget buildExportDataDialog() {
    return AlertDialog(
      title: const Text(SettingsConstants.exportDataLabel),
      content: const Text('This will be available in a future update.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(Get.context!),
          child: const Text(SettingsConstants.okLabel),
        ),
      ],
    );
  }

  /// Build statistics card
  static Widget buildStatisticsCard({
    required SettingsAnalytics stats,
  }) {
    if (!stats.hasData) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings Statistics',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
              ),
            ),
            SizedBox(height: 12.h),
            _buildStatRow('Total Settings', stats.totalSettings.toString()),
            _buildStatRow('Enabled Settings', stats.enabledSettings.toString()),
            _buildStatRow('Enabled Percentage', '${(stats.enabledPercentage * 100).toStringAsFixed(1)}%'),
            SizedBox(height: 8.h),
            Text(
              'By Category:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
              ),
            ),
            SizedBox(height: 4.h),
            ...stats.categoryCounts.entries.map((entry) => 
              Padding(
                padding: EdgeInsets.only(left: 8.w, top: 2.h),
                child: Text(
                  '${_getCategoryDisplayName(entry.key)}: ${entry.value}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build statistics row
  static Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              fontSize: 13.sp,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build health score card
  static Widget buildHealthScoreCard({
    required double score,
    required String status,
  }) {
    Color color;
    if (score >= 4.0) {
      color = Colors.green;
    } else if (score >= 3.0) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings Health',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: score / 5.0,
                    backgroundColor: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  '${score.toStringAsFixed(1)}/5.0',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Status: $status',
              style: TextStyle(
                fontSize: 14.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build recommendations card
  static Widget buildRecommendationsCard({
    required List<String> recommendations,
  }) {
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommendations',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
              ),
            ),
            SizedBox(height: 12.h),
            ...recommendations.map((recommendation) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16.w,
                    color: Theme.of(Get.context!).primaryColor,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray700,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  /// Get server status subtitle
  static String _getServerStatusSubtitle(Map<String, dynamic> serverSettings) {
    if (serverSettings.isEmpty) return SettingsConstants.unknownServerStatusMessage;
    
    final name = serverSettings['appName'] ?? 'FindMed';
    final version = serverSettings['version'] ?? '';
    return '$name${version.isNotEmpty ? ' • v$version' : ''}';
  }

  /// Get backend host display
  static String _getBackendHostDisplay() {
    final host = SettingsServices.getBackendHost();
    if (host?.isNotEmpty == true) {
      return host!;
    }
    return SettingsConstants.usingDefaultHostMessage;
  }

  /// Get business mode subtitle
  static String _getBusinessModeSubtitle(bool effective, bool user) {
    if (effective) {
      return SettingsConstants.businessModeOnMessage;
    } else {
      return user 
          ? SettingsConstants.businessModeOffAdminMessage
          : SettingsConstants.businessModeOffServiceMessage;
    }
  }

  /// Get category display name
  static String _getCategoryDisplayName(SettingCategory category) {
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

  /// Show success message
  static void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show error message
  static void _showErrorMessage(String message) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Build spacing
  static Widget buildSpacing({double height = 16}) {
    return SizedBox(height: height.h);
  }

  /// Build section divider
  static Widget buildSectionDivider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.h),
      height: 1.h,
      color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
    );
  }

  /// Build loading indicator
  static Widget buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Build empty state
  static Widget buildEmptyState({
    String message = 'No settings available',
    IconData icon = Icons.settings,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40.w),
              border: Border.all(
                color: Theme.of(Get.context!).primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: 40.w,
              color: Theme.of(Get.context!).primaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper class to get context
class Get {
  static BuildContext? _context;
  
  static BuildContext get context {
    if (_context == null) {
      throw Exception('Context not set. Call setContext() first.');
    }
    return _context!;
  }
  
  static void setContext(BuildContext context) {
    _context = context;
  }
  
  static void clearContext() {
    _context = null;
  }
}
