import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../../../../services/notification_center.dart';
import '../../../../widgets/branding_widgets.dart';
import 'models/notifications_models.dart';
import 'services/notifications_services.dart';
import 'widgets/notifications_widgets.dart';

/// Notifications Page - User notifications management
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // State
  NotificationsState _state = const NotificationsState();
  NotificationFilter _filter = const NotificationFilter();
  
  // Listeners
  StreamSubscription<void>? _notificationListener;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    
    _fadeController.forward();
    _slideController.forward();
  }

  void _initializeData() async {
    // Set up notification listener first
    _notificationListener = NotificationsServices.setupNotificationListener(_onNotificationChanged);
    
    // Load notifications with lazy loading when page opens
    await _loadNotifications();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _notificationListener?.cancel();
    NotificationsWidgets.clearContext();
    super.dispose();
  }

  // State management
  void _updateState(NotificationsState newState) {
    setState(() {
      _state = newState;
    });
  }

  void _setLoading(bool loading) {
    _updateState(_state.setLoading(loading));
  }

  void _setRefreshing(bool refreshing) {
    _updateState(_state.setRefreshing(refreshing));
  }

  void _setError(String error) {
    _updateState(_state.setError(error));
  }

  void _clearError() {
    _updateState(_state.clearError());
  }

  void _toggleShowAll() {
    final newShowAll = !_state.showAll;
    _updateState(_state.toggleShowAll());
    _loadNotifications();
  }

  void _updateFilter(NotificationFilter newFilter) {
    setState(() {
      _filter = newFilter;
    });
    _applyFilter();
  }

  // Data loading - called when page opens
  Future<void> _loadNotifications() async {
    _setLoading(true);
    _clearError();
    
    try {
      final notifications = await NotificationsServices.loadNotifications();
      
      // Sort notifications by priority and date
      final sortedNotifications = NotificationsServices.sortNotifications(notifications, byPriority: true);
      
      _updateState(_state.updateItems(sortedNotifications));
    } catch (e) {
      _setError('Failed to load notifications: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _refreshNotifications() async {
    _setRefreshing(true);
    _clearError();
    
    try {
      final notifications = await NotificationsServices.refreshNotifications(
        showAll: _state.showAll,
        includeContent: true,
      );
      
      _updateState(_state.updateItems(notifications));
    } catch (e) {
      _setError('Failed to refresh notifications: $e');
    } finally {
      _setRefreshing(false);
    }
  }

  void _applyFilter() {
    if (_state.items.isEmpty) return;
    
    final filteredNotifications = NotificationsServices.filterNotifications(_state.items, _filter);
    _updateState(_state.updateItems(filteredNotifications));
  }

  void _onNotificationChanged() {
    // Refresh list when global unread count changes
    _loadNotifications();
  }

  // Notification actions
  Future<void> _markAsRead(String notificationId) async {
    try {
      final result = await NotificationsServices.markAsRead(notificationId);
      
      if (result.success) {
        // Update local state
        final updatedItems = _state.items.map((item) {
          if (item.id == notificationId) {
            return item.copyWith(read: true);
          }
          return item;
        }).toList();
        
        _updateState(_state.updateItems(updatedItems));
      }
    } catch (e) {
      _setError('Failed to mark as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    final unreadItems = _state.unreadItems;
    if (unreadItems.isEmpty) return;
    
    final unreadIds = unreadItems.map((item) => item.id).toList();
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => NotificationsWidgets.buildMarkAllReadDialog(
        unreadCount: unreadIds.length,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );
    
    if (!confirmed) return;
    
    try {
      final result = await NotificationsServices.markAllAsRead(unreadIds);
      
      if (result.success) {
        // Update local state
        final updatedItems = _state.items.map((item) {
          if (unreadIds.contains(item.id)) {
            return item.copyWith(read: true);
          }
          return item;
        }).toList();
        
        _updateState(_state.updateItems(updatedItems));
      }
    } catch (e) {
      _setError('Failed to mark all as read: $e');
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      final result = await NotificationsServices.deleteNotification(notificationId);
      
      if (result.success) {
        // Update local state
        final updatedItems = _state.items.where((item) => item.id != notificationId).toList();
        _updateState(_state.updateItems(updatedItems));
      }
    } catch (e) {
      _setError('Failed to delete notification: $e');
    }
  }

  // UI interactions
  Future<void> _onNotificationTap(NotificationItem notification) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => NotificationsWidgets.buildNotificationDetailSheet(
        notification: notification,
        onClose: () => Navigator.pop(ctx),
        onMarkRead: () async {
          await _markAsRead(notification.id);
          Navigator.pop(ctx);
        },
        isRead: notification.read,
      ),
    );
  }

  // UI helpers
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    NotificationsWidgets.setContext(context);
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: BrandingWidgets.buildLoadingOverlay(
        isLoading: _state.isLoading,
        message: 'Loading notifications...',
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        NotificationsConstants.pageTitle,
        style: TextStyle(
          fontSize: context.responsiveTextLg,
          fontWeight: FontWeight.bold,
          color: context.isDarkMode ? Colors.white : TailwindColors.gray900,
        ),
      ),
      backgroundColor: context.isDarkMode ? TailwindColors.gray800 : Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(
        color: context.isDarkMode ? Colors.white : TailwindColors.gray700,
        size: context.isMobile ? 22.w : 24.w,
      ),
      actions: [
        // Refresh button
        IconButton(
          tooltip: NotificationsConstants.refreshTooltip,
          icon: const Icon(Icons.refresh),
          onPressed: _refreshNotifications,
        ),
        
        // Mark all read button
        IconButton(
          tooltip: NotificationsConstants.markAllReadTooltip,
          icon: const Icon(Icons.done_all),
          onPressed: _state.unreadCount > 0 ? _markAllAsRead : null,
        ),
        
        // Menu button
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'show_all') {
              _toggleShowAll();
            }
          },
          itemBuilder: (ctx) => [
            NotificationsWidgets.buildShowAllMenuItem(
              showAll: _state.showAll,
              onChanged: (_) => _toggleShowAll(),
            ),
          ],
        ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_state.isLoading) {
      return NotificationsWidgets.buildLoadingIndicator();
    }
    
    if (_state.hasError) {
      return NotificationsWidgets.buildErrorState(_state.error!);
    }
    
    if (!_state.hasItems) {
      return BrandingWidgets.buildEmptyState(
        message: NotificationsConstants.noNotificationsMessage,
        subtitle: 'You\'re all caught up! No new notifications.',
        icon: Icons.notifications_none,
        onAction: _refreshNotifications,
        actionText: 'Refresh',
      );
    }
    
    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      child: Column(
        children: [
          // Filter chips
          NotificationsWidgets.buildFilterChips(
            filter: _filter,
            onFilterChanged: _updateFilter,
          ),
          
          // Statistics card
          if (_state.hasItems)
            FutureBuilder<NotificationStatistics>(
              future: NotificationsServices.getStatistics(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.hasData) {
                  return NotificationsWidgets.buildStatisticsCard(stats: snapshot.data!);
                }
                return const SizedBox.shrink();
              },
            ),
          
          // Notifications list
          Expanded(
            child: ListView.separated(
              itemCount: _state.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, index) {
                final notification = _state.items[index];
                
                return NotificationsWidgets.buildNotificationItem(
                  notification: notification,
                  onTap: () => _onNotificationTap(notification),
                  isUpcoming: notification.upcoming,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
