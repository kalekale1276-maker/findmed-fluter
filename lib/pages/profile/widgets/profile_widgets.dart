import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../models/profile_models.dart';
import '../services/profile_services.dart';

/// UI components for profile functionality
class ProfileWidgets {
  /// Build profile avatar
  static Widget buildAvatar({
    required String displayName,
    double radius = 48,
  }) {
    return CircleAvatar(
      radius: radius.r,
      backgroundColor: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
        style: TextStyle(
          fontSize: (radius * 0.75).sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(Get.context!).primaryColor,
        ),
      ),
    );
  }

  /// Build agent info chip
  static Widget buildAgentInfoChip({
    required String agentId,
    required String facilityType,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(Get.context!).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            facilityType.toLowerCase() == 'pharmacy' ? Icons.local_pharmacy : Icons.medical_services,
            size: 16.w,
            color: Theme.of(Get.context!).primaryColor,
          ),
          SizedBox(width: 8.w),
          Text(
            'Agent ID: $agentId',
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(Get.context!).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build personal information card
  static Widget buildPersonalInfoCard({
    required String fullName,
    required String email,
    required String phone,
    required int? age,
    required bool isEditing,
    required VoidCallback? onEdit,
  }) {
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
              ProfileConstants.personalInfoTitle,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
              ),
            ),
            SizedBox(height: 12.h),
            _buildInfoField(
              label: ProfileConstants.fullNameLabel,
              value: fullName,
              isEditing: isEditing,
            ),
            SizedBox(height: 8.h),
            _buildInfoField(
              label: ProfileConstants.emailLabel,
              value: email,
              isEditing: false, // Email is always read-only
            ),
            SizedBox(height: 8.h),
            _buildInfoField(
              label: ProfileConstants.phoneLabel,
              value: ProfileServices.formatPhoneDisplay(phone),
              isEditing: isEditing,
            ),
            SizedBox(height: 8.h),
            _buildInfoField(
              label: ProfileConstants.ageLabel,
              value: age?.toString() ?? '',
              isEditing: isEditing,
            ),
          ],
        ),
      ),
    );
  }

  /// Build info field
  static Widget _buildInfoField({
    required String label,
    required String value,
    required bool isEditing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60.w,
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
            value.isEmpty ? '-' : value,
            style: TextStyle(
              fontSize: 13.sp,
              color: isEditing 
                  ? Theme.of(Get.context!).primaryColor
                  : (Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900),
              fontWeight: isEditing ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  /// Build medical profile card
  static Widget buildMedicalProfileCard({
    required String conditions,
    required String allergies,
    required String medications,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
      ),
      child: ListTile(
        title: Text(
          ProfileConstants.medicalProfileTitle,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            if (conditions.isNotEmpty)
              Text('Conditions: $conditions'),
            if (allergies.isNotEmpty)
              Text('Allergies: $allergies'),
            if (medications.isNotEmpty)
              Text('Medications: $medications'),
            if (conditions.isEmpty && allergies.isEmpty && medications.isEmpty)
              Text(ProfileConstants.noMedicalProfileMessage),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: Theme.of(Get.context!).primaryColor),
        onTap: onTap,
      ),
    );
  }

  /// Build action card
  static Widget buildActionCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(Get.context!).primaryColor),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                ),
              )
            : null,
        trailing: Icon(Icons.chevron_right, color: Theme.of(Get.context!).primaryColor),
        onTap: onTap,
      ),
    );
  }

  /// Build error message
  static Widget buildErrorMessage(String error) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: TailwindColors.red50,
        borderRadius: BorderRadius.circular(TailwindRadius.md),
        border: Border.all(color: TailwindColors.red200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: TailwindColors.red500,
            size: 20.w,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: TailwindColors.red500,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build loading overlay
  static Widget buildLoadingOverlay() {
    return Container(
      color: Colors.black45,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Build action buttons
  static Widget buildActionButtons({
    required bool isEditing,
    required bool isLoading,
    required VoidCallback onEdit,
    required VoidCallback onSave,
    required VoidCallback onLogout,
  }) {
    return Row(
      children: [
        if (isEditing) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onSave,
              icon: isLoading
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.save, size: 18.w),
              label: Text(ProfileConstants.saveLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(Get.context!).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ] else ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: Icon(Icons.edit, size: 18.w),
              label: Text(ProfileConstants.editLabel),
            ),
          ),
        ],
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onLogout,
            icon: Icon(Icons.logout, size: 18.w),
            label: Text(ProfileConstants.logoutLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// Build change password dialog
  static Widget buildChangePasswordDialog({
    required VoidCallback onCancel,
    required VoidCallback onSave,
  }) {
    return AlertDialog(
      title: Text(ProfileConstants.changePasswordTitle),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            obscureText: true,
            decoration: InputDecoration(labelText: 'Current password'),
          ),
          SizedBox(height: 8),
          TextField(
            obscureText: true,
            decoration: InputDecoration(labelText: 'New password'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(ProfileConstants.cancelLabel),
        ),
        TextButton(
          onPressed: onSave,
          child: Text('Save'),
        ),
      ],
    );
  }

  /// Build connect Telegram dialog
  static Widget buildConnectTelegramDialog({
    required TextEditingController controller,
    required bool isLoading,
    required VoidCallback onCancel,
    required VoidCallback onConnect,
  }) {
    return AlertDialog(
      title: Text(ProfileConstants.connectTelegramTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(ProfileConstants.telegramInstructions),
          SizedBox(height: 8.h),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: ProfileConstants.telegramChatIdLabel,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : onCancel,
          child: Text(ProfileConstants.cancelLabel),
        ),
        TextButton(
          onPressed: isLoading ? null : onConnect,
          child: Text(ProfileConstants.connectLabel),
        ),
      ],
    );
  }

  /// Build profile completeness indicator
  static Widget buildProfileCompletenessIndicator({
    required double completeness,
  }) {
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
              'Profile Completeness',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
              ),
            ),
            SizedBox(height: 12.h),
            LinearProgressIndicator(
              value: completeness,
              backgroundColor: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
              valueColor: AlwaysStoppedAnimation<Color>(
                completeness == 1.0 ? Colors.green : Theme.of(Get.context!).primaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '${(completeness * 100).toStringAsFixed(0)}% Complete',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: completeness == 1.0 ? Colors.green : Theme.of(Get.context!).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build health tips card
  static Widget buildHealthTipsCard({
    required List<String> tips,
  }) {
    if (tips.isEmpty) {
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
              'Profile Tips',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
              ),
            ),
            SizedBox(height: 12.h),
            ...tips.map((tip) => 
              Padding(
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
                        tip,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Get.context!.isDarkMode ? Colors.white90 : TailwindColors.gray700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build statistics card
  static Widget buildStatisticsCard({
    required ProfileStatistics stats,
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
              'Profile Statistics',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
              ),
            ),
            SizedBox(height: 12.h),
            _buildStatRow('Total Profiles', stats.totalProfiles.toString()),
            _buildStatRow('Agent Profiles', stats.agentProfiles.toString()),
            _buildStatRow('Telegram Linked', stats.telegramLinkedProfiles.toString()),
            _buildStatRow('Average Age', stats.averageAge.toStringAsFixed(1)),
            SizedBox(height: 8.h),
            Text(
              'Facility Types:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
              ),
            ),
            SizedBox(height: 4.h),
            ...stats.facilityTypes.entries.map((entry) => 
              Padding(
                padding: EdgeInsets.only(left: 8.w, top: 2.h),
                child: Text(
                  '${entry.key}: ${entry.value}',
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
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
        ],
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
