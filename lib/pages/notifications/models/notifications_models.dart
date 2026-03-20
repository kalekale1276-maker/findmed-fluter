/// Models and constants for notifications functionality
class NotificationsConstants {
  // UI labels
  static const String pageTitle = 'Notifications';
  static const String refreshTooltip = 'Refresh';
  static const String markAllReadTooltip = 'Mark all read';
  static const String showAllLabel = 'Show all (ignore intervals)';
  static const String markAllReadTitle = 'Mark all as read';
  static const String markAllReadQuestion = 'Mark notifications as read?';
  static const String closeLabel = 'Close';
  static const String markReadLabel = 'Mark read';
  static const String noNotificationsMessage = 'No notifications';
  static const String failedToLoadMessage = 'Failed to load: ';
  static const String visibleLabel = 'Visible';
  static const String expiringInLabel = 'Expiring in';
  static const String minutesLabel = 'm';
  static const String expiringSoonLabel = 'Expiring soon';
  static const String scheduledLabel = 'Scheduled';
  static const String pinnedLabel = 'Pinned';
  
  // Animation durations
  static const int animationDurationMs = 300;
  static const int refreshDelayMs = 500;
  
  // Display settings
  static const int maxItemsPerPage = 50;
  static const int maxImageWidth = 56;
  static const int maxImageHeight = 56;
  static const double bottomSheetInitialSize = 0.6;
  static const double bottomSheetMinSize = 0.3;
  static const double bottomSheetMaxSize = 0.95;
  static const double imageHeight = 180.0;
  
  // API endpoints
  static const String notificationsEndpoint = '/api/notifications';
  static const String contentEndpoint = '/api/content';
  static const String cleanupEndpoint = '/api/notifications/cleanup';
}

/// Notification type enum
enum NotificationType {
  content,
  contentReminder,
  system,
  reminder,
  alert,
}

/// Notification model
class NotificationItem {
  final String id;
  final String? contentId;
  final NotificationType type;
  final String title;
  final String body;
  final String? imageUrl;
  final String? caption;
  final bool pinned;
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool read;
  final bool upcoming;
  final int? minutesRemaining;
  final Map<String, dynamic>? metadata;

