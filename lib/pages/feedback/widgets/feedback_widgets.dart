import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../models/feedback_models.dart';
import '../services/feedback_services.dart';

/// UI components for feedback functionality
class FeedbackWidgets {
  /// Build feedback header
  static Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(Get.context!).primaryColor.withOpacity(0.1),
            Theme.of(Get.context!).primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(TailwindRadius.xl),
        border: Border.all(
          color: Theme.of(Get.context!).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.feedback,
            size: 48.w,
            color: Theme.of(Get.context!).primaryColor,
          ),
          SizedBox(height: 16.h),
          Text(
            FeedbackConstants.headerMessage,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your feedback helps us improve FindMed for everyone',
            style: TextStyle(
              fontSize: 14.sp,
              color: Get.context!.isDarkMode ? Colors.white90 : TailwindColors.gray700,
            ),
          ),
        ],
      ),
    );
  }

  /// Build form field
  static Widget buildFormField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    TextInputType? keyboardType,
    int? maxLines,
    int? minLines,
    String? Function(String?)? validator,
    bool optional = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(TailwindRadius.lg),
            borderSide: BorderSide(
              color: Get.context!.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(TailwindRadius.lg),
            borderSide: BorderSide(
              color: Theme.of(Get.context!).primaryColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: maxLines != null && maxLines! > 1 ? 16.h : 12.h,
          ),
          suffixText: optional ? '(optional)' : null,
          suffixStyle: TextStyle(
            fontSize: 12.sp,
            color: Get.context!.isDarkMode ? Colors.white54 : TailwindColors.gray500,
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        minLines: minLines,
        validator: validator,
        style: TextStyle(
          fontSize: 15.sp,
          color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
        ),
      ),
    );
  }

  /// Build category selector
  static Widget buildCategorySelector({
    required String selectedCategoryId,
    required ValueChanged<String> onCategoryChanged,
  }) {
    final categories = FeedbackServices.getFeedbackCategories();
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feedback Type',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: categories.map((category) => 
              _buildCategoryChip(
                category: category,
                isSelected: selectedCategoryId == category.id,
                onTap: () => onCategoryChanged(category.id),
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }

  /// Build category chip
  static Widget _buildCategoryChip({
    required FeedbackCategory category,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? category.color : category.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          border: Border.all(
            color: isSelected ? category.color : category.color.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 16.w,
              color: isSelected ? Colors.white : category.color,
            ),
            SizedBox(width: 6.w),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : category.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build attachment section
  static Widget buildAttachmentSection({
    required List<FeedbackAttachment> attachments,
    required VoidCallback onAttach,
    required Function(FeedbackAttachment) onRemove,
    bool isUploading = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Attachments',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${attachments.length} files',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Get.context!.isDarkMode ? Colors.white54 : TailwindColors.gray500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              IconButton(
                onPressed: isUploading ? null : onAttach,
                icon: isUploading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(Get.context!).primaryColor,
                          ),
                        ),
                      )
                    : Icon(Icons.attach_file, size: 20.w),
                tooltip: 'Attach file',
              ),
              SizedBox(width: 8.w),
              Text(
                'Supported: Images, PDF, Documents (max 10MB)',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Get.context!.isDarkMode ? Colors.white54 : TailwindColors.gray500,
                ),
              ),
            ],
          ),
          if (attachments.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: attachments.map((attachment) => 
                _buildAttachmentChip(
                  attachment: attachment,
                  onRemove: () => onRemove(attachment),
                ),
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// Build attachment chip
  static Widget _buildAttachmentChip({
    required FeedbackAttachment attachment,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: FeedbackServices.getFileColor(attachment).withOpacity(0.1),
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: FeedbackServices.getFileColor(attachment).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FeedbackServices.getFileIcon(attachment),
            size: 16.w,
            color: FeedbackServices.getFileColor(attachment),
          ),
          SizedBox(width: 6.w),
          Text(
            attachment.displayName,
            style: TextStyle(
              fontSize: 13.sp,
              color: FeedbackServices.getFileColor(attachment),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 16.w,
              color: FeedbackServices.getFileColor(attachment),
            ),
          ),
        ],
      ),
    );
  }

  /// Build submit button
  static Widget buildSubmitButton({
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isValid = true,
  }) {
    return Container(
      width: double.infinity,
      height: 48.h,
      margin: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        gradient: isValid
            ? LinearGradient(
                colors: [
                  Theme.of(Get.context!).primaryColor,
                  Theme.of(Get.context!).primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isValid ? null : Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray300,
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        boxShadow: isValid
            ? [
                BoxShadow(
                  color: Theme.of(Get.context!).primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isValid && !isLoading ? onPressed : null,
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    FeedbackConstants.sendButtonLabel,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isValid ? Colors.white : (Get.context!.isDarkMode ? Colors.white54 : TailwindColors.gray500),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// Build success dialog
  static Widget buildSuccessDialog({
    required String message,
    required VoidCallback onContinue,
  }) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(32.w),
            ),
            child: Icon(
              Icons.check_circle,
              size: 32.w,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Thank You!',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onContinue,
          child: const Text('Continue'),
        ),
      ],
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

  /// Build info message
  static Widget buildInfoMessage(String message) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(TailwindRadius.md),
        border: Border.all(
          color: Theme.of(Get.context!).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(Get.context!).primaryColor,
            size: 20.w,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(Get.context!).primaryColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
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
