import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../models/community_models.dart';
import '../services/community_services.dart';

/// UI components for community functionality
class CommunityWidgets {
  /// Build feature card
  static Widget buildFeatureCard({
    required CommunityFeature feature,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(TailwindRadius.xl),
        border: Border.all(
          color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
        ),
        boxShadow: [TailwindShadows.md],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TailwindRadius.xl),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(28.w),
                  ),
                  child: Icon(
                    feature.icon,
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
                        feature.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        feature.description,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
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

  /// Build statistics card
  static Widget buildStatsCard(CommunityStats stats) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(20.w),
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
          Text(
            'Community Impact',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Contributions', stats.totalContributions, Theme.of(Get.context!).primaryColor),
              ),
              Expanded(
                child: _buildStatItem('Contributors', stats.activeContributors, Colors.green),
              ),
              Expanded(
                child: _buildStatItem('Facilities Added', stats.facilitiesAdded, Colors.blue),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Updates', stats.facilitiesUpdated, Colors.orange),
              ),
              Expanded(
                child: _buildStatItem('Forum Posts', stats.forumPosts, Colors.purple),
              ),
              Expanded(
                child: _buildStatItem('Pending', stats.pendingReviews, Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build statistics item
  static Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20.sp,
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
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build activity item
  static Widget buildActivityItem(CommunityActivity activity) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.w),
            ),
            child: Icon(
              Icons.person,
              size: 20.w,
              color: Theme.of(Get.context!).primaryColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.formattedActivity,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  activity.formattedTime,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Get.context!.isDarkMode ? Colors.white54 : TailwindColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build guidelines section
  static Widget buildGuidelinesSection() {
    final guidelines = CommunityServices.getCommunityGuidelines();
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(TailwindRadius.xl),
        border: Border.all(
          color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
        ),
        boxShadow: [TailwindShadows.sm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            CommunityConstants.guidelinesTitle,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          SizedBox(height: 16.h),
          ...guidelines.map((guideline) => _buildGuidelineItem(guideline)),
        ],
      ),
    );
  }

  /// Build guideline item
  static Widget _buildGuidelineItem(CommunityGuideline guideline) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: guideline.isImportant 
                  ? Colors.red.withOpacity(0.1)
                  : Theme.of(Get.context!).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.w),
            ),
            child: Icon(
              guideline.icon,
              size: 16.w,
              color: guideline.isImportant 
                  ? Colors.red
                  : Theme.of(Get.context!).primaryColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guideline.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  guideline.description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build section header
  static Widget buildSectionHeader({
    required String title,
    String? subtitle,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onAction != null && actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
        ],
      ),
    );
  }

  /// Build action button
  static Widget buildActionButton({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    bool isPrimary = true,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      height: 48.h,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? LinearGradient(
                colors: [
                  Theme.of(Get.context!).primaryColor,
                  Theme.of(Get.context!).primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPrimary ? null : Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray100,
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: isPrimary
            ? null
            : Border.all(
                color: Get.context!.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray300,
              ),
        boxShadow: isPrimary
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
          onTap: onPressed,
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20.w,
                    color: isPrimary ? Colors.white : (Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900),
                  ),
                  SizedBox(width: 8.w),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isPrimary ? Colors.white : (Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build empty state
  static Widget buildEmptyState({
    required String title,
    required String subtitle,
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
              color: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40.w),
              border: Border.all(
                color: Theme.of(Get.context!).primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon ?? Icons.people_outline,
              size: 40.w,
              color: Theme.of(Get.context!).primaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
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
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(Get.context!).primaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
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
