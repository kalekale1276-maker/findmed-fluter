import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../models/legal_models.dart';
import '../services/legal_services.dart';

/// UI components for legal functionality
class LegalWidgets {
  /// Build app header
  static Widget buildAppHeader() {
    final appInfo = LegalServices.getAppInfo();
    
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
                      appInfo.name,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      appInfo.description,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Get.context!.isDarkMode ? Colors.white90 : TailwindColors.gray700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16.w,
                color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
              ),
              SizedBox(width: 8.w),
              Text(
                'Version ${appInfo.fullVersion}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build legal section card
  static Widget buildLegalSectionCard({
    required LegalSection section,
    required VoidCallback onTap,
    bool isExpanded = false,
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
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: section.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Icon(
                        section.icon,
                        size: 20.w,
                        color: section.color,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        section.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 20.w,
                      color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  SizedBox(height: 16.h),
                  _buildSectionContent(section.content),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build section content
  static Widget _buildSectionContent(String content) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray50,
        borderRadius: BorderRadius.circular(TailwindRadius.md),
        border: Border.all(
          color: Get.context!.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray200,
        ),
      ),
      child: MarkdownBody(
        data: LegalServices.formatMarkdownContent(content),
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(
            fontSize: 14.sp,
            color: Get.context!.isDarkMode ? Colors.white90 : TailwindColors.gray700,
            height: 1.4,
          ),
          h1: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
          h2: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
          h3: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
          listBullet: TextStyle(
            fontSize: 14.sp,
            color: Get.context!.isDarkMode ? Colors.white90 : TailwindColors.gray700,
          ),
          code: TextStyle(
            fontSize: 13.sp,
            backgroundColor: Get.context!.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray200,
            color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
          strong: TextStyle(
            fontWeight: FontWeight.bold,
            color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
          em: TextStyle(
            fontStyle: FontStyle.italic,
            color: Get.context!.isDarkMode ? Colors.white90 : TailwindColors.gray700,
          ),
        ),
      ),
    );
  }

  /// Build contact section
  static Widget buildContactSection() {
    final appInfo = LegalServices.getAppInfo();
    
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
            'Contact Us',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Have questions about FindMed? We\'d love to hear from you.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Get.context!.isDarkMode ? Colors.white90 : TailwindColors.gray700,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildContactButton(
                  icon: Icons.email,
                  label: 'Email',
                  onTap: () => LegalServices.sendEmailToDeveloper(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildContactButton(
                  icon: Icons.language,
                  label: 'Website',
                  onTap: () => LegalServices.openDeveloperWebsite(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build contact button
  static Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: Get.context!.isDarkMode ? TailwindColors.gray700 : Colors.white,
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: Get.context!.isDarkMode ? TailwindColors.gray600 : TailwindColors.gray300,
        ),
        boxShadow: [TailwindShadows.sm],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18.w,
                  color: Theme.of(Get.context!).primaryColor,
                ),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(Get.context!).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build version info card
  static Widget buildVersionInfoCard() {
    final appInfo = LegalServices.getAppInfo();
    
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
                Icons.info,
                size: 20.w,
                color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
              ),
              SizedBox(width: 8.w),
              Text(
                LegalConstants.versionInfoTitle,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildInfoRow('App Name', appInfo.name),
          _buildInfoRow('Version', appInfo.fullVersion),
          _buildInfoRow('Developer', appInfo.developerName),
          _buildInfoRow('Release Date', appInfo.formattedReleaseDate),
        ],
      ),
    );
  }

  /// Build info row
  static Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
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
                color: Get.context!.isDarkMode ? Colors.white90 : TailwindColors.gray700,
              ),
            ),
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
            'Loading legal information...',
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
  static Widget buildErrorMessage(String error, {VoidCallback? onRetry}) {
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
            'Error loading legal information',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
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
