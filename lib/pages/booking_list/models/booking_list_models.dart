/// Models and constants for booking list functionality
class BookingListConstants {
  // UI labels
  static const String pageTitle = 'My Bookings';
  static const String noBookingsMessage = 'No bookings found';
  static const String loadingMessage = 'Loading bookings...';
  static const String cancelBookingLabel = 'Cancel';
  static const String bookingCancelledMessage = 'Booking cancelled';
  static const String failedToLoadMessage = 'Failed to load bookings: ';
  static const String failedToCancelMessage = 'Failed to cancel: ';
  
  // Status labels
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
  
  // Date format
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
}

/// Booking item model for list display
class BookingListItem {
  final String id;
  final String facilityName;
  final DateTime date;
  final String time;
  final String status;
  final String? notes;
  final Map<String, dynamic> facility;
  final Map<String, dynamic> rawData;

  BookingListItem({
    required this.id,
    required this.facilityName,
    required this.date,
    required this.time,
    required this.status,
    this.notes,
    required this.facility,
    required this.rawData,
  });

  /// Create from API response
  factory BookingListItem.fromJson(Map<String, dynamic> json) {
    final facility = json['facility'] ?? {};
    final dateStr = json['date'] as String;
    
    return BookingListItem(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      facilityName: facility['name'] as String? ?? 'Unknown Facility',
      date: DateTime.parse(dateStr),
      time: json['time'] as String? ?? '',
      status: json['status'] as String? ?? BookingListConstants.statusPending,
      notes: json['notes'] as String?,
      facility: facility,
      rawData: json,
    );
  }

  /// Check if booking can be cancelled
  bool get canCancel => status == BookingListConstants.statusPending;

  /// Get formatted date for display
  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Get formatted time for display
  String get formattedTime {
    final parts = time.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return time;
  }

  /// Get status display text
  String get statusDisplay {
    switch (status) {
      case BookingListConstants.statusPending:
        return 'Pending';
      case BookingListConstants.statusConfirmed:
        return 'Confirmed';
      case BookingListConstants.statusCompleted:
        return 'Completed';
      case BookingListConstants.statusCancelled:
        return 'Cancelled';
      default:
        return status;
    }
  }

  /// Get status color
  Color get statusColor {
    switch (status) {
      case BookingListConstants.statusPending:
        return Colors.orange;
      case BookingListConstants.statusConfirmed:
        return Colors.green;
      case BookingListConstants.statusCompleted:
        return Colors.blue;
      case BookingListConstants.statusCancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Check if booking is in the past
  bool get isInPast {
    final bookingDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.tryParse(time.split(':')[0]) ?? 0,
      int.tryParse(time.split(':')[1]) ?? 0,
    );
    return bookingDateTime.isBefore(DateTime.now());
  }

  /// Get booking subtitle
  String get subtitle {
    final notesText = notes != null && notes!.isNotEmpty ? '\nNotes: $notes' : '';
    return '$formattedDate at $formattedTime\nStatus: $statusDisplay$notesText';
  }
}

/// Booking list state
class BookingListState {
  final List<BookingListItem> bookings;
  final bool isLoading;
  final String? error;

  const BookingListState({
    this.bookings = const [],
    this.isLoading = true,
    this.error,
  });

  BookingListState copyWith({
    List<BookingListItem>? bookings,
    bool? isLoading,
    String? error,
  }) {
    return BookingListState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Check if list is empty
  bool get isEmpty => bookings.isEmpty && !isLoading;

  /// Get bookings that can be cancelled
  List<BookingListItem> get cancellableBookings {
    return bookings.where((booking) => booking.canCancel).toList();
  }

  /// Clear error
  BookingListState clearError() => copyWith(error: null);

  /// Set loading
  BookingListState setLoading(bool loading) => copyWith(isLoading: loading, error: null);

  /// Set error
  BookingListState setError(String error) => copyWith(isLoading: false, error: error);

  /// Set bookings
  BookingListState setBookings(List<BookingListItem> bookings) => 
      copyWith(bookings: bookings, isLoading: false, error: null);
}

/// Booking list filter options
class BookingListFilter {
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? facilityId;

  BookingListFilter({
    this.status,
    this.startDate,
    this.endDate,
    this.facilityId,
  });

  BookingListFilter copyWith({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? facilityId,
  }) {
    return BookingListFilter(
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      facilityId: facilityId ?? this.facilityId,
    );
  }

  /// Check if filter is active
  bool get isActive => status != null || startDate != null || endDate != null || facilityId != null;

  /// Reset filter
  BookingListFilter reset() => const BookingListFilter();

  /// Apply filter to bookings
  List<BookingListItem> apply(List<BookingListItem> bookings) {
    var filtered = bookings;

    if (status != null) {
      filtered = filtered.where((b) => b.status == status).toList();
    }

    if (startDate != null) {
      filtered = filtered.where((b) => b.date.isAfter(startDate!.subtract(const Duration(days: 1)))).toList();
    }

    if (endDate != null) {
      filtered = filtered.where((b) => b.date.isBefore(endDate!.add(const Duration(days: 1)))).toList();
    }

    if (facilityId != null) {
      filtered = filtered.where((b) => b.facility['_id'] == facilityId).toList();
    }

    return filtered;
  }
}

/// Booking action result
class BookingActionResult {
  final bool success;
  final String? message;

  BookingActionResult({
    required this.success,
    this.message,
  });

  factory BookingActionResult.success(String message) {
    return BookingActionResult(
      success: true,
      message: message,
    );
  }

  factory BookingActionResult.failure(String message) {
    return BookingActionResult(
      success: false,
      message: message,
    );
  }
}
