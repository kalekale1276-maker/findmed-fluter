import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../models/reports_models.dart';
import '../services/reports_services.dart';

/// UI components for reports functionality
class ReportsWidgets {
  /// Build report list item
  static Widget buildReportItem({
    required Report report,
    required VoidCallback onTap,
    required VoidCallback? onStatusChange,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailwindRadius.lg),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.w),
        title: Row(
          children: [
            Expanded(
              child: Text(
                report.title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                ),
              ),
            ),
            _buildPriorityChip(report.priority),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            Row(
              children: [
                _buildStatusChip(report.status),
                SizedBox(width: 8.w),
                _buildCategoryChip(report.category),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              '${report.formattedDate} • ${report.statusText}',
              style: TextStyle(
                fontSize: 12.sp,
                color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: Theme.of(Get.context!).primaryColor),
        onTap: onTap,
      ),
    );
  }

  /// Build priority chip
  static Widget _buildPriorityChip(ReportPriority priority) {
    Color backgroundColor;
    Color textColor;
    String text;
    
    switch (priority) {
      case ReportPriority.urgent:
        backgroundColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        text = ReportsConstants.urgentPriority;
        break;
      case ReportPriority.high:
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        text = ReportsConstants.highPriority;
        break;
      case ReportPriority.medium:
        backgroundColor = Colors.yellow[50]!;
        textColor = Colors.yellow[700]!;
        text = ReportsConstants.mediumPriority;
        break;
      case ReportPriority.low:
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        text = ReportsConstants.lowPriority;
        break;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  /// Build status chip
  static Widget _buildStatusChip(ReportStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;
    
    switch (status) {
      case ReportStatus.open:
        backgroundColor = Colors.blue[50]!;
        textColor = Colors.blue[700]!;
        text = ReportsConstants.openStatus;
        break;
      case ReportStatus.inProgress:
        backgroundColor = Colors.indigo[50]!;
        textColor = Colors.indigo[700]!;
        text = ReportsConstants.inProgressStatus;
        break;
      case ReportStatus.resolved:
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        text = ReportsConstants.resolvedStatus;
        break;
      case ReportStatus.closed:
        backgroundColor = Colors.grey[50]!;
        textColor = Colors.grey[700]!;
        text = ReportsConstants.closedStatus;
        break;
      case ReportStatus.pending:
        backgroundColor = Colors.amber[50]!;
        textColor = Colors.amber[700]!;
        text = ReportsConstants.pendingStatus;
        break;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  /// Build category chip
  static Widget _buildCategoryChip(ReportCategory category) {
    Color backgroundColor;
    Color textColor;
    String text;
    
    switch (category) {
      case ReportCategory.equipment:
        backgroundColor = Colors.purple[50]!;
        textColor = Colors.purple[700]!;
        text = ReportsConstants.equipmentCategory;
        break;
      case ReportCategory.stockout:
        backgroundColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        text = ReportsConstants.stockoutCategory;
        break;
      case ReportCategory.facility:
        backgroundColor = Colors.teal[50]!;
        textColor = Colors.teal[700]!;
        text = ReportsConstants.facilityCategory;
        break;
      case ReportCategory.staff:
        backgroundColor = Colors.cyan[50]!;
        textColor = Colors.cyan[700]!;
        text = ReportsConstants.staffCategory;
        break;
      case ReportCategory.other:
        backgroundColor = Colors.grey[50]!;
        textColor = Colors.grey[700]!;
        text = ReportsConstants.otherCategory;
        break;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  /// Build create report button
  static Widget buildCreateReportButton({
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Icon(Icons.add, size: 20.w),
        label: Text(ReportsConstants.createReportLabel),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(Get.context!).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TailwindRadius.lg),
          ),
        ),
      ),
    );
  }

  /// Build create report bottom sheet
  static Widget buildCreateReportSheet({
    required TextEditingController titleController,
    required TextEditingController descriptionController,
    required ReportCategory selectedCategory,
    required ReportPriority selectedPriority,
    required ValueChanged<ReportCategory> onCategoryChanged,
    required ValueChanged<ReportPriority> onPriorityChanged,
    required VoidCallback onCancel,
    required VoidCallback onSubmit,
    bool isLoading = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ReportsConstants.createReportLabel,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
            ),
          ),
          SizedBox(height: 16.h),
          
          // Title field
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: ReportsConstants.titleLabel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TailwindRadius.md),
              ),
            ),
            maxLength: ReportsConstants.titleMaxLength,
          ),
          SizedBox(height: 12.h),
          
          // Description field
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: ReportsConstants.descriptionLabel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TailwindRadius.md),
              ),
            ),
            maxLines: 3,
            maxLength: ReportsConstants.descriptionMaxLength,
          ),
          SizedBox(height: 12.h),
          
          // Category dropdown
          DropdownButtonFormField<ReportCategory>(
            value: selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TailwindRadius.md),
              ),
            ),
            items: ReportCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(_getCategoryText(category)),
              );
            }).toList(),
            onChanged: (category) {
              if (category != null) onCategoryChanged(category);
            },
          ),
          SizedBox(height: 12.h),
          
          // Priority dropdown
          DropdownButtonFormField<ReportPriority>(
            value: selectedPriority,
            decoration: InputDecoration(
              labelText: 'Priority',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TailwindRadius.md),
              ),
            ),
            items: ReportPriority.values.map((priority) {
              return DropdownMenuItem(
                value: priority,
                child: Text(_getPriorityText(priority)),
              );
            }).toList(),
            onChanged: (priority) {
              if (priority != null) onPriorityChanged(priority);
            },
          ),
          SizedBox(height: 16.h),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : onCancel,
                  child: Text(ReportsConstants.cancelLabel),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : onSubmit,
                  child: isLoading
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(ReportsConstants.submitLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build report detail dialog
  static Widget buildReportDetailDialog({
    required Report report,
    required VoidCallback onClose,
    required VoidCallback? onStatusChange,
  }) {
    return AlertDialog(
      title: Text(report.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(ReportsConstants.dateLabel, report.formattedDateTime),
            SizedBox(height: 8.h),
            _buildDetailRow(ReportsConstants.statusLabel, report.statusText),
            SizedBox(height: 8.h),
            _buildDetailRow('Category', report.categoryText),
            SizedBox(height: 8.h),
            _buildDetailRow('Priority', report.priorityText),
            SizedBox(height: 8.h),
            if (report.description.isNotEmpty) ...[
              Text(
                ReportsConstants.detailsLabel,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                report.description,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray700,
                ),
              ),
              SizedBox(height: 8.h),
            ],
            if (report.description.isEmpty)
              Text(
                ReportsConstants.noDetailsMessage,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontStyle: FontStyle.italic,
                  color: Get.context!.isDarkMode ? Colors.white60 : TailwindColors.gray500,
                ),
              ),
            if (report.resolutionTime != null) ...[
              SizedBox(height: 8.h),
              _buildDetailRow('Resolution Time', '${report.resolutionTime} days'),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onClose,
          child: Text(ReportsConstants.closeLabel),
        ),
        if (onStatusChange != null && report.isActive)
          TextButton(
            onPressed: onStatusChange,
            child: Text('Update Status'),
          ),
      ],
    );
  }

  /// Build detail row
  static Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
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

  /// Build empty state
  static Widget buildEmptyState({
    String message = 'No reports found',
    IconData icon = Icons.report_problem,
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
          SizedBox(height: 8.h),
          Text(
            'Create your first report to get started',
            style: TextStyle(
              fontSize: 14.sp,
              color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build loading indicator
  static Widget buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Build error state
  static Widget buildErrorState(String error) {
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
              fontSize: 16.sp,
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
        ],
      ),
    );
  }

  /// Build statistics card
  static Widget buildStatisticsCard({
    required ReportStatistics stats,
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
              'Report Statistics',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
              ),
            ),
            SizedBox(height: 12.h),
            _buildStatRow('Total Reports', stats.totalReports.toString()),
            _buildStatRow('Open', stats.openReports.toString()),
            _buildStatRow('In Progress', stats.inProgressReports.toString()),
            _buildStatRow('Resolved', stats.resolvedReports.toString()),
            _buildStatRow('Closed', stats.closedReports.toString()),
            _buildStatRow('Pending', stats.pendingReports.toString()),
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
                  '${_getCategoryText(entry.key)}: ${entry.value}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'By Priority:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
              ),
            ),
            SizedBox(height: 4.h),
            ...stats.priorityCounts.entries.map((entry) => 
              Padding(
                padding: EdgeInsets.only(left: 8.w, top: 2.h),
                child: Text(
                  '${_getPriorityText(entry.key)}: ${entry.value}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            _buildStatRow('Avg Resolution Time', '${stats.averageResolutionTime.toStringAsFixed(1)} days'),
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

  /// Build filter chips
  static Widget buildFilterChips({
    required ReportFilter filter,
    required ValueChanged<ReportFilter> onFilterChanged,
  }) {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: const Text('All'),
            selected: !filter.hasFilters,
            onSelected: (selected) {
              if (selected) onFilterChanged(filter.clear());
            },
          ),
          SizedBox(width: 8.w),
          FilterChip(
            label: const Text('Open'),
            selected: filter.status == ReportStatus.open,
            onSelected: (selected) {
              onFilterChanged(filter.copyWith(
                status: selected ? ReportStatus.open : null,
              ));
            },
          ),
          SizedBox(width: 8.w),
          FilterChip(
            label: const Text('High Priority'),
            selected: filter.priority == ReportPriority.high,
            onSelected: (selected) {
              onFilterChanged(filter.copyWith(
                priority: selected ? ReportPriority.high : null,
              ));
            },
          ),
        ],
      ),
    );
  }

  /// Build search bar
  static Widget buildSearchBar({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.all(16.w),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search reports...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(TailwindRadius.lg),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  /// Get category text
  static String _getCategoryText(ReportCategory category) {
    switch (category) {
      case ReportCategory.equipment:
        return ReportsConstants.equipmentCategory;
      case ReportCategory.stockout:
        return ReportsConstants.stockoutCategory;
      case ReportCategory.facility:
        return ReportsConstants.facilityCategory;
      case ReportCategory.staff:
        return ReportsConstants.staffCategory;
      case ReportCategory.other:
        return ReportsConstants.otherCategory;
    }
  }

  /// Get priority text
  static String _getPriorityText(ReportPriority priority) {
    switch (priority) {
      case ReportPriority.low:
        return ReportsConstants.lowPriority;
      case ReportPriority.medium:
        return ReportsConstants.mediumPriority;
      case ReportPriority.high:
        return ReportsConstants.highPriority;
      case ReportPriority.urgent:
        return ReportsConstants.urgentPriority;
    }
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
