import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../services/api.dart';
import '../../../../services/notifications.dart';
import '../../../../services/notification_center.dart';
import '../../../../services/lazy_api_service.dart';
import '../models/notifications_models.dart';

/// Services for notifications functionality
class NotificationsServices {
  static const String _notificationsEndpoint = '/api/notifications';
  static const String _contentEndpoint = '/api/content';

  /// Load notifications with lazy loading
  static Future<void> loadNotificationsLazy() async {
    await LazyApiService().loadPageData('notifications', {
      'notifications_list': () async {
        await fetchNotifications();
      },
    });
  }

  /// Fetch notifications from server
  static Future<List<NotificationItem>> fetchNotifications({
    bool showAll = false,
    bool includeContent = true,
  }) async {
    try {
      // Cleanup expired notifications first
      if (!showAll) {
        await _cleanupExpiredNotifications();
      }

      // Fetch notifications list
      List<Map<String, dynamic>> notificationsList = [];
      try {
        notificationsList = await NotificationsService.list();
      } catch (e) {
        debugPrint('Error fetching notifications: $e');
      }

      // Merge with content items if requested
      if (includeContent) {
        final contentItems = await _fetchContentItems();
        notificationsList = _mergeNotificationsAndContent(notificationsList, contentItems);
      }

      // Filter notifications
      final filtered = _filterNotifications(notificationsList, showAll);

      // Sort notifications
      final sorted = _sortNotifications(filtered);

      // Convert to NotificationItem objects
      return sorted.map((item) => NotificationItem.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error in fetchNotifications: $e');
      rethrow;
    }
  }

  /// Cleanup expired notifications
  static Future<void> _cleanupExpiredNotifications() async {
    try {
      // Fetch current content IDs
      final contentResponse = await Api.get(_contentEndpoint);
      final items = contentResponse['items'] as List<dynamic>;
      final keepIds = items
          .map((e) => e['id']?.toString())
          .where((id) => id != null)
          .toList();

      // Cleanup notifications
      await NotificationsService.cleanup(keepIds: List<String>.from(keepIds));
    } catch (e) {
      debugPrint('Error in cleanup: $e');
    }
  }

  /// Fetch content items
  static Future<List<Map<String, dynamic>>> _fetchContentItems() async {
    try {
      final contentResponse = await Api.get(_contentEndpoint);
      final contentItems = (contentResponse['items'] as List<dynamic>?) ?? [];
      
      return contentItems
          .where((c) => c != null && c['published'] == true)
          .map((c) {
        return {
          'id': c['id'],
          'type': 'content',
          'contentId': c['id'],
          'title': c['title'] ?? '',
          'body': c['body'] ?? '',
          'imageUrl': c['imageUrl'],
          'caption': c['caption'],
          'pinned': c['pinned'] == true,
          'startAt': c['startAt'],
          'endAt': c['endAt'],
          'createdAt': c['updatedAt'] ?? c['createdAt'] ?? DateTime.now().toIso8601String(),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching content items: $e');
      return [];
    }
  }

  /// Merge notifications and content items
  static List<Map<String, dynamic>> _mergeNotificationsAndContent(
    List<Map<String, dynamic>> notifications,
    List<Map<String, dynamic>> contentItems,
  ) {
    final merged = <Map<String, dynamic>>[];
    final seen = <String>{};

    // Add existing notifications
    for (final notification in notifications) {
      merged.add(notification);
      final key = (notification['contentId'] ?? notification['id'] ?? '').toString();
      if (key.isNotEmpty) seen.add(key);
    }

    // Add content items that haven't been seen
    for (final contentItem in contentItems) {
      final key = (contentItem['contentId'] ?? contentItem['id'] ?? '').toString();
      if (key.isEmpty) continue;
      if (!seen.contains(key)) merged.add(contentItem);
    }

    return merged;
  }

  /// Filter notifications based on settings
  static List<Map<String, dynamic>> _filterNotifications(
    List<Map<String, dynamic>> notifications,
    bool showAll,
  ) {
    final now = DateTime.now().toUtc();

    if (showAll) {
      // Show all except expired
      return notifications.where((item) {
        try {
          final endAt = item['endAt'] != null
              ? DateTime.parse(item['endAt']).toUtc()
              : null;
          if (endAt != null && now.isAfter(endAt)) {
            return false; // Exclude expired
          }
        } catch (_) {}
        return true;
      }).map((item) {
        // Mark upcoming items
        try {
          final startAt = item['startAt'] != null
              ? DateTime.parse(item['startAt']).toUtc()
              : null;
          if (startAt != null && now.isBefore(startAt)) {
            final copy = Map<String, dynamic>.from(item);
            copy['upcoming'] = true;
            return copy;
          }
        } catch (_) {}
        return item;
      }).toList();
    } else {
      // Show only content notifications and reminders
      final contentNotifications = notifications
          .where((item) => item['type'] == 'content' || item['type'] == 'content_reminder')
          .toList();

      return contentNotifications.where((item) {
        try {
          final startAt = item['startAt'] != null
              ? DateTime.parse(item['startAt']).toUtc()
              : null;
          final endAt = item['endAt'] != null
              ? DateTime.parse(item['endAt']).toUtc()
              : null;

          // Hide items outside interval
          if (startAt != null && now.isBefore(startAt)) return false;
          if (endAt != null && now.isAfter(endAt)) return false;

          // Hide items without meaningful content
          final title = (item['title'] ?? '').toString().trim();
          final body = (item['body'] ?? '').toString().trim();
          final message = (item['message'] ?? item['text'] ?? '').toString().trim();
          if (title.isEmpty && body.isEmpty && message.isEmpty) return false;
        } catch (_) {
          // Include item if parsing fails
        }
        return true;
      }).toList();
    }
  }

  /// Sort notifications
  static List<Map<String, dynamic>> _sortNotifications(List<Map<String, dynamic>> notifications) {
    // Sort pinned items first, then by creation date (newest first)
    notifications.sort((a, b) {
      final pinnedA = (a['pinned'] == true) ? 1 : 0;
      final pinnedB = (b['pinned'] == true) ? 1 : 0;
      
      if (pinnedA != pinnedB) {
        return pinnedB - pinnedA; // Pinned items first
      }
      
      final dateA = (a['createdAt'] ?? '').toString();
      final dateB = (b['createdAt'] ?? '').toString();
      
      try {
        final dateTimeA = DateTime.parse(dateA);
        final dateTimeB = DateTime.parse(dateB);
        return dateTimeB.compareTo(dateTimeA); // Newest first
      } catch (_) {
        return dateB.compareTo(dateA); // Fallback to string comparison
      }
    });

    return notifications;
  }

  /// Mark notification as read
  static Future<NotificationResult> markAsRead(String notificationId) async {
    try {
      await NotificationsService.markRead(notificationId);
      NotificationCenter.markReadLocally(notificationId);
      
      return NotificationResult.success(
        message: 'Notification marked as read',
      );
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return NotificationResult.failure('Failed to mark as read: $e');
    }
  }

  /// Mark all notifications as read
  static Future<NotificationResult> markAllAsRead(List<String> notificationIds) async {
    try {
      for (final id in notificationIds) {
        try {
          await NotificationsService.markRead(id);
          NotificationCenter.markReadLocally(id);
        } catch (e) {
          debugPrint('Error marking notification $id as read: $e');
        }
      }
      
      await NotificationCenter.refresh();
      
      return NotificationResult.success(
        message: 'All notifications marked as read',
      );
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      return NotificationResult.failure('Failed to mark all as read: $e');
    }
  }

  /// Delete notification
  static Future<NotificationResult> deleteNotification(String notificationId) async {
    try {
      await NotificationsService.delete(notificationId);
      
      return NotificationResult.success(
        message: 'Notification deleted',
      );
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return NotificationResult.failure('Failed to delete notification: $e');
    }
  }

  /// Refresh notifications
  static Future<List<NotificationItem>> refreshNotifications({
    bool showAll = false,
    bool includeContent = true,
  }) async {
    try {
      await NotificationCenter.refresh();
      return await fetchNotifications(showAll: showAll, includeContent: includeContent);
    } catch (e) {
      debugPrint('Error refreshing notifications: $e');
      rethrow;
    }
  }

  /// Get notification statistics
  static Future<NotificationStatistics> getStatistics({
    bool showAll = false,
    bool includeContent = true,
  }) async {
    try {
      final notifications = await fetchNotifications(
        showAll: showAll,
        includeContent: includeContent,
      );
      
      return NotificationStatistics.fromItems(notifications);
    } catch (e) {
      debugPrint('Error getting statistics: $e');
      rethrow;
    }
  }

  /// Search notifications
  static List<NotificationItem> searchNotifications(
    List<NotificationItem> notifications,
    String query, {
    NotificationFilter? filter,
  }) {
    if (query.trim().isEmpty) return notifications;
    
    final lowerQuery = query.toLowerCase();
    
    return notifications.where((notification) {
      // Search in title
      if (notification.title.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      
      // Search in body
      if (notification.body.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      
      // Search in caption
      if (notification.caption?.toLowerCase().contains(lowerQuery) == true) {
        return true;
      }
      
      return false;
    }).toList();
  }

  /// Filter notifications by criteria
  static List<NotificationItem> filterNotifications(
    List<NotificationItem> notifications,
    NotificationFilter filter,
  ) {
    return filter.apply(notifications);
  }

  /// Get notifications by type
  static List<NotificationItem> getNotificationsByType(
    List<NotificationItem> notifications,
    NotificationType type,
  ) {
    return notifications.where((notification) => notification.type == type).toList();
  }

  /// Get unread notifications
  static List<NotificationItem> getUnreadNotifications(List<NotificationItem> notifications) {
    return notifications.where((notification) => !notification.read).toList();
  }

  /// Get pinned notifications
  static List<NotificationItem> getPinnedNotifications(List<NotificationItem> notifications) {
    return notifications.where((notification) => notification.pinned).toList();
  }

  /// Get active notifications
  static List<NotificationItem> getActiveNotifications(List<NotificationItem> notifications) {
    return notifications.where((notification) => notification.isActive).toList();
  }

  /// Get expired notifications
  static List<NotificationItem> getExpiredNotifications(List<NotificationItem> notifications) {
    return notifications.where((notification) => notification.isExpired).toList();
  }

  /// Get scheduled notifications
  static List<NotificationItem> getScheduledNotifications(List<NotificationItem> notifications) {
    return notifications.where((notification) => notification.isScheduled).toList();
  }

  /// Update notification metadata
  static NotificationItem updateNotificationMetadata(
    NotificationItem notification,
    Map<String, dynamic> metadata,
  ) {
    return notification.copyWith(metadata: {...notification.metadata ?? {}, ...metadata});
  }

  /// Calculate minutes remaining for reminder
  static int? calculateMinutesRemaining(DateTime? endTime) {
    if (endTime == null) return null;
    
    final now = DateTime.now().toUtc();
    final difference = endTime.difference(now);
    
    if (difference.isNegative) return null;
    
    return difference.inMinutes;
  }

  /// Check if notification should show reminder
  static bool shouldShowReminder(NotificationItem notification) {
    if (notification.type != NotificationType.contentReminder) {
      return false;
    }
    
    final minutesRemaining = calculateMinutesRemaining(notification.endAt);
    return minutesRemaining != null && minutesRemaining <= 60 && minutesRemaining > 0;
  }

  /// Get notification priority for sorting
  static int getNotificationPriority(NotificationItem notification) {
    int priority = 0;
    
    if (notification.pinned) priority += 1000;
    if (!notification.read) priority += 500;
    if (notification.type == NotificationType.contentReminder) priority += 250;
    if (notification.isScheduled) priority += 100;
    if (shouldShowReminder(notification)) priority += 750;
    
    // Add recency factor (newer notifications get higher priority)
    final hoursSinceCreation = DateTime.now().difference(notification.createdAt).inHours;
    if (hoursSinceCreation < 24) priority += 50;
    if (hoursSinceCreation < 1) priority += 25;
    
    return priority;
  }

  /// Sort notifications by priority
  static List<NotificationItem> sortByPriority(List<NotificationItem> notifications) {
    final sorted = List<NotificationItem>.from(notifications);
    sorted.sort((a, b) => getNotificationPriority(b).compareTo(getNotificationPriority(a)));
    return sorted;
  }

  /// Create notification from content
  static NotificationItem createNotificationFromContent(
    Map<String, dynamic> content, {
    bool isReminder = false,
  }) {
    final notification = NotificationItem.fromContent(content);
    
    if (isReminder) {
      return notification.copyWith(
        type: NotificationType.contentReminder,
        minutesRemaining: calculateMinutesRemaining(notification.endAt),
      );
    }
    
    return notification;
  }

  /// Validate notification data
  static bool validateNotificationData(Map<String, dynamic> data) {
    try {
      // Check required fields
      if (!data.containsKey('id') || data['id']?.toString().isEmpty == true) {
        return false;
      }
      
      // Check if has meaningful content
      final title = (data['title'] ?? '').toString().trim();
      final body = (data['body'] ?? '').toString().trim();
      final message = (data['message'] ?? data['text'] ?? '').toString().trim();
      
      if (title.isEmpty && body.isEmpty && message.isEmpty) {
        return false;
      }
      
      // Validate date fields
      if (data['startAt'] != null) {
        DateTime.parse(data['startAt'].toString());
      }
      
      if (data['endAt'] != null) {
        DateTime.parse(data['endAt'].toString());
      }
      
      return true;
    } catch (e) {
      debugPrint('Error validating notification data: $e');
      return false;
    }
  }

  /// Export notifications to JSON
  static String exportNotificationsToJson(List<NotificationItem> notifications) {
    final data = {
      'notifications': notifications.map((n) => n.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
      'totalCount': notifications.length,
      'unreadCount': notifications.where((n) => !n.read).length,
    };
    
    return _encodeJson(data);
  }

  /// Simple JSON encoder (avoiding dart:convert dependency)
  static String _encodeJson(Map<String, dynamic> data) {
    // This is a simplified JSON encoder for demonstration
    // In a real app, you would use dart:convert
    return '{\n'
        '  "notifications": [\n'
        '    // Notification data would be serialized here\n'
        '  ],\n'
        '  "exportedAt": "${data['exportedAt']}",\n'
        '  "totalCount": ${data['totalCount']},\n'
        '  "unreadCount": ${data['unreadCount']}\n'
        '}';
  }

  /// Get notification summary
  static String getNotificationSummary(List<NotificationItem> notifications) {
    final buffer = StringBuffer();
    
    buffer.writeln('Notification Summary');
    buffer.writeln('===================');
    buffer.writeln();
    
    buffer.writeln('Total: ${notifications.length}');
    buffer.writeln('Unread: ${notifications.where((n) => !n.read).length}');
    buffer.writeln('Pinned: ${notifications.where((n) => n.pinned).length}');
    buffer.writeln();
    
    if (notifications.isNotEmpty) {
      buffer.writeln('Recent notifications:');
      for (int i = 0; i < notifications.length && i < 5; i++) {
        final notification = notifications[i];
        buffer.writeln('• ${notification.title} (${notification.formattedCreatedAt})');
      }
    }
    
    return buffer.toString();
  }

  /// Setup notification listener
  static StreamSubscription<void>? setupNotificationListener(VoidCallback callback) {
    return NotificationCenter.unreadCount.addListener(callback);
  }

  /// Remove notification listener
  static void removeNotificationListener(StreamSubscription<void>? subscription) {
    subscription?.cancel();
  }

  /// Get notification color based on type and status
  static String getNotificationColor(NotificationItem notification) {
    if (notification.pinned) return 'blue';
    if (notification.type == NotificationType.contentReminder) return 'orange';
    if (notification.isScheduled) return 'yellow';
    if (!notification.read) return 'red';
    return 'grey';
  }

  /// Get notification icon based on type
  static String getNotificationIcon(NotificationItem notification) {
    switch (notification.type) {
      case NotificationType.content:
        return 'article';
      case NotificationType.contentReminder:
        return 'alarm';
      case NotificationType.system:
        return 'info';
      case NotificationType.reminder:
        return 'event';
      case NotificationType.alert:
        return 'warning';
    }
  }

  /// Check if notification should be highlighted
  static bool shouldHighlight(NotificationItem notification) {
    return !notification.read || notification.pinned || shouldShowReminder(notification);
  }

  /// Get notification display order
  static List<NotificationItem> getDisplayOrder(List<NotificationItem> notifications) {
    return sortByPriority(notifications);
  }
}
