import 'package:flutter/foundation.dart';
import '../../../../services/booking_api.dart';
import '../models/booking_list_models.dart';

/// Services for booking list functionality
class BookingListServices {
  /// Load all bookings for the user
  static Future<List<BookingListItem>> loadBookings() async {
    try {
      final data = await BookingApi.getBookings();
      
      return data.map((booking) => BookingListItem.fromJson(booking)).toList();
    } catch (e) {
      debugPrint('Error loading bookings: $e');
      rethrow;
    }
  }

  /// Cancel a booking
  static Future<BookingActionResult> cancelBooking(String bookingId) async {
    try {
      await BookingApi.cancelBooking(bookingId);
      return BookingActionResult.success(BookingListConstants.bookingCancelledMessage);
    } catch (e) {
      debugPrint('Error cancelling booking: $e');
      return BookingActionResult.failure('${BookingListConstants.failedToCancelMessage}$e');
    }
  }

  /// Reschedule a booking (mock implementation)
  static Future<BookingActionResult> rescheduleBooking(
    String bookingId,
    DateTime newDate,
    String newTime,
  ) async {
    try {
      // This would typically call an API to reschedule
      // For now, return success as mock
      return BookingActionResult.success('Booking rescheduled successfully');
    } catch (e) {
      debugPrint('Error rescheduling booking: $e');
      return BookingActionResult.failure('Failed to reschedule booking: $e');
    }
  }

  /// Get booking details
  static Future<BookingListItem?> getBookingDetails(String bookingId) async {
    try {
      // This would typically call an API to get booking details
      // For now, return null as mock
      return null;
    } catch (e) {
      debugPrint('Error fetching booking details: $e');
      return null;
    }
  }

  /// Filter bookings based on criteria
  static List<BookingListItem> filterBookings(
    List<BookingListItem> bookings,
    BookingListFilter filter,
  ) {
    return filter.apply(bookings);
  }

  /// Sort bookings by date
  static List<BookingListItem> sortBookingsByDate(
    List<BookingListItem> bookings, {
    bool ascending = true,
  }) {
    final sorted = List<BookingListItem>.from(bookings);
    sorted.sort((a, b) {
      final comparison = a.date.compareTo(b.date);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  /// Group bookings by status
  static Map<String, List<BookingListItem>> groupBookingsByStatus(
    List<BookingListItem> bookings,
  ) {
    final grouped = <String, List<BookingListItem>>{};
    
    for (final booking in bookings) {
      if (!grouped.containsKey(booking.status)) {
        grouped[booking.status] = [];
      }
      grouped[booking.status]!.add(booking);
    }
    
    return grouped;
  }

  /// Get upcoming bookings
  static List<BookingListItem> getUpcomingBookings(List<BookingListItem> bookings) {
    return bookings.where((booking) => !booking.isInPast).toList();
  }

  /// Get past bookings
  static List<BookingListItem> getPastBookings(List<BookingListItem> bookings) {
    return bookings.where((booking) => booking.isInPast).toList();
  }

  /// Get pending bookings
  static List<BookingListItem> getPendingBookings(List<BookingListItem> bookings) {
    return bookings
        .where((booking) => booking.status == BookingListConstants.statusPending)
        .toList();
  }

  /// Get confirmed bookings
  static List<BookingListItem> getConfirmedBookings(List<BookingListItem> bookings) {
    return bookings
        .where((booking) => booking.status == BookingListConstants.statusConfirmed)
        .toList();
  }

  /// Get cancelled bookings
  static List<BookingListItem> getCancelledBookings(List<BookingListItem> bookings) {
    return bookings
        .where((booking) => booking.status == BookingListConstants.statusCancelled)
        .toList();
  }

  /// Get completed bookings
  static List<BookingListItem> getCompletedBookings(List<BookingListItem> bookings) {
    return bookings
        .where((booking) => booking.status == BookingListConstants.statusCompleted)
        .toList();
  }

  /// Search bookings by facility name or notes
  static List<BookingListItem> searchBookings(
    List<BookingListItem> bookings,
    String query,
  ) {
    if (query.isEmpty) return bookings;
    
    final lowerQuery = query.toLowerCase();
    
    return bookings.where((booking) {
      return booking.facilityName.toLowerCase().contains(lowerQuery) ||
             (booking.notes?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Get booking statistics
  static BookingStats getBookingStats(List<BookingListItem> bookings) {
    return BookingStats(
      total: bookings.length,
      pending: getPendingBookings(bookings).length,
      confirmed: getConfirmedBookings(bookings).length,
      cancelled: getCancelledBookings(bookings).length,
      completed: getCompletedBookings(bookings).length,
      upcoming: getUpcomingBookings(bookings).length,
      past: getPastBookings(bookings).length,
    );
  }

  /// Export bookings to CSV (mock implementation)
  static Future<String> exportBookingsToCsv(List<BookingListItem> bookings) async {
    try {
      // This would typically generate and return a CSV string
      // For now, return empty string as mock
      return '';
    } catch (e) {
      debugPrint('Error exporting bookings: $e');
      rethrow;
    }
  }

  /// Share booking details (mock implementation)
  static Future<BookingActionResult> shareBooking(String bookingId) async {
    try {
      // This would typically generate a shareable link or text
      // For now, return success as mock
      return BookingActionResult.success('Booking shared successfully');
    } catch (e) {
      debugPrint('Error sharing booking: $e');
      return BookingActionResult.failure('Failed to share booking: $e');
    }
  }
}

/// Booking statistics
class BookingStats {
  final int total;
  final int pending;
  final int confirmed;
  final int cancelled;
  final int completed;
  final int upcoming;
  final int past;

  BookingStats({
    required this.total,
    required this.pending,
    required this.confirmed,
    required this.cancelled,
    required this.completed,
    required this.upcoming,
    required this.past,
  });

  /// Get completion rate
  double get completionRate {
    if (total == 0) return 0.0;
    return completed / total;
  }

  /// Get cancellation rate
  double get cancellationRate {
    if (total == 0) return 0.0;
    return cancelled / total;
  }

  /// Get confirmation rate
  double get confirmationRate {
    if (total == 0) return 0.0;
    return confirmed / total;
  }
}
