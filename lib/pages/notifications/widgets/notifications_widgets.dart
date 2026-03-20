import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../models/notifications_models.dart';
import '../services/notifications_services.dart';

/// UI components for notifications functionality
class NotificationsWidgets {
  /// Build notification list item
  static Widget buildNotificationItem({
    required NotificationItem notification,
    required VoidCallback onTap,
    bool isUpcoming = false,
  }) {
    final subtitleParts = notification.subtitleParts;
    final hasImage = notification.imageUrl != null && notification.imageUrl!.isNotEmpty;
    
    return InkWell(
      onTap: onTap,
      child: isUpcoming
          ? _buildUpcomingTile(notification)
          : _buildRegularTile(notification, hasImage, subtitleParts),
    );
  }

  /// Build regular notification tile
  static Widget _buildRegularTile(
    NotificationItem notification,
    bool hasImage,
    List<String> subtitleParts,
  ) {
    return ListTile(
      isThreeLine: subtitleParts.length > 1,
      leading: hasImage
          ? _buildNotificationImage(notification.imageUrl!)
          : _buildNotificationIcon(notification),
      title: _buildNotificationTitle(notification),
      subtitle: Text(notification.subtitle),
      trailing: _buildNotificationTrailing(notification),
    );
  }

  /// Build upcoming notification tile
  static Widget _buildUpcomingTile(NotificationItem notification) {
    return ListTile(
      title: Text(
        '${NotificationsConstants.visibleLabel}: ${notification.formattedStartAt} → ${notification.formattedEndAt}',
      ),
      leading: const Icon(Icons.schedule),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            notification.formattedCreatedAt,
            style: const TextStyle(fontSize: 11),
          ),
          if (notification.read)
            const Icon(Icons.check, size: 14, color: Colors.green),
        ],
      ),
    );
  }

  /// Build notification image
  static Widget _buildNotificationImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6.r),
      child: Image.network(
        imageUrl,
        width: NotificationsConstants.maxImageWidth.w,
        height: NotificationsConstants.maxImageHeight.h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.image),
      ),
    );
  }

  /// Build notification icon
  static Widget _buildNotificationIcon(NotificationItem notification) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Icon(Icons.notifications),
        if (!notification.read)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 8.w,
              height: 8.w,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  /// Build notification title
  static Widget _buildNotificationTitle(NotificationItem notification) {
    return Row(
      children: [
        Expanded(
          child: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
              color: Get.context!.isDarkMode 
                  ? (notification.read ? Colors.white70 : Colors.white)
                  : (notification.read ? TailwindColors.gray700 : TailwindColors.gray900),
            ),
          ),
        ),
        if (notification.pinned)
          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: Icon(Icons.push_pin, size: 14.w),
          ),
      ],
    );
  }

  /// Build notification trailing
  static Widget _buildNotificationTrailing(NotificationItem notification) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          notification.formattedCreatedAt,
          style: const TextStyle(fontSize: 11),
        ),
        if (notification.read)
          const Icon(Icons.check, size: 14, color: Colors.green),
      ],
    );
  }

  /// Build notification detail bottom sheet
  static Widget buildNotificationDetailSheet({
    required NotificationItem notification,
    required VoidCallback onClose,
    required VoidCallback onMarkRead,
    bool isRead = false,
  }) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: NotificationsConstants.bottomSheetInitialSize,
      minChildSize: NotificationsConstants.bottomSheetMinSize,
      maxChildSize: NotificationsConstants.bottomSheetMaxSize,
      builder: (_, controller) {
        return SingleChildScrollView(
          controller: controller,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                if (notification.imageUrl != null && notification.imageUrl!.isNotEmpty)
                  _buildDetailImage(notification.imageUrl!),
                
                SizedBox(height: 12.h),
                
                // Title with pin icon
                _buildDetailTitle(notification),
                
                SizedBox(height: 8.h),
                
                // Chips
                _buildDetailChips(notification),
                
                SizedBox(height: 12.h),
                
                // Caption
                if (notification.caption != null && notification.caption!.isNotEmpty) ...[
                  Text(
                    notification.caption!,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Get.context!.isDarkMode ? Colors.white70 : TailwindColors.gray600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],
                
                // Body
                if (notification.body.isNotEmpty)
                  Text(
                    notification.body,
                    style: Theme.of(Get.context!).textTheme.bodyLarge,
                  ),
                
                SizedBox(height: 16.h),
                
                // Date information
                if (notification.startAt != null || notification.endAt != null)
                  Text(
                    '${NotificationsConstants.visibleLabel}: ${notification.formattedStartAt} → ${notification.formattedEndAt}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                
                SizedBox(height: 18.h),
                
                // Actions
                _buildDetailActions(onClose, onMarkRead, isRead),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build detail image
  static Widget _buildDetailImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: NotificationsConstants.imageHeight.h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox(),
      ),
    );
  }

  /// Build detail title
  static Widget _buildDetailTitle(NotificationItem notification) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            notification.title,
            style: Theme.of(Get.context!).textTheme.titleLarge,
          ),
        ),
        if (notification.pinned)
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(Icons.push_pin_outlined),
          ),
      ],
    );
  }

  /// Build detail chips
  static Widget _buildDetailChips(NotificationItem notification) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 6.h,
      children: [
        if (notification.pinned)
          Chip(
            label: Text(NotificationsConstants.pinnedLabel),
            backgroundColor: Colors.blue[50],
          ),
        if (notification.type == NotificationType.contentReminder)
          Chip(
            label: Text(
              notification.minutesRemaining != null
                  ? '${NotificationsConstants.expiringInLabel} ${notification.minutesRemaining}${NotificationsConstants.minutesLabel}'
                  : NotificationsConstants.expiringSoonLabel,
            ),
            backgroundColor: Colors.orange[50],
          ),
        if (notification.startAt != null && notification.isScheduled)
          Chip(
            label: Text(NotificationsConstants.scheduledLabel),
            backgroundColor: Colors.yellow[50],
          ),
      ],
    );
  }

  /// Build detail actions
  static Widget _buildDetailActions(
    VoidCallback onClose,
    VoidCallback onMarkRead,
    bool isRead,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: onClose,
          child: Text(NotificationsConstants.closeLabel),
        ),
        if (!isRead)
          ElevatedButton(
            onPressed: onMarkRead,
            child: Text(NotificationsConstants.markReadLabel),
          ),
      ],
    );
  }

  /// Build empty state
  static Widget buildEmptyState({
    String message = NotificationsConstants.noNotificationsMessage,
    IconData icon = Icons.notifications_none,
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
            'You\'re all caught up!',
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
            '${NotificationsConstants.failedToLoadMessage}$error',
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
    required NotificationStatistics stats,
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
              'Notification Statistics',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
              ),
            ),
            SizedBox(height: 12.h),
            _buildStatRow('Total', stats.totalCount.toString()),
            _buildStatRow('Unread', stats.unreadCount.toString()),
            _buildStatRow('Pinned', stats.pinnedCount.toString()),
            _buildStatRow('Expired', stats.expiredCount.toString()),
            _buildStatRow('Scheduled', stats.scheduledCount.toString()),
            SizedBox(height: 8.h),
            Text(
              'By Type:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Get.context!.isDarkMode ? Colors.white : TailwindColors.gray900,
              ),
            ),
            SizedBox(height: 4.h),
            ...stats.typeCounts.entries.map((entry) => 
              Padding(
                padding: EdgeInsets.only(left: 8.w, top: 2.h),
                child: Text(
                  '${entry.key.toString().split('.').last}: ${entry.value}',
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

  /// Build filter chips
  static Widget buildFilterChips({
    required NotificationFilter filter,
    required ValueChanged<NotificationFilter> onFilterChanged,
  }) {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: const Text('All'),
            selected: filter.showAll,
            onSelected: (selected) {
              onFilterChanged(filter.copyWith(showAll: selected));
            },
          ),
          SizedBox(width: 8.w),
          FilterChip(
            label: const Text('Unread'),
            selected: filter.showOnlyUnread,
            onSelected: (selected) {
              onFilterChanged(filter.copyWith(showOnlyUnread: selected));
            },
          ),
          SizedBox(width: 8.w),
          FilterChip(
            label: const Text('Pinned'),
            selected: filter.types?.contains(NotificationType.content) == true,
            onSelected: (selected) {
              final types = selected ? [NotificationType.content] : null;
              onFilterChanged(filter.copyWith(types: types));
            },
          ),
        ],
      ),
    );
  }

  /// Build mark all read dialog
  static Widget buildMarkAllReadDialog({
    required int unreadCount,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    return AlertDialog(
      title: Text(NotificationsConstants.markAllReadTitle),
      content: Text('Mark $unreadCount notifications as read?'),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(NotificationsConstants.closeLabel),
        ),
        TextButton(
          onPressed: onConfirm,
          child: const Text('Yes'),
        ),
      ],
    );
  }

  /// Build show all menu item
  static PopupMenuItem<String> buildShowAllMenuItem({
    required bool showAll,
    required ValueChanged<bool> onChanged,
  }) {
    return PopupMenuItem(
      value: 'show_all',
      child: Row(
        children: [
          Checkbox(
            value: showAll,
            onChanged: (_) => onChanged(!showAll),
          ),
          SizedBox(width: 8.w),
          Text(NotificationsConstants.showAllLabel),
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
