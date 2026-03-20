import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../services/booking_api.dart';
import '../models/booking_models.dart';

/// Services for booking functionality
class BookingServices {
  /// Create a new booking
  static Future<BookingResult> createBooking(BookingData bookingData) async {
    try {
      await BookingApi.createBooking(
        bookingData.facilityId,
        bookingData.formattedDate,
        bookingData.formattedTime,
        notes: bookingData.notes?.isEmpty == true ? null : bookingData.notes,
      );
      
      return BookingResult.success(
        message: BookingConstants.bookingSuccessMessage,
      );
    } catch (e) {
      debugPrint('Booking creation failed: $e');
      return BookingResult.failure('${BookingConstants.bookingFailedPrefix}$e');
    }
  }

  /// Validate booking data
  static ValidationResult validateBooking(BookingData? bookingData) {
    if (bookingData == null) {
      return ValidationResult.invalid(BookingConstants.selectDateMessage);
    }

    if (bookingData.selectedDate == null) {
      return ValidationResult.invalid('Please select a date');
    }

    if (bookingData.selectedTime == null) {
      return ValidationResult.invalid('Please select a time');
    }

    if (!bookingData.isValid) {
      return ValidationResult.invalid('Please select a future date and time');
    }

    return ValidationResult.valid;
  }

  /// Show date picker
  static Future<DateTime?> showDatePicker(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: BookingConstants.maxBookingDaysInAdvance)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  /// Show time picker
  static Future<TimeOfDay?> showTimePicker(BuildContext context) async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  /// Format date for display
  static String formatDateForDisplay(DateTime? date) {
    if (date == null) return BookingConstants.selectDateLabel;
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Format time for display
  static String formatTimeForDisplay(TimeOfDay? time) {
    if (time == null) return BookingConstants.selectTimeLabel;
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Check if date is in the past
  static bool isDateInPast(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);
    
    return selectedDay.isBefore(today);
  }

  /// Check if time is in the past for today
  static bool isTimeInPast(TimeOfDay time, DateTime date) {
    if (!isSameDay(date, DateTime.now())) return false;
    
    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final selectedMinutes = time.hour * 60 + time.minute;
    
    return selectedMinutes <= currentMinutes;
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  /// Get available time slots for a date (mock implementation)
  static Future<List<TimeSlot>> getAvailableTimeSlots(DateTime date) async {
    // This would typically call an API to get real availability
    // For now, return mock data
    final slots = <TimeSlot>[];
    
    // Generate slots from 8 AM to 6 PM with 30-minute intervals
    for (int hour = 8; hour < 18; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final startTime = TimeOfDay(hour: hour, minute: minute);
        final endTime = minute == 30 
            ? TimeOfDay(hour: hour + 1, minute: 0)
            : TimeOfDay(hour: hour, minute: 30);
            
        // Mock some slots as unavailable
        final isAvailable = !(hour == 12 && minute == 0) || // Lunch break
                             (hour == 15 && minute == 30); // Mock busy slot
        
        slots.add(TimeSlot(
          startTime: startTime,
          endTime: endTime,
          available: isAvailable,
        ));
      }
    }
    
    return slots;
  }

  /// Get date availability
  static Future<DateAvailability> getDateAvailability(DateTime date) async {
    final slots = await getAvailableTimeSlots(date);
    final availableSlots = slots.where((slot) => slot.available).toList();
    
    return DateAvailability(
      date: date,
      availableSlots: slots,
      isFullyBooked: availableSlots.isEmpty,
    );
  }

  /// Get booking details (mock implementation)
  static Future<BookingData?> getBookingDetails(String bookingId) async {
    try {
      // This would typically call an API to get booking details
      // For now, return null as mock
      return null;
    } catch (e) {
      debugPrint('Error fetching booking details: $e');
      return null;
    }
  }

  /// Cancel booking (mock implementation)
  static Future<BookingResult> cancelBooking(String bookingId) async {
    try {
      // This would typically call an API to cancel the booking
      // For now, return success as mock
      return BookingResult.success(message: 'Booking cancelled successfully');
    } catch (e) {
      debugPrint('Error cancelling booking: $e');
      return BookingResult.failure('Failed to cancel booking: $e');
    }
  }

  /// Reschedule booking (mock implementation)
  static Future<BookingResult> rescheduleBooking(String bookingId, BookingData newBookingData) async {
    try {
      // This would typically call an API to reschedule the booking
      // For now, return success as mock
      return BookingResult.success(message: 'Booking rescheduled successfully');
    } catch (e) {
      debugPrint('Error rescheduling booking: $e');
      return BookingResult.failure('Failed to reschedule booking: $e');
    }
  }

  /// Get user's bookings (mock implementation)
  static Future<List<BookingData>> getUserBookings() async {
    try {
      // This would typically call an API to get user's bookings
      // For now, return empty list as mock
      return [];
    } catch (e) {
      debugPrint('Error fetching user bookings: $e');
      return [];
    }
  }
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({required this.isValid, this.errorMessage});

  static const ValidationResult valid = ValidationResult(isValid: true);
  
  ValidationResult.invalid(String message) 
      : isValid = false, errorMessage = message;
}
