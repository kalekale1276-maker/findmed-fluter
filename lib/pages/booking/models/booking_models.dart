/// Models and constants for booking functionality
class BookingConstants {
  // Date and time constraints
  static const int maxBookingDaysInAdvance = 365;
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  
  // Validation messages
  static const String selectDateMessage = 'Please select date and time';
  static const String bookingSuccessMessage = 'Booking created successfully';
  static const String bookingFailedPrefix = 'Failed to create booking: ';
  
  // UI labels
  static const String selectDateLabel = 'Select Date';
  static const String selectTimeLabel = 'Select Time';
  static const String bookAppointmentLabel = 'Book Appointment';
  static const String notesLabel = 'Notes (optional)';
  static const String selectDateTimeTitle = 'Select Date and Time';
}

/// Booking data model
class BookingData {
  final String facilityId;
  final String facilityName;
  final DateTime date;
  final TimeOfDay time;
  final String? notes;

  BookingData({
    required this.facilityId,
    required this.facilityName,
    required this.date,
    required this.time,
    this.notes,
  });

  /// Format date as string for API
  String get formattedDate {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Format time as string for API
  String get formattedTime {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Format date for display
  String get displayDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Format time for display
  String get displayTime {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Check if booking is valid
  bool get isValid => date.isAfter(DateTime.now().subtract(const Duration(days: 1)));

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'facilityId': facilityId,
      'date': formattedDate,
      'time': formattedTime,
      'notes': notes?.trim(),
    };
  }

  /// Create from JSON
  factory BookingData.fromJson(Map<String, dynamic> json) {
    final dateStr = json['date'] as String;
    final timeStr = json['time'] as String;
    
    final dateParts = dateStr.split('-');
    final timeParts = timeStr.split(':');
    
    return BookingData(
      facilityId: json['facilityId'] as String,
      facilityName: json['facilityName'] as String? ?? '',
      date: DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      ),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      notes: json['notes'] as String?,
    );
  }
}

/// Booking state model
class BookingState {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final String notes;
  final bool isLoading;
  final String? error;

  const BookingState({
    this.selectedDate,
    this.selectedTime,
    this.notes = '',
    this.isLoading = false,
    this.error,
  });

  BookingState copyWith({
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    String? notes,
    bool? isLoading,
    String? error,
  }) {
    return BookingState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Check if booking data is complete
  bool get isComplete => selectedDate != null && selectedTime != null;

  /// Clear error
  BookingState clearError() => copyWith(error: null);

  /// Set loading
  BookingState setLoading(bool loading) => copyWith(isLoading: loading, error: null);

  /// Set error
  BookingState setError(String error) => copyWith(isLoading: false, error: error);
}

/// Booking result model
class BookingResult {
  final bool success;
  final String? message;
  final String? bookingId;

  BookingResult({
    required this.success,
    this.message,
    this.bookingId,
  });

  factory BookingResult.success({String? message, String? bookingId}) {
    return BookingResult(
      success: true,
      message: message ?? BookingConstants.bookingSuccessMessage,
      bookingId: bookingId,
    );
  }

  factory BookingResult.failure(String message) {
    return BookingResult(
      success: false,
      message: message,
    );
  }
}

/// Time slot model for availability
class TimeSlot {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool available;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    this.available = true,
  });

  /// Format time range for display
  String get displayRange {
    return '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')} - '
           '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  /// Check if a time is within this slot
  bool contains(TimeOfDay time) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final checkMinutes = time.hour * 60 + time.minute;
    
    return checkMinutes >= startMinutes && checkMinutes <= endMinutes;
  }
}

/// Date availability model
class DateAvailability {
  final DateTime date;
  final List<TimeSlot> availableSlots;
  final bool isFullyBooked;

  DateAvailability({
    required this.date,
    required this.availableSlots,
    this.isFullyBooked = false,
  });

  /// Check if a specific time is available
  bool isTimeAvailable(TimeOfDay time) {
    if (isFullyBooked) return false;
    
    return availableSlots.any((slot) => slot.contains(time) && slot.available);
  }

  /// Get available time slots
  List<TimeSlot> get availableSlotsOnly {
    return availableSlots.where((slot) => slot.available).toList();
  }
}
