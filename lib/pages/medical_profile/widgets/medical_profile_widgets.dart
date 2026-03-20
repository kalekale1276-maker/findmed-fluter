import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../models/medical_profile_models.dart';
import '../services/medical_profile_services.dart';

/// UI components for medical profile functionality
class MedicalProfileWidgets {
  /// Build profile overview card
  static Widget buildProfileOverviewCard({
    required MedicalProfile profile,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    bool isLoading = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              MedicalProfileConstants.savedProfileTitle,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
              ),
            ),
            SizedBox(height: 12.h),
            _buildInfoRow(
              'Conditions:',
              profile.formattedConditions.isEmpty ? '-' : profile.formattedConditions,
            ),
            SizedBox(height: 6.h),
            _buildInfoRow(
              'Allergies:',
              profile.formattedAllergies.isEmpty ? '-' : profile.formattedAllergies,
            ),
            SizedBox(height: 6.h),
            _buildInfoRow(
              'Medications:',
              profile.formattedMedications.isEmpty ? '-' : profile.formattedMedications,
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onEdit,
                    icon: Icon(Icons.edit, size: 18.w),
                    label: Text(MedicalProfileConstants.editLabel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(Get.context!).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                OutlinedButton.icon(
                  onPressed: isLoading ? null : onDelete,
                  icon: Icon(Icons.delete, size: 18.w),
                  label: Text(MedicalProfileConstants.deleteLabel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build info row
  static Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
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
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
        ),
      ],
    );
  }

  /// Build profile edit form
  static Widget buildProfileEditForm({
    required TextEditingController conditionsController,
    required TextEditingController allergiesController,
    required TextEditingController medicationsController,
    required FocusNode conditionsFocus,
    required FocusNode allergiesFocus,
    required FocusNode medicationsFocus,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader(MedicalProfileConstants.medicalConditionsTitle),
            SizedBox(height: 8.h),
            TextField(
              controller: conditionsController,
              focusNode: conditionsFocus,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: MedicalProfileConstants.commaSeparatedHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TailwindRadius.md),
                ),
                filled: true,
                fillColor: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            _buildSectionHeader(MedicalProfileConstants.allergiesTitle),
            SizedBox(height: 8.h),
            TextField(
              controller: allergiesController,
              focusNode: allergiesFocus,
              minLines: 1,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: MedicalProfileConstants.commaSeparatedHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TailwindRadius.md),
                ),
                filled: true,
                fillColor: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            _buildSectionHeader(MedicalProfileConstants.medicationsTitle),
            SizedBox(height: 8.h),
            TextField(
              controller: medicationsController,
              focusNode: medicationsFocus,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: MedicalProfileConstants.commaSeparatedHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TailwindRadius.md),
                ),
                filled: true,
                fillColor: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build section header
  static Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
      ),
    );
  }

  /// Build save button
  static Widget buildSaveButton({
    required VoidCallback onPressed,
    bool isLoading = false,
    bool canSave = true,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: canSave && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canSave ? Theme.of(Get.context!).primaryColor : Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TailwindRadius.lg),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(MedicalProfileConstants.saveLabel),
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
      color: Colors.black26,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Build add item dialog
  static Widget buildAddItemDialog({
    required String title,
    required String label,
    required TextEditingController controller,
    required VoidCallback onAdd,
    required VoidCallback onCancel,
  }) {
    return AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(MedicalProfileConstants.cancelLabel),
        ),
        TextButton(
          onPressed: onAdd,
          child: Text(MedicalProfileConstants.addLabel),
        ),
      ],
    );
  }

  /// Build confirm delete dialog
  static Widget buildConfirmDeleteDialog({
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    return AlertDialog(
      title: Text(MedicalProfileConstants.deleteProfileTitle),
      content: Text(MedicalProfileConstants.deleteProfileMessage),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(MedicalProfileConstants.cancelLabel),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(MedicalProfileConstants.deleteLabel),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
        ),
      ],
    );
  }

  /// Build history list
  static Widget buildHistoryList({
    required List<MedicalProfileHistory> history,
    bool isEmpty = false,
  }) {
    if (isEmpty) {
      return _buildEmptyState(MedicalProfileConstants.noHistoryMessage);
    }

    return ListView.separated(
      itemCount: history.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final entry = history[index];
        return ExpansionTile(
          title: Text(entry.displayDate),
          children: [
            ListTile(
              title: const Text('Conditions'),
              subtitle: Text(entry.formattedConditions.isEmpty ? '-' : entry.formattedConditions),
            ),
            ListTile(
              title: const Text('Allergies'),
              subtitle: Text(entry.formattedAllergies.isEmpty ? '-' : entry.formattedAllergies),
            ),
            ListTile(
              title: const Text('Medications'),
              subtitle: Text(entry.formattedMedications.isEmpty ? '-' : entry.formattedMedications),
            ),
          ],
        );
      },
    );
  }

  /// Build empty state
  static Widget _buildEmptyState(String message) {
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
              Icons.history,
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
          SizedBox(height: 8.h),
          Text(
            'Your profile history will appear here',
            style: TextStyle(
              fontSize: 14.sp,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build profile statistics card
  static Widget buildStatisticsCard({
    required MedicalProfileStats stats,
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
            _buildStatRow('Avg. Conditions', stats.averageConditions.toString()),
            _buildStatRow('Avg. Allergies', stats.averageAllergies.toString()),
            _buildStatRow('Avg. Medications', stats.averageMedications.toString()),
            _buildStatRow('Last Updated', _formatDate(stats.lastUpdated)),
            SizedBox(height: 8.h),
            Text(
              'Category Counts:',
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

  /// Format date
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
              'Health Tips',
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

  /// Build completeness indicator
  static Widget buildCompletenessIndicator({
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
