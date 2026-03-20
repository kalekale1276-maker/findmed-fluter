/// Models and constants for facility detail functionality
class FacilityDetailConstants {
  // UI labels
  static const String defaultTitle = 'Facility';
  static const String unnamedFacility = 'Unnamed';
  static const String nameLabel = 'Name';
  static const String addressLabel = 'Address';
  static const String ownershipLabel = 'Ownership';
  static const String phoneLabel = 'Phone';
  static const String emailLabel = 'Email';
  static const String servicesLabel = 'Services';
  static const String callButtonLabel = 'Call';
  static const String directionsButtonLabel = 'Directions';
  static const String bookButtonLabel = 'Book';
  static const String notAvailableText = 'N/A';
  
  // Map URLs
  static const String googleMapsSearchUrl = 'https://www.google.com/maps/search/?api=1&query=';
  static const String googleMapsDirectionsUrl = 'https://www.google.com/maps/dir/?api=1&destination=';
  
  // Phone URL scheme
  static const String phoneUrlScheme = 'tel:';
  
  // Service display settings
  static const String serviceSeparator = ', ';
  static const int maxServiceDisplay = 5;
  
  // Animation durations
  static const int animationDurationMs = 300;
  static const int pulseAnimationDurationMs = 1000;
}

/// Facility detail model
class FacilityDetail {
  final String id;
  final String name;
  final String address;
  final String ownership;
  final String phone;
  final String email;
  final List<String> services;
  final LatLng? location;
  final Map<String, dynamic> rawData;

  FacilityDetail({
    required this.id,
    required this.name,
    required this.address,
    required this.ownership,
    required this.phone,
    required this.email,
    required this.services,
    this.location,
    this.rawData = const {},
  });

  factory FacilityDetail.fromJson(Map<String, dynamic> json) {
    // Extract location coordinates
    LatLng? facilityLocation;
    final loc = json['location'];
    if (loc is Map && loc['coordinates'] is List && (loc['coordinates'] as List).length >= 2) {
      final coords = List.from(loc['coordinates']);
      final lng = (coords[0] as num).toDouble();
      final lat = (coords[1] as num).toDouble();
      facilityLocation = LatLng(lat, lng);
    }

    // Extract services
    List<String> servicesList = [];
    final servicesData = json['services'];
    if (servicesData is List) {
      servicesList = servicesData.map((service) {
        if (service is String) return service;
        if (service is Map) {
          return (service['name'] ?? service['label'] ?? service.toString()).toString();
        }
        return service.toString();
      }).toList();
    } else if (servicesData != null) {
      servicesList = [servicesData.toString()];
    }

    return FacilityDetail(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? FacilityDetailConstants.unnamedFacility,
      address: json['address']?.toString() ?? '',
      ownership: json['ownership']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      services: servicesList,
      location: facilityLocation,
      rawData: json,
    );
  }

  /// Check if facility has valid location
  bool get hasValidLocation => location != null;

  /// Check if facility has phone number
  bool get hasPhone => phone.isNotEmpty;

  /// Check if facility has email
  bool get hasEmail => email.isNotEmpty;

  /// Check if facility has services
  bool get hasServices => services.isNotEmpty;

  /// Get formatted ownership (capitalized)
  String get formattedOwnership {
    if (ownership.isEmpty) return '';
    return '${ownership[0].toUpperCase()}${ownership.substring(1)}';
  }

  /// Get formatted services display
  String get formattedServices {
    if (services.isEmpty) return FacilityDetailConstants.notAvailableText;
    
    final displayServices = services.take(FacilityDetailConstants.maxServiceDisplay).toList();
    final servicesText = displayServices.join(FacilityDetailConstants.serviceSeparator);
    
    if (services.length > FacilityDetailConstants.maxServiceDisplay) {
      return '$servicesText and ${services.length - FacilityDetailConstants.maxServiceDisplay} more';
    }
    
    return servicesText.isEmpty ? FacilityDetailConstants.notAvailableText : servicesText;
  }

  /// Get coordinates string for maps
  String get coordinatesString {
    if (!hasValidLocation) return '';
    return '${location!.latitude},${location!.longitude}';
  }

  /// Get Google Maps search URL
  String get googleMapsSearchUrl {
    if (!hasValidLocation) return '';
    return '${FacilityDetailConstants.googleMapsSearchUrl}${coordinatesString}';
  }

  /// Get Google Maps directions URL
  String get googleMapsDirectionsUrl {
    if (!hasValidLocation) return '';
    return '${FacilityDetailConstants.googleMapsDirectionsUrl}${coordinatesString}';
  }

