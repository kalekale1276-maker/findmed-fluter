import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/utils/tailwind_extensions.dart';
import 'models/booking_list_models.dart';
import 'services/booking_list_services.dart';
import 'widgets/booking_list_widgets.dart';

/// Booking List Page - Display user's bookings
class BookingsListPage extends StatefulWidget {
  const BookingsListPage({Key? key}) : super(key: key);

  @override
  State<BookingsListPage> createState() => _BookingsListPageState();
}

class _BookingsListPageState extends State<BookingsListPage> 
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // State
  BookingListState _state = const BookingListState();
  BookingListFilter _filter = const BookingListFilter();
  final TextEditingController _searchController = TextEditingController();
  
  // UI state
  bool _showStats = false;
  String _selectedTab = 'all';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadBookings();
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

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // State management
  void _updateState(BookingListState newState) {
    setState(() {
      _state = newState;
    });
  }

  void _setLoading(bool loading) {
    _updateState(_state.setLoading(loading));
  }

  void _setError(String error) {
    _updateState(_state.setError(error));
  }

  void _clearError() {
    _updateState(_state.clearError());
  }

  // Data loading
  Future<void> _loadBookings() async {
    _setLoading(true);
    
    try {
      final bookings = await BookingListServices.loadBookings();
      _updateState(_state.setBookings(bookings));
    } catch (e) {
      _setError('${BookingListConstants.failedToLoadMessage}$e');
    }
  }

  // Booking actions
  Future<void> _cancelBooking(BookingListItem booking) async {
    final confirmed = await _showConfirmationDialog(
      title: 'Cancel Booking',
      content: 'Are you sure you want to cancel your booking at ${booking.facilityName}?',
    );
    
    if (!confirmed) return;
    
    try {
      final result = await BookingListServices.cancelBooking(booking.id);
      
      if (result.success) {
        _showSuccessMessage(result.message!);
        _loadBookings(); // Reload
      } else {
        _showErrorMessage(result.message!);
      }
    } catch (e) {
      _showErrorMessage('Failed to cancel booking: $e');
    }
  }

  // Filter and search
  List<BookingListItem> get _filteredBookings {
    var bookings = _state.bookings;
    
    // Apply tab filter
    bookings = _applyTabFilter(bookings);
    
    // Apply search
    if (_searchController.text.isNotEmpty) {
      bookings = BookingListServices.searchBookings(bookings, _searchController.text);
    }
    
    // Apply custom filter
    bookings = BookingListServices.filterBookings(bookings, _filter);
    
    // Sort by date
    bookings = BookingListServices.sortBookingsByDate(bookings, ascending: false);
    
    return bookings;
  }

  List<BookingListItem> _applyTabFilter(List<BookingListItem> bookings) {
    switch (_selectedTab) {
      case 'upcoming':
        return BookingListServices.getUpcomingBookings(bookings);
      case 'past':
        return BookingListServices.getPastBookings(bookings);
      case 'pending':
        return BookingListServices.getPendingBookings(bookings);
      case 'confirmed':
        return BookingListServices.getConfirmedBookings(bookings);
      case 'cancelled':
        return BookingListServices.getCancelledBookings(bookings);
      case 'completed':
        return BookingListServices.getCompletedBookings(bookings);
      default:
        return bookings;
    }
  }

  // UI helpers
  Future<bool> _showConfirmationDialog({
    required String title,
    required String content,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
    return result ?? false;
  }

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

  void _onBookingTap(BookingListItem booking) {
    // Navigate to booking details (mock implementation)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(booking.facilityName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${booking.formattedDate}'),
            Text('Time: ${booking.formattedTime}'),
            Text('Status: ${booking.statusDisplay}'),
            if (booking.notes != null && booking.notes!.isNotEmpty)
              Text('Notes: ${booking.notes}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    BookingListWidgets.setContext(context);
    
    return Scaffold(
      backgroundColor: context.isDarkMode ? TailwindColors.gray900 : TailwindColors.gray50,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        BookingListConstants.pageTitle,
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
        IconButton(
          icon: Icon(
            _showStats ? Icons.analytics_outlined : Icons.analytics,
            size: context.isMobile ? 20.w : 22.w,
          ),
          onPressed: () {
            setState(() {
              _showStats = !_showStats;
            });
          },
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
    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: Column(
        children: [
          if (_showStats && !_state.isLoading && _state.bookings.isNotEmpty) ...[
            BookingListWidgets.buildStatsCard(
              BookingListServices.getBookingStats(_state.bookings),
            ),
          ],
          BookingListWidgets.buildSearchBar(
            controller: _searchController,
            onChanged: () => setState(() {}),
          ),
          _buildTabChips(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChips() {
    final tabs = [
      {'id': 'all', 'label': 'All'},
      {'id': 'upcoming', 'label': 'Upcoming'},
      {'id': 'past', 'label': 'Past'},
      {'id': 'pending', 'label': 'Pending'},
      {'id': 'confirmed', 'label': 'Confirmed'},
    ];

    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: BookingListWidgets.buildFilterChip(
              label: tab['label'] as String,
              isSelected: _selectedTab == tab['id'],
              onTap: () => setState(() => _selectedTab = tab['id'] as String),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (_state.isLoading) {
      return BookingListWidgets.buildLoadingIndicator();
    }

    if (_state.error != null) {
      return Column(
        children: [
          BookingListWidgets.buildErrorMessage(_state.error!),
          BookingListWidgets.buildSpacing(),
          ElevatedButton(
            onPressed: _loadBookings,
            child: const Text('Retry'),
          ),
        ],
      );
    }

    final filteredBookings = _filteredBookings;

    if (filteredBookings.isEmpty) {
      return BookingListWidgets.buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: filteredBookings.length,
      itemBuilder: (context, index) {
        final booking = filteredBookings[index];
        return BookingListWidgets.buildBookingCard(
          booking: booking,
          onCancel: booking.canCancel ? () => _cancelBooking(booking) : null,
          onTap: () => _onBookingTap(booking),
        );
      },
    );
  }
}
