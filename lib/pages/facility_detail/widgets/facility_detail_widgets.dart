import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../models/facility_detail_models.dart';
import '../services/facility_detail_services.dart';

/// UI components for facility detail functionality
class FacilityDetailWidgets {
  /// Build facility header
  static Widget buildFacilityHeader(FacilityDetail facility) {
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
          Row(
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: Theme.of(Get.context!).primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(28.w),
                ),
                child: Icon(
                  Icons.local_hospital,
                  size: 28.w,
                  color: Theme.of(Get.context!).primaryColor,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      facility.name,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      facility.ownership.isNotEmpty ? facility.formattedOwnership : 'Healthcare Facility',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build info card
  static Widget buildInfoCard({
    required String title,
    required String content,
    IconData? icon,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
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
                if (icon != null) ...[
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: (iconColor ?? Theme.of(Get.context!).primaryColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(
                      icon,
                      size: 20.w,
                      color: iconColor ?? Theme.of(Get.context!).primaryColor,
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        content,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.open_in_new,
                    size: 16.w,
                    color: Get.context!.isDarkMode ? Colors.white54 : TailwindColors.gray400,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build services card
  static Widget buildServicesCard(FacilityDetail facility) {
    if (!facility.hasServices) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
        ),
        boxShadow: [TailwindShadows.sm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Icons.medical_services,
                  size: 20.w,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                FacilityDetailConstants.servicesLabel,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: facility.services.take(10).map((service) => 
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  service,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ).toList(),
          ),
          if (facility.services.length > 10) ...[
            SizedBox(height: 8.h),
            Text(
              '... and ${facility.services.length - 10} more services',
              style: TextStyle(
                fontSize: 12.sp,
                color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build action buttons
  static Widget buildActionButtons({
    required FacilityDetail facility,
    required bool businessMode,
    required VoidCallback onCall,
    required VoidCallback onDirections,
    required VoidCallback onBook,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: FacilityDetailConstants.callButtonLabel,
                  icon: Icons.call,
                  color: Colors.green,
                  onPressed: facility.hasPhone ? onCall : null,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildActionButton(
                  label: FacilityDetailConstants.directionsButtonLabel,
                  icon: Icons.directions,
                  color: Colors.blue,
                  onPressed: facility.hasValidLocation ? onDirections : null,
                ),
              ),
              if (businessMode) ...[
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildActionButton(
                    label: FacilityDetailConstants.bookButtonLabel,
                    icon: Icons.calendar_today,
                    color: Theme.of(Get.context!).primaryColor,
                    onPressed: onBook,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Build action button
  static Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: onPressed != null ? color : color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        boxShadow: onPressed != null ? [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18.w,
                  color: Colors.white,
                ),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
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

  /// Build completion indicator
  static Widget buildCompletionIndicator(FacilityDetail facility) {
    final completion = facility.completionPercentage;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
        ),
        boxShadow: [TailwindShadows.sm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20.w,
                color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
              ),
              SizedBox(width: 8.w),
              Text(
                'Information Completeness',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          LinearProgressIndicator(
            value: completion,
            backgroundColor: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(
              completion >= 0.8 ? Colors.green : completion >= 0.5 ? Colors.orange : Colors.red,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${(completion * 100).toInt()}% Complete',
            style: TextStyle(
              fontSize: 12.sp,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build rating widget
  static Widget buildRatingWidget(FacilityRating? rating) {
    if (rating == null || !rating.hasRatings) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(16.w),
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
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating.averageRating.floor() ? Icons.star : 
                index < rating.averageRating ? Icons.star_half : Icons.star_border,
                size: 20.w,
                color: Colors.amber,
              );
            }),
          ),
          SizedBox(width: 8.w),
          Text(
            rating.starDisplay,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          Text(
            rating.countDisplay,
            style: TextStyle(
              fontSize: 14.sp,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build operating hours widget
  static Widget buildOperatingHoursWidget(FacilityOperatingHours? hours) {
    if (hours == null) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
        ),
        boxShadow: [TailwindShadows.sm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Icons.schedule,
                  size: 20.w,
                  color: Colors.purple,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Operating Hours',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...hours.todayHours.map((hour) => Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Text(
              hour,
              style: TextStyle(
                fontSize: 14.sp,
                color: Get.context!.isDarkMode ? Colors.white90 : TailwindColors.gray700,
              ),
            ),
          )),
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
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
