import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../models/about_models.dart';
import '../services/about_services.dart';

/// UI components for the About page
class AboutWidgets {
  /// App header with logo and version
  static Widget buildAppHeader() {
    return Row(
      children: [
        Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(36.w),
            border: Border.all(
              color: Theme.of(Get.context!).primaryColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.local_hospital,
            size: 36.w,
            color: Theme.of(Get.context!).primaryColor,
          ),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AboutConstants.appName,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Version ${AboutConstants.version}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Description text
  static Widget buildDescription() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Get.context!.isDarkMode ? TailwindColors.gray800 : TailwindColors.gray50,
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
        ),
      ),
      child: Text(
        AboutConstants.description,
        style: TextStyle(
          fontSize: 15.sp,
          height: 1.5,
          color: Get.context!.isDarkMode ? Colors.white90 : TailwindColors.gray700,
        ),
      ),
    );
  }

  /// Section title
  static Widget buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
        ),
      ),
    );
  }

  /// Expandable section
  static Widget buildExpandableSection(AboutSection section) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
        ),
        boxShadow: [TailwindShadows.sm],
      ),
      child: ExpansionTile(
        title: Text(
          section.title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        childrenPadding: EdgeInsets.all(16.w),
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        children: [
          if (section.content != null) ...[
            Text(
              section.content!,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.5,
                color: Get.context!.isDarkMode ? Colors.white90 : TailwindColors.gray700,
              ),
            ),
            if (section.bulletPoints != null) SizedBox(height: 12.h),
          ],
          if (section.bulletPoints != null) ...[
            ...section.bulletPoints!.map((point) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(Get.context!).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.4,
                        color: Get.context!.isDarkMode ? Colors.white90 : TailwindColors.gray700,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
          if (section.externalLink != null) ...[
            SizedBox(height: 12.h),
            _buildLinkButton(
              label: _getLinkLabel(section.title),
              onPressed: () => _handleLinkAction(section.title),
            ),
          ],
        ],
      ),
    );
  }

  /// Key features list
  static Widget buildKeyFeatures() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Get.context!.isDarkMode ? TailwindColors.gray800 : TailwindColors.gray50,
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionTitle('Key features'),
          SizedBox(height: 8.h),
          ...AboutConstants.keyFeatures.map((feature) => Padding(
            padding: EdgeInsets.only(bottom: 6.h, left: 8.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16.w,
                  color: Theme.of(Get.context!).primaryColor,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.4,
                      color: Get.context!.isDarkMode ? Colors.white90 : TailwindColors.gray700,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  /// Support actions grid
  static Widget buildSupportActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle('Support'),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: AboutServices.getSupportActions().map((action) => 
            _buildSupportButton(action)
          ).toList(),
        ),
      ],
    );
  }

  /// Open source section
  static Widget buildOpenSourceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle('Open-source & Licenses'),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Get.context!.isDarkMode ? TailwindColors.gray800 : TailwindColors.gray50,
            borderRadius: BorderRadius.circular(TailwindRadius.lg),
            border: Border.all(
              color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This app uses open-source packages. Tap below to view the full license list.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Get.context!.isDarkMode ? Colors.white90 : TailwindColors.gray700,
                ),
              ),
              SizedBox(height: 12.h),
              _buildLinkButton(
                label: 'View licenses',
                onPressed: () => showLicensePage(
                  context: Get.context!,
                  applicationName: AboutConstants.appName,
                  applicationVersion: AboutConstants.version,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Credits section
  static Widget buildCreditsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle('Credits'),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Get.context!.isDarkMode ? TailwindColors.gray800 : TailwindColors.gray50,
            borderRadius: BorderRadius.circular(TailwindRadius.lg),
            border: Border.all(
              color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AboutConstants.credits.map((credit) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Text(
                credit,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Get.context!.isDarkMode ? Colors.white90 : TailwindColors.gray700,
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  /// Footer action button
  static Widget buildFooterActionButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 16.h),
      child: ElevatedButton.icon(
        onPressed: AboutServices.sendBugReport,
        icon: Icon(Icons.bug_report, size: 18.w),
        label: Text('Report a bug or request a feature'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(Get.context!).primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TailwindRadius.lg),
          ),
        ),
      ),
    );
  }

  /// Support button
  static Widget _buildSupportButton(SupportAction action) {
    return ElevatedButton.icon(
      onPressed: action.onPressed,
      icon: Icon(action.icon, size: 16.w),
      label: Text(action.label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray100,
        foregroundColor: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TailwindRadius.md),
        ),
        side: BorderSide(
          color: Get.context!.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray300,
        ),
      ),
    );
  }

  /// Link button
  static Widget _buildLinkButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.open_in_new, size: 16.w),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(Get.context!).primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      ),
    );
  }

  /// Get appropriate link label
  static String _getLinkLabel(String sectionTitle) {
    switch (sectionTitle) {
      case 'Roadmap & Upcoming features':
        return 'View full roadmap';
      case 'Changelog':
        return 'View changelog';
      case 'Data & Privacy':
        return 'Open privacy policy';
      case 'Contribute / Report issues':
        return 'Open repository';
      default:
        return 'Learn more';
    }
  }

  /// Handle link actions based on section
  static void _handleLinkAction(String sectionTitle) {
    switch (sectionTitle) {
      case 'Roadmap & Upcoming features':
        AboutServices.openRoadmap();
        break;
      case 'Changelog':
        AboutServices.openChangelog();
        break;
      case 'Data & Privacy':
        AboutServices.openPrivacyPolicy();
        break;
      case 'Contribute / Report issues':
        AboutServices.openRepository();
        break;
      default:
        AboutServices.openWebsite();
    }
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
