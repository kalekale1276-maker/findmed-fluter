import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../models/help_models.dart';
import '../services/help_services.dart';

/// UI components for help functionality
class HelpWidgets {
  /// Build search bar
  static Widget buildSearchBar({
    required TextEditingController controller,
    required bool isSearching,
    required VoidCallback onToggleSearch,
    required ValueChanged<String> onSearchChanged,
  }) {
    if (isSearching) {
      return TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: HelpConstants.searchHint,
          border: InputBorder.none,
          hintStyle: TextStyle(
            fontSize: 16.sp,
            color: Get.context!.isDarkMode ? Colors.white54 : TailwindColors.gray500,
          ),
        ),
        style: TextStyle(
          fontSize: 16.sp,
          color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
        ),
        onChanged: onSearchChanged,
      );
    }
    
    return Text(
      HelpConstants.pageTitle,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
      ),
    );
  }

  /// Build search hint
  static Widget buildSearchHint(String query) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18.w,
            color: Get.context!.isDarkMode ? Colors.white54 : TailwindColors.gray600,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              query.isEmpty 
                  ? HelpConstants.searchHintText
                  : HelpConstants.resultsForText.replaceAll('{query}', query),
              style: TextStyle(
                fontSize: 14.sp,
                color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build help section expansion tile
  static Widget buildHelpSectionTile({
    required HelpSection section,
    required bool isExpanded,
    required VoidCallback onExpansionChanged,
    String searchQuery = '',
  }) {
    final shouldExpand = isExpanded || (searchQuery.isNotEmpty && section.getMatchScore(searchQuery) > 0);
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
        ),
        boxShadow: [TailwindShadows.sm],
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            if (section.icon != null) ...[
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: (section.color ?? Theme.of(Get.context!).primaryColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  section.icon,
                  size: 16.w,
                  color: section.color ?? Theme.of(Get.context!).primaryColor,
                ),
              ),
              SizedBox(width: 12.w),
            ],
            Expanded(
              child: Text(
                section.title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                ),
              ),
            ),
          ],
        ),
        initiallyExpanded: shouldExpand,
        onExpansionChanged: (expanded) => onExpansionChanged(),
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: section.content.map((content) => 
                Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Get.context!.isDarkMode ? Colors.white90 : TailwindColors.gray700,
                      height: 1.4,
                    ),
                  ),
                ),
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build FAQ list tile
  static Widget buildFAQTile({
    required FAQ faq,
    required VoidCallback onTap,
    String searchQuery = '',
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: Get.context!.isDarkMode ? TailwindColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
        border: Border.all(
          color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
        ),
        boxShadow: [TailwindShadows.sm],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.w),
        title: Text(
          faq.question,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text(
            faq.answer,
            style: TextStyle(
              fontSize: 13.sp,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.w,
          color: Get.context!.isDarkMode ? Colors.white54 : TailwindColors.gray400,
        ),
        onTap: onTap,
      ),
    );
  }

  /// Build category selector
  static Widget buildCategorySelector({
    required List<HelpCategory> categories,
    required String? selectedCategory,
    required ValueChanged<String?> onCategorySelected,
  }) {
    return Container(
      height: 80.h,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category.id;
          
          return GestureDetector(
            onTap: () => onCategorySelected(isSelected ? null : category.id),
            child: Container(
              width: 120.w,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isSelected ? category.color : category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(TailwindRadius.lg),
                border: Border.all(
                  color: isSelected ? category.color : category.color.withOpacity(0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category.icon,
                    size: 24.w,
                    color: isSelected ? Colors.white : category.color,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : category.color,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build contact section
  static Widget buildContactSection() {
    final contactMethods = HelpServices.getContactMethods();
    
    return Container(
      padding: EdgeInsets.all(16.w),
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
            HelpConstants.contactSupportTitle,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            HelpConstants.contactSupportText,
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
                  method: contactMethods[0], // Email
                  isPrimary: true,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildContactButton(
                  method: contactMethods[1], // Phone
                  isPrimary: false,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: _buildContactButton(
              method: contactMethods[2], // Telegram
              isPrimary: false,
            ),
          ),
        ],
      ),
    );
  }

  /// Build contact button
  static Widget _buildContactButton({
    required ContactMethod method,
    required bool isPrimary,
  }) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: isPrimary 
            ? Theme.of(Get.context!).primaryColor
            : Get.context!.isDarkMode ? TailwindColors.gray700 : Colors.white,
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
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => HelpServices.launchUrl(method.url),
          borderRadius: BorderRadius.circular(TailwindRadius.lg),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  method.icon,
                  size: 18.w,
                  color: isPrimary ? Colors.white : (Get.context!.isDarkMode ? Colors.white : TailwindColors.gray700),
                ),
                SizedBox(width: 8.w),
                Text(
                  method.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isPrimary ? Colors.white : (Get.context!.isDarkMode ? Colors.white : TailwindColors.gray700),
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
    String message = HelpConstants.noResultsMessage,
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
              icon ?? Icons.search_off,
              size: 40.w,
              color: Theme.of(Get.context!).primaryColor,
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
            'Try different keywords or browse categories',
            style: TextStyle(
              fontSize: 14.sp,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
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
      padding: EdgeInsets.symmetric(vertical: 12.h),
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
                    fontSize: 18.sp,
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

  /// Build version info
  static Widget buildVersionInfo() {
    return Center(
      child: Text(
        HelpConstants.versionText,
        style: TextStyle(
          fontSize: 12.sp,
          color: Get.context!.isDarkMode ? Colors.white54 : TailwindColors.gray500,
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
