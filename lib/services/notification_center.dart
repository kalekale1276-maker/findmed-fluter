import 'package:flutter/foundation.dart';
import 'notifications.dart';

class NotificationCenter {
  static final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);
  static final ValueNotifier<Map<String, dynamic>?> latest =
      ValueNotifier<Map<String, dynamic>?>(null);

  static Future<void> refresh() async {
    try {
      // consider content and reminder notifications for counts/latest by default
      final list = await NotificationsService.list();
      final contentOnly = list
          .where(
              (n) => n['type'] == 'content' || n['type'] == 'content_reminder')
          .toList();
      final unread = contentOnly.where((n) => n['read'] != true).length;
      unreadCount.value = unread;
      if (contentOnly.isNotEmpty) {
        latest.value = Map<String, dynamic>.from(contentOnly.first);
      }
    } catch (e) {
      // ignore
    }
  }

  static void addNotification(Map<String, dynamic> n) {
    try {
      latest.value = Map<String, dynamic>.from(n);
      unreadCount.value = (unreadCount.value ?? 0) + 1;
    } catch (e) {}
  }

  static void markReadLocally(String id) {
    if (unreadCount.value > 0) unreadCount.value = unreadCount.value - 1;
    if (unreadCount.value <= 0) latest.value = null;
  }

  static void clearLatest() {
    latest.value = null;
  }
}
