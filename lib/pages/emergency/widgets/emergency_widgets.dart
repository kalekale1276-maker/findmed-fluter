import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../../../../widgets/app_drawer.dart';
import '../models/emergency_models.dart';
import '../services/emergency_services.dart';

/// UI components for emergency functionality
class EmergencyWidgets {
  /// Build SOS button
  static Widget buildSOSButton({
    required VoidCallback onPressed,
    bool isActivated = false,
  }) {
    return Container(
      width: double.infinity,
      height: 60.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isActivated ? Colors.red.shade600 : Colors.red,
            isActivated ? Colors.red.shade800 : Colors.red.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(TailwindRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.4),
            blurRadius: isActivated ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(TailwindRadius.xl),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emergency,
                  size: 24.w,
                  color: Colors.white,
                ),
                SizedBox(width: 12.w),
                Text(
                  EmergencyConstants.sosButtonLabel,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build facility list item
  static Widget buildFacilityItem({
    required EmergencyFacility facility,
    required VoidCallback onTap,
    required VoidCallback onCall,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
        ),
        boxShadow: [TailwindShadows.sm],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24.w),
                  ),
                  child: Icon(
                    Icons.local_hospital,
                    size: 24.w,
                    color: Colors.red,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facility.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'ID: ${facility.id}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Get.context!.isDarkMode ? Colors.white54 : TailwindColors.gray500,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        facility.displaySubtitle,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (facility.hasPhone)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.call,
                        size: 20.w,
                        color: Colors.green,
                      ),
                      onPressed: onCall,
                      tooltip: 'Call Hospital',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build search bar
  static Widget buildSearchBar({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required VoidCallback onClear,
    bool isSearching = false,
  }) {
    if (!isSearching) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
        ),
        boxShadow: [TailwindShadows.sm],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: EmergencyConstants.searchHint,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12.h,
                  horizontal: 16.w,
                ),
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: Get.context!.isDarkMode ? Colors.white54 : TailwindColors.gray400,
                ),
              ),
              style: TextStyle(
                fontSize: 14.sp,
                color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
              ),
              onChanged: onChanged,
            ),
          ),
          IconButton(
            tooltip: EmergencyConstants.clearSearchLabel,
            icon: Icon(
              Icons.clear,
              size: 20.w,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
            onPressed: onClear,
          ),
        ],
      ),
    );
  }

  /// Build header
  static Widget buildHeader({
    required bool isSearching,
    required VoidCallback onSearchToggle,
    required VoidCallback onRefresh,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isSearching)
            Expanded(
              child: Text(
                EmergencyConstants.pageTitle,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                ),
              ),
            )
          else
            Text(
              EmergencyConstants.pageTitle,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.search,
                  size: 22.w,
                  color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray700,
                ),
                tooltip: EmergencyConstants.searchTooltip,
                onPressed: onSearchToggle,
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  size: 22.w,
                  color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray700,
                ),
                tooltip: EmergencyConstants.refreshTooltip,
                onPressed: onRefresh,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build section title
  static Widget buildSectionTitle(String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
        ),
      ),
    );
  }

  /// Build empty state
  static Widget buildEmptyState({
    String message = EmergencyConstants.noHospitalsMessage,
    IconData? icon,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40.w),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon ?? Icons.local_hospital_outlined,
              size: 40.w,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try refreshing or checking your location settings',
            style: TextStyle(
              fontSize: 14.sp,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build loading indicator
  static Widget buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
          SizedBox(height: 16.h),
          Text(
            'Finding nearby hospitals...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build error message
  static Widget buildErrorMessage(String message, {VoidCallback? onRetry}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: TailwindColors.red50,
              borderRadius: BorderRadius.circular(40.w),
              border: Border.all(
                color: TailwindColors.red200,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.error_outline,
              size: 40.w,
              color: TailwindColors.red500,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
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
          if (onRetry != null) ...[
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh, size: 18.w),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build SOS dialog
  static Widget buildSOSDialog() {
    return AlertDialog(
      title: Text(
        EmergencyConstants.sosDialogTitle,
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emergency,
            size: 48.w,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            EmergencyConstants.sosDialogMessage,
            style: TextStyle(
              fontSize: 16.sp,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(Get.context!).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }

  /// Build spacing
  static Widget buildSpacing({double height = 16}) {
    return SizedBox(height: height.h);
  }

  /// Build statistics card
  static Widget buildStatisticsCard({
    required int totalFacilities,
    required int facilitiesWithPhone,
    required double? nearestDistance,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.1),
            Colors.red.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: Colors.red.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', totalFacilities.toString(), Colors.red),
          _buildStatItem('With Phone', facilitiesWithPhone.toString(), Colors.green),
          _buildStatItem(
            'Nearest',
            nearestDistance != null ? '${nearestDistance.toStringAsFixed(1)} km' : 'N/A',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  /// Build statistics item
  static Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
          ),
        ),
      ],
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