  NotificationItem({
    required this.id,
    this.contentId,
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    this.caption,
    this.pinned = false,
    this.startAt,
    this.endAt,
    required this.createdAt,
    this.updatedAt,
    this.read = false,
    this.upcoming = false,
    this.minutesRemaining,
    this.metadata,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final type = _parseType(json['type']);
    
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      contentId: json['contentId']?.toString(),
      type: type,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      caption: json['caption']?.toString(),
      pinned: json['pinned'] == true,
      startAt: _parseDateTime(json['startAt']),
      endAt: _parseDateTime(json['endAt']),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt']),
      read: json['read'] == true,
      upcoming: json['upcoming'] == true,
      minutesRemaining: _toInt(json['minutesRemaining']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  factory NotificationItem.fromContent(Map<String, dynamic> content) {
    return NotificationItem(
      id: content['id']?.toString() ?? '',
      contentId: content['id']?.toString(),
      type: NotificationType.content,
      title: content['title']?.toString() ?? '',
      body: content['body']?.toString() ?? '',
      imageUrl: content['imageUrl']?.toString(),
      caption: content['caption']?.toString(),
      pinned: content['pinned'] == true,
      startAt: _parseDateTime(content['startAt']),
      endAt: _parseDateTime(content['endAt']),
      createdAt: _parseDateTime(content['updatedAt']) ?? 
                 _parseDateTime(content['createdAt']) ?? 
                 DateTime.now(),
    );
  }

  /// Parse notification type
  static NotificationType _parseType(dynamic type) {
    final typeStr = type?.toString().toLowerCase();
    switch (typeStr) {
      case 'content':
        return NotificationType.content;
      case 'content_reminder':
        return NotificationType.contentReminder;
      case 'system':
        return NotificationType.system;
      case 'reminder':
        return NotificationType.reminder;
      case 'alert':
        return NotificationType.alert;
      default:
        return NotificationType.system;
    }
  }

  /// Parse date time
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  /// Parse int
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentId': contentId,
      'type': type.toString(),
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'caption': caption,
      'pinned': pinned,
      'startAt': startAt?.toIso8601String(),
      'endAt': endAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'read': read,
      'upcoming': upcoming,
      'minutesRemaining': minutesRemaining,
      'metadata': metadata,
    };
  }

  /// Create copy with updated fields
  NotificationItem copyWith({
    String? id,
    String? contentId,
    NotificationType? type,
    String? title,
    String? body,
    String? imageUrl,
    String? caption,
    bool? pinned,
    DateTime? startAt,
    DateTime? endAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? read,
    bool? upcoming,
    int? minutesRemaining,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      pinned: pinned ?? this.pinned,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      read: read ?? this.read,
      upcoming: upcoming ?? this.upcoming,
      minutesRemaining: minutesRemaining ?? this.minutesRemaining,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if notification is currently active
  bool get isActive {
    final now = DateTime.now().toUtc();
    
    // Check start time
    if (startAt != null && now.isBefore(startAt!)) {
      return false;
    }
    
    // Check end time
    if (endAt != null && now.isAfter(endAt!)) {
      return false;
    }
    
    return true;
  }

  /// Check if notification is expired
  bool get isExpired {
    if (endAt == null) return false;
    return DateTime.now().toUtc().isAfter(endAt!);
  }

  /// Check if notification is scheduled
  bool get isScheduled {
    if (startAt == null) return false;
    return DateTime.now().toUtc().isBefore(startAt!);
  }

  /// Check if has meaningful content
  bool get hasContent {
    final titleTrimmed = title.trim();
    final bodyTrimmed = body.trim();
    return titleTrimmed.isNotEmpty || bodyTrimmed.isNotEmpty;
  }

  /// Get formatted creation date
  String get formattedCreatedAt {
    return _formatDateTime(createdAt);
  }

  /// Get formatted start date
  String get formattedStartAt {
    return startAt != null ? _formatDateTime(startAt!) : '—';
  }

  /// Get formatted end date
  String get formattedEndAt {
    return endAt != null ? _formatDateTime(endAt!) : '—';
  }

  /// Get subtitle parts
  List<String> get subtitleParts {
    final parts = <String>[];
    
    if (caption != null && caption!.isNotEmpty) {
      parts.add(caption!);
    }
    
    if (body.isNotEmpty) {
      parts.add(body);
    }
    
    if (minutesRemaining != null) {
      parts.add('${NotificationsConstants.expiringInLabel} ${minutesRemaining}${NotificationsConstants.minutesLabel}');
    } else if (startAt != null || endAt != null) {
      parts.add('${NotificationsConstants.visibleLabel}: ${formattedStartAt} → ${formattedEndAt}');
    }
    
    return parts;
  }

  /// Get subtitle text
  String get subtitle => subtitleParts.join('\n');

  /// Format date time
  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${local.day}/${local.month}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  /// Get unique key
  String get uniqueKey {
    return contentId ?? id;
  }

  /// Get display priority (higher = more important)
  int get displayPriority {
    int priority = 0;
    
    if (pinned) priority += 100;
    if (!read) priority += 50;
    if (type == NotificationType.contentReminder) priority += 25;
    if (isScheduled) priority += 10;
    
    return priority;
  }
}

/// Notifications state model
class NotificationsState {
  final List<NotificationItem> items;
  final bool isLoading;
  final bool isRefreshing;
  final bool showAll;
  final String? error;
  final int unreadCount;

  const NotificationsState({
    this.items = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.showAll = false,
    this.error,
    this.unreadCount = 0,
  });

  NotificationsState copyWith({
    List<NotificationItem>? items,
    bool? isLoading,
    bool? isRefreshing,
    bool? showAll,
    String? error,
    int? unreadCount,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      showAll: showAll ?? this.showAll,
      error: error ?? this.error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  /// Clear error
  NotificationsState clearError() => copyWith(error: null);

  /// Set loading
  NotificationsState setLoading(bool loading) => copyWith(isLoading: loading, error: null);

  /// Set refreshing
  NotificationsState setRefreshing(bool refreshing) => copyWith(isRefreshing: refreshing, error: null);

  /// Set error
  NotificationsState setError(String error) => copyWith(isLoading: false, isRefreshing: false, error: error);

  /// Toggle show all
  NotificationsState toggleShowAll() => copyWith(showAll: !showAll);

  /// Update items
  NotificationsState updateItems(List<NotificationItem> newItems) {
    final unreadCount = newItems.where((item) => !item.read).length;
    return copyWith(items: newItems, unreadCount: unreadCount);
  }

  /// Check if has error
  bool get hasError => error != null;

  /// Check if has items
  bool get hasItems => items.isNotEmpty;

  /// Check if is loading
  bool get isAnyLoading => isLoading || isRefreshing;

  /// Get unread items
  List<NotificationItem> get unreadItems => items.where((item) => !item.read).toList();

  /// Get pinned items
  List<NotificationItem> get pinnedItems => items.where((item) => item.pinned).toList();

  /// Get active items
  List<NotificationItem> get activeItems => items.where((item) => item.isActive).toList();

  /// Get expired items
  List<NotificationItem> get expiredItems => items.where((item) => item.isExpired).toList();
}

/// Notification filter options
class NotificationFilter {
  final bool showAll;
  final bool showExpired;
  final bool showScheduled;
  final bool showOnlyUnread;
  final List<NotificationType>? types;
  final DateTime? startDate;
  final DateTime? endDate;

  const NotificationFilter({
    this.showAll = false,
    this.showExpired = false,
    this.showScheduled = false,
    this.showOnlyUnread = false,
    this.types,
    this.startDate,
    this.endDate,
  });

  /// Create copy with updated fields
  NotificationFilter copyWith({
    bool? showAll,
    bool? showExpired,
    bool? showScheduled,
    bool? showOnlyUnread,
    List<NotificationType>? types,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return NotificationFilter(
      showAll: showAll ?? this.showAll,
      showExpired: showExpired ?? this.showExpired,
      showScheduled: showScheduled ?? this.showScheduled,
      showOnlyUnread: showOnlyUnread ?? this.showOnlyUnread,
      types: types ?? this.types,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  /// Apply filter to items
  List<NotificationItem> apply(List<NotificationItem> items) {
    if (showAll) {
      return items.where((item) => !item.isExpired).toList();
    }

    return items.where((item) {
      // Check expired filter
      if (!showExpired && item.isExpired) return false;

      // Check scheduled filter
      if (!showScheduled && item.isScheduled) return false;

      // Check unread filter
      if (showOnlyUnread && item.read) return false;

      // Check type filter
      if (types != null && !types!.contains(item.type)) return false;

      // Check date range filter
      final createdAt = item.createdAt;
      if (startDate != null && createdAt.isBefore(startDate!)) return false;
      if (endDate != null && createdAt.isAfter(endDate!)) return false;

      // Check content filter
      if (!item.hasContent) return false;

      return true;
    }).toList();
  }
}

/// Notification statistics
class NotificationStatistics {
  final int totalCount;
  final int unreadCount;
  final int pinnedCount;
  final int expiredCount;
  final int scheduledCount;
  final Map<NotificationType, int> typeCounts;
  final DateTime lastUpdated;

  NotificationStatistics({
    required this.totalCount,
    required this.unreadCount,
    required this.pinnedCount,
    required this.expiredCount,
    required this.scheduledCount,
    required this.typeCounts,
    required this.lastUpdated,
  });

  /// Calculate statistics from items
  factory NotificationStatistics.fromItems(List<NotificationItem> items) {
    final now = DateTime.now();
    
    final totalCount = items.length;
    final unreadCount = items.where((item) => !item.read).length;
    final pinnedCount = items.where((item) => item.pinned).length;
    final expiredCount = items.where((item) => item.isExpired).length;
    final scheduledCount = items.where((item) => item.isScheduled).length;
    
    final typeCounts = <NotificationType, int>{};
    for (final item in items) {
      typeCounts[item.type] = (typeCounts[item.type] ?? 0) + 1;
    }

    return NotificationStatistics(
      totalCount: totalCount,
      unreadCount: unreadCount,
      pinnedCount: pinnedCount,
      expiredCount: expiredCount,
      scheduledCount: scheduledCount,
      typeCounts: typeCounts,
      lastUpdated: now,
    );
  }

  /// Get unread percentage
  double get unreadPercentage {
    if (totalCount == 0) return 0.0;
    return unreadCount / totalCount;
  }

  /// Get most common type
  NotificationType? get mostCommonType {
    if (typeCounts.isEmpty) return null;
    
    return typeCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Check if has data
  bool get hasData => totalCount > 0;
}

/// Notification action result
class NotificationResult {
  final bool success;
  final String? message;
  final NotificationItem? notification;

  NotificationResult({
    required this.success,
    this.message,
    this.notification,
  });

  factory NotificationResult.success({
    String? message,
    NotificationItem? notification,
  }) {
    return NotificationResult(
      success: true,
      message: message,
      notification: notification,
    );
  }

  factory NotificationResult.failure(String message) {
    return NotificationResult(
      success: false,
      message: message,
    );
  }
}