  /// Get phone URL
  String get phoneUrl {
    if (!hasPhone) return '';
    return '${FacilityDetailConstants.phoneUrlScheme}$phone';
  }

  /// Get email URL
  String get emailUrl {
    if (!hasEmail) return '';
    return 'mailto:$email';
  }

  /// Check if facility is complete
  bool get isComplete {
    return name.isNotEmpty && 
           address.isNotEmpty && 
           hasPhone && 
           hasValidLocation;
  }

  /// Get completion percentage
  double get completionPercentage {
    int completedFields = 0;
    int totalFields = 6; // name, address, phone, email, services, location
    
    if (name.isNotEmpty) completedFields++;
    if (address.isNotEmpty) completedFields++;
    if (hasPhone) completedFields++;
    if (hasEmail) completedFields++;
    if (hasServices) completedFields++;
    if (hasValidLocation) completedFields++;
    
    return completedFields / totalFields;
  }
}

/// Facility action type
enum FacilityAction {
  call,
  directions,
  book,
  email,
  share,
}

/// Facility action result
class FacilityActionResult {
  final bool success;
  final String? message;
  final FacilityAction action;

  FacilityActionResult({
    required this.success,
    required this.action,
    this.message,
  });

  factory FacilityActionResult.success(FacilityAction action, {String? message}) {
    return FacilityActionResult(
      success: true,
      action: action,
      message: message,
    );
  }

  factory FacilityActionResult.failure(FacilityAction action, String message) {
    return FacilityActionResult(
      success: false,
      action: action,
      message: message,
    );
  }
}

/// Facility detail state
class FacilityDetailState {
  final FacilityDetail facility;
  final bool isLoading;
  final String? error;
  final bool businessMode;

  FacilityDetailState({
    required this.facility,
    this.isLoading = false,
    this.error,
    this.businessMode = false,
  });

  FacilityDetailState copyWith({
    FacilityDetail? facility,
    bool? isLoading,
    String? error,
    bool? businessMode,
  }) {
    return FacilityDetailState(
      facility: facility ?? this.facility,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      businessMode: businessMode ?? this.businessMode,
    );
  }

  /// Clear error
  FacilityDetailState clearError() => copyWith(error: null);

  /// Set loading
  FacilityDetailState setLoading(bool loading) => copyWith(isLoading: loading, error: null);

  /// Set error
  FacilityDetailState setError(String error) => copyWith(isLoading: false, error: error);

  /// Update business mode
  FacilityDetailState updateBusinessMode(bool mode) => copyWith(businessMode: mode);
}

/// Facility rating model
class FacilityRating {
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingDistribution; // 1-5 stars count

  FacilityRating({
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
  });

  factory FacilityRating.fromJson(Map<String, dynamic> json) {
    final distribution = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      distribution[i] = json['rating_$i'] as int? ?? 0;
    }

    return FacilityRating(
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: json['totalRatings'] as int? ?? 0,
      ratingDistribution: distribution,
    );
  }

  /// Get star rating display
  String get starDisplay {
    return '${averageRating.toStringAsFixed(1)} ⭐';
  }

  /// Get rating count display
  String get countDisplay {
    return '($totalRatings)';
  }

  /// Check if has ratings
  bool get hasRatings => totalRatings > 0;
}

/// Facility operating hours model
class FacilityOperatingHours {
  final Map<String, List<String>> weeklyHours;
  final bool isOpen24Hours;
  final String? timezone;

  FacilityOperatingHours({
    required this.weeklyHours,
    this.isOpen24Hours = false,
    this.timezone,
  });

  factory FacilityOperatingHours.fromJson(Map<String, dynamic> json) {
    final hours = <String, List<String>>{};
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    
    for (final day in days) {
      final dayHours = json[day];
      if (dayHours is List) {
        hours[day] = dayHours.map((h) => h.toString()).toList();
      } else if (dayHours is String) {
        hours[day] = [dayHours];
      }
    }

    return FacilityOperatingHours(
      weeklyHours: hours,
      isOpen24Hours: json['isOpen24Hours'] as bool? ?? false,
      timezone: json['timezone'] as String?,
    );
  }

  /// Get today's hours
  List<String> get todayHours {
    final now = DateTime.now();
    final dayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final today = dayNames[now.weekday - 1];
    return weeklyHours[today] ?? [];
  }

  /// Check if currently open
  bool get isOpenNow {
    if (isOpen24Hours) return true;
    
    // This would require more complex time logic
    // For now, return false as placeholder
    return false;
  }
}

/// Import LatLng class
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatLng &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() => 'LatLng($latitude, $longitude)';
}
