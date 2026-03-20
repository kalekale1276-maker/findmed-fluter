/// Models and constants for saved facilities functionality
class SavedFacilitiesConstants {
  // UI labels
  static const String pageTitle = 'Saved Facilities';
  static const String noSavedFacilitiesMessage = 'No saved facilities';
  static const String unnamedFacilityMessage = 'Unnamed';
  static const String unnamedAddressMessage = '';
  
  // Button tooltips
  static const String callTooltip = 'Call';
  static const String deleteTooltip = 'Delete';
  static const String openInMapsTooltip = 'Open in Maps';
  
  // Facility types
  static const String hospitalType = 'hospital';
  static const String pharmacyType = 'pharmacy';
  static const String clinicType = 'clinic';
  static const String laboratoryType = 'laboratory';
  static const String otherType = 'other';
  
  // Animation durations
  static const int animationDurationMs = 300;
  static const int deleteAnimationMs = 200;
  
  // Map settings
  static const String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=';
  static const String telUrlPrefix = 'tel:';
  
  // API endpoints
  static const String savedFacilitiesEndpoint = '/users/{userId}/saved';
  static const String deleteFacilityEndpoint = '/users/{userId}/saved/{facilityId}';
  
  // Validation
  static const int maxItemsPerPage = 50;
  static const double defaultLatitude = 9.0245;
  static const double defaultLongitude = 38.7485;
}

/// Saved facility model
class SavedFacility {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String type;
  final List<double> coordinates;
  final String? email;
  final String? website;
  final String? description;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  SavedFacility({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.type,
    required this.coordinates,
    this.email,
    this.website,
    this.description,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory SavedFacility.fromJson(Map<String, dynamic> json) {
    return SavedFacility(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? SavedFacilityConstants.unnamedFacilityMessage,
      address: json['address']?.toString() ?? SavedFacilityConstants.unnamedAddressMessage,
      phone: json['phone']?.toString() ?? '',
      type: json['type']?.toString() ?? SavedFacilityConstants.otherType,
      coordinates: _parseCoordinates(json['location']),
      email: json['email']?.toString(),
      website: json['website']?.toString(),
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Parse coordinates from location data
  static List<double> _parseCoordinates(dynamic location) {
    if (location is Map && location['coordinates'] is List) {
      final coords = location['coordinates'] as List;
      if (coords.length >= 2) {
        return [
          coords[0].toDouble(),
          coords[1].toDouble(),
        ];
      }
    }
    return [SavedFacilitiesConstants.defaultLongitude, SavedFacilitiesConstants.defaultLatitude];
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

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'type': type,
      'location': {
        'coordinates': coordinates,
        'type': 'Point',
      },
      'email': email,
      'website': website,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create copy with updated fields
  SavedFacility copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? type,
    List<double>? coordinates,
    String? email,
    String? website,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return SavedFacility(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      coordinates: coordinates ?? this.coordinates,
      email: email ?? this.email,
      website: website ?? this.website,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get display name
  String get displayName => name.isNotEmpty ? name : SavedFacilitiesConstants.unnamedFacilityMessage;

  /// Get display address
  String get displayAddress => address.isNotEmpty ? address : phone;

  /// Get formatted phone number
  String get formattedPhone {
    if (phone.isEmpty) return '';
    
    // Basic phone formatting
    String formatted = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Add country code if missing (Ethiopia example)
    if (!formatted.startsWith('+') && formatted.length == 9 && formatted.startsWith('9')) {
      formatted = '+251$formatted';
    }
    
    return formatted;
  }

  /// Get facility icon
  IconData get facilityIcon {
    switch (type.toLowerCase()) {
      case SavedFacilitiesConstants.hospitalType:
        return Icons.local_hospital;
      case SavedFacilitiesConstants.pharmacyType:
        return Icons.local_pharmacy;
      case SavedFacilitiesConstants.clinicType:
        return Icons.local_hospital;
      case SavedFacilitiesConstants.laboratoryType:
        return Icons.science;
      default:
        return Icons.location_on;
    }
  }

  /// Get facility color
  String get facilityColor {
    switch (type.toLowerCase()) {
      case SavedFacilitiesConstants.hospitalType:
        return 'red';
      case SavedFacilitiesConstants.pharmacyType:
        return 'blue';
      case SavedFacilitiesConstants.clinicType:
        return 'green';
      case SavedFacilitiesConstants.laboratoryType:
        return 'purple';
      default:
        return 'grey';
    }
  }

  /// Check if has phone number
  bool get hasPhone => phone.isNotEmpty;

  /// Check if has email
  bool get hasEmail => email?.isNotEmpty == true;

  /// Check if has website
  bool get hasWebsite => website?.isNotEmpty == true;

  /// Check if has coordinates
  bool get hasCoordinates => coordinates.length >= 2;

  /// Get latitude
  double get latitude => coordinates.length >= 2 ? coordinates[1] : SavedFacilitiesConstants.defaultLatitude;

  /// Get longitude
  double get longitude => coordinates.length >= 2 ? coordinates[0] : SavedFacilitiesConstants.defaultLongitude;

  /// Get Google Maps URL
  String get googleMapsUrl {
    if (!hasCoordinates) return '';
    return '${SavedFacilitiesConstants.googleMapsUrl}$latitude,$longitude';
  }

  /// Get phone URL
  String get phoneUrl {
    if (!hasPhone) return '';
    return '${SavedFacilitiesConstants.telUrlPrefix}${formattedPhone}';
  }

  /// Check if has contact information
  bool get hasContactInfo => hasPhone || hasEmail || hasWebsite;

  /// Get contact methods count
  int get contactMethodsCount {
    int count = 0;
    if (hasPhone) count++;
    if (hasEmail) count++;
    if (hasWebsite) count++;
    return count;
  }

  /// Get facility type display name
  String get typeDisplayName {
    switch (type.toLowerCase()) {
      case SavedFacilitiesConstants.hospitalType:
        return 'Hospital';
      case SavedFacilitiesConstants.pharmacyType:
        return 'Pharmacy';
      case SavedFacilitiesConstants.clinicType:
        return 'Clinic';
      case SavedFacilitiesConstants.laboratoryType:
        return 'Laboratory';
      default:
        return 'Other';
    }
  }

  /// Get formatted created date
  String get formattedCreatedAt {
    if (createdAt == null) return '';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }

  /// Validate facility data
  bool get isValid {
    return id.isNotEmpty && name.isNotEmpty;
  }

  /// Get distance from a point
  double distanceFrom(double lat, double lng) {
    if (!hasCoordinates) return double.infinity;
    
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double lat1 = latitude * (3.141592653589793 / 180);
    final double lat2 = lat * (3.141592653589793 / 180);
    final double deltaLat = (lat2 - lat1);
    final double deltaLng = (lng - longitude) * (3.141592653589793 / 180);
    
    final double a = (deltaLat / 2).sin() * (deltaLat / 2).sin() +
        lat1.cos() * lat2.cos() * (deltaLng / 2).sin() * (deltaLng / 2).sin();
    final double c = 2 * a.sqrt().asin();
    
    return earthRadius * c;
  }

  /// Get distance in kilometers
  double getDistanceInKm(double lat, double lng) {
    return distanceFrom(lat, lng);
  }

  /// Get distance in miles
  double getDistanceInMiles(double lat, double lng) {
    return distanceFrom(lat, lng) * 0.621371;
  }

  /// Get distance formatted string
  String getFormattedDistance(double lat, double lng, {bool useMiles = false}) {
    final distance = useMiles ? getDistanceInMiles(lat, lng) : getDistanceInKm(lat, lng);
    
    if (distance < 1) {
      return '${(distance * (useMiles ? 5280 : 1000)).toStringAsFixed(0)} ${useMiles ? 'ft' : 'm'}';
    } else if (distance < 10) {
      return '${distance.toStringAsFixed(1)} ${useMiles ? 'mi' : 'km'}';
    } else {
      return '${distance.toStringAsFixed(0)} ${useMiles ? 'mi' : 'km'}';
    }
  }
}

/// Saved facilities state model
class SavedFacilitiesState {
  final List<SavedFacility> facilities;
  final bool isLoading;
  final bool isDeleting;
  final String? error;
  final String? searchQuery;
  final String? selectedType;

  const SavedFacilitiesState({
    this.facilities = const [],
    this.isLoading = false,
    this.isDeleting = false,
    this.error,
    this.searchQuery,
    this.selectedType,
  });

  SavedFacilitiesState copyWith({
    List<SavedFacility>? facilities,
    bool? isLoading,
    bool? isDeleting,
    String? error,
    String? searchQuery,
    String? selectedType,
  }) {
    return SavedFacilitiesState(
      facilities: facilities ?? this.facilities,
      isLoading: isLoading ?? this.isLoading,
      isDeleting: isDeleting ?? this.isDeleting,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: selectedType ?? this.selectedType,
    );
  }

  /// Clear error
  SavedFacilitiesState clearError() => copyWith(error: null);

  /// Set loading
  SavedFacilitiesState setLoading(bool loading) => copyWith(isLoading: loading, error: null);

  /// Set deleting
  SavedFacilitiesState setDeleting(bool deleting) => copyWith(isDeleting: deleting, error: null);

  /// Set error
  SavedFacilitiesState setError(String error) => copyWith(isLoading: false, isDeleting: false, error: error);

  /// Update facilities
  SavedFacilitiesState updateFacilities(List<SavedFacility> newFacilities) {
    return copyWith(facilities: newFacilities);
  }

  /// Add facility
  SavedFacilitiesState addFacility(SavedFacility facility) {
    return copyWith(facilities: [facility, ...facilities]);
  }

  /// Remove facility
  SavedFacilitiesState removeFacility(String facilityId) {
    final updatedFacilities = facilities.where((f) => f.id != facilityId).toList();
    return copyWith(facilities: updatedFacilities);
  }

  /// Update search query
  SavedFacilitiesState updateSearchQuery(String query) {
    return copyWith(searchQuery: query.isEmpty ? null : query);
  }

  /// Update selected type
  SavedFacilitiesState updateSelectedType(String? type) {
    return copyWith(selectedType: type);
  }

  /// Check if has error
  bool get hasError => error != null;

  /// Check if is loading
  bool get isAnyLoading => isLoading || isDeleting;

  /// Check if has facilities
  bool get hasFacilities => facilities.isNotEmpty;

  /// Check if is searching
  bool get isSearching => searchQuery?.isNotEmpty == true;

  /// Check if has type filter
  bool get hasTypeFilter => selectedType != null;

  /// Get filtered facilities
  List<SavedFacility> get filteredFacilities {
    var filtered = facilities;
    
    // Apply search filter
    if (isSearching) {
      final query = searchQuery!.toLowerCase();
      filtered = filtered.where((facility) {
        return facility.name.toLowerCase().contains(query) ||
               facility.address.toLowerCase().contains(query) ||
               facility.type.toLowerCase().contains(query);
      }).toList();
    }
    
    // Apply type filter
    if (hasTypeFilter) {
      filtered = filtered.where((facility) => facility.type == selectedType).toList();
    }
    
    return filtered;
  }

  /// Get facilities by type
  List<SavedFacility> getFacilitiesByType(String type) {
    return facilities.where((f) => f.type == type).toList();
  }

  /// Get facilities count by type
  Map<String, int> getFacilityCountByType() {
    final counts = <String, int>{};
    for (final facility in facilities) {
      counts[facility.type] = (counts[facility.type] ?? 0) + 1;
    }
    return counts;
  }

  /// Get unique facility types
  List<String> get uniqueTypes {
    final types = facilities.map((f) => f.type).toSet().toList();
    types.sort();
    return types;
  }

  /// Get facilities with phone
  List<SavedFacility> get facilitiesWithPhone {
    return facilities.where((f) => f.hasPhone).toList();
  }

  /// Get facilities with coordinates
  List<SavedFacility> get facilitiesWithCoordinates {
    return facilities.where((f) => f.hasCoordinates).toList();
  }

  /// Get facilities sorted by distance from a point
  List<SavedFacility> getSortedByDistance(double lat, double lng) {
    final withCoords = facilitiesWithCoordinates;
    withCoords.sort((a, b) {
      final distanceA = a.getDistanceInKm(lat, lng);
      final distanceB = b.getDistanceInKm(lat, lng);
      return distanceA.compareTo(distanceB);
    });
    return withCoords;
  }

  /// Get nearest facilities
  List<SavedFacility> getNearestFacilities(double lat, double lng, {int maxCount = 5}) {
    final sorted = getSortedByDistance(lat, lng);
    return sorted.take(maxCount).toList();
  }

  /// Get facilities within radius
  List<SavedFacility> getFacilitiesWithinRadius(double lat, double lng, double radiusKm) {
    return facilitiesWithCoordinates.where((facility) {
      return facility.getDistanceInKm(lat, lng) <= radiusKm;
    }).toList();
  }
}

/// Facility filter model
class FacilityFilter {
  final String? type;
  final String? searchQuery;
  final double? maxDistance;
  final bool hasPhoneOnly;
  final bool hasCoordinatesOnly;

  const FacilityFilter({
    this.type,
    this.searchQuery,
    this.maxDistance,
    this.hasPhoneOnly = false,
    this.hasCoordinatesOnly = false,
  });

  /// Create copy with updated fields
  FacilityFilter copyWith({
    String? type,
    String? searchQuery,
    double? maxDistance,
    bool? hasPhoneOnly,
    bool? hasCoordinatesOnly,
  }) {
    return FacilityFilter(
      type: type ?? this.type,
      searchQuery: searchQuery ?? this.searchQuery,
      maxDistance: maxDistance ?? this.maxDistance,
      hasPhoneOnly: hasPhoneOnly ?? this.hasPhoneOnly,
      hasCoordinatesOnly: hasCoordinatesOnly ?? this.hasCoordinatesOnly,
    );
  }

  /// Clear all filters
  FacilityFilter clear() {
    return const FacilityFilter();
  }

  /// Check if has any active filters
  bool get hasFilters =>
      type != null ||
      searchQuery?.isNotEmpty == true ||
      maxDistance != null ||
      hasPhoneOnly ||
      hasCoordinatesOnly;

  /// Apply filter to facilities
  List<SavedFacility> apply(List<SavedFacility> facilities) {
    return facilities.where((facility) {
      // Type filter
      if (type != null && facility.type != type) return false;

      // Search filter
      if (searchQuery != null && searchQuery!.isNotEmpty) {
        final query = searchQuery!.toLowerCase();
        if (!facility.name.toLowerCase().contains(query) &&
            !facility.address.toLowerCase().contains(query) &&
            !facility.type.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Phone filter
      if (hasPhoneOnly && !facility.hasPhone) return false;

      // Coordinates filter
      if (hasCoordinatesOnly && !facility.hasCoordinates) return false;

      return true;
    }).toList();
  }
}

/// Saved facility action result
class SavedFacilityResult {
  final bool success;
  final String? message;
  final SavedFacility? facility;

  SavedFacilityResult({
    required this.success,
    this.message,
    this.facility,
  });

  factory SavedFacilityResult.success({
    String? message,
    SavedFacility? facility,
  }) {
    return SavedFacilityResult(
      success: true,
      message: message ?? 'Operation successful',
      facility: facility,
    );
  }

  factory SavedFacilityResult.failure(String message) {
    return SavedFacilityResult(
      success: false,
      message: message,
    );
  }
}

/// Facility statistics model
class FacilityStatistics {
  final int totalFacilities;
  final Map<String, int> typeCounts;
  final int facilitiesWithPhone;
  final int facilitiesWithCoordinates;
  final int facilitiesWithEmail;
  final int facilitiesWithWebsite;
  final double averageDistance;
  final DateTime lastUpdated;

  FacilityStatistics({
    required this.totalFacilities,
    required this.typeCounts,
    required this.facilitiesWithPhone,
    required this.facilitiesWithCoordinates,
    required this.facilitiesWithEmail,
    required this.facilitiesWithWebsite,
    required this.averageDistance,
    required this.lastUpdated,
  });

  /// Calculate statistics from facilities
  factory FacilityStatistics.fromFacilities(List<SavedFacility> facilities) {
    final typeCounts = <String, int>{};
    int withPhone = 0;
    int withCoordinates = 0;
    int withEmail = 0;
    int withWebsite = 0;
    double totalDistance = 0;
    int distanceCount = 0;

    for (final facility in facilities) {
      // Count by type
      typeCounts[facility.type] = (typeCounts[facility.type] ?? 0) + 1;

      // Count contact methods
      if (facility.hasPhone) withPhone++;
      if (facility.hasCoordinates) withCoordinates++;
      if (facility.hasEmail) withEmail++;
      if (facility.hasWebsite) withWebsite++;

      // Calculate distances (using a reference point)
      if (facility.hasCoordinates) {
        totalDistance += facility.getDistanceInKm(9.0245, 38.7485); // Addis Ababa
        distanceCount++;
      }
    }

    return FacilityStatistics(
      totalFacilities: facilities.length,
      typeCounts: typeCounts,
      facilitiesWithPhone: withPhone,
      facilitiesWithCoordinates: withCoordinates,
      facilitiesWithEmail: withEmail,
      facilitiesWithWebsite: withWebsite,
      averageDistance: distanceCount > 0 ? totalDistance / distanceCount : 0.0,
      lastUpdated: DateTime.now(),
    );
  }

  /// Get most common type
  String? get mostCommonType {
    if (typeCounts.isEmpty) return null;
    
    return typeCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Get phone coverage percentage
  double get phoneCoverage {
    if (totalFacilities == 0) return 0.0;
    return facilitiesWithPhone / totalFacilities;
  }

  /// Get coordinates coverage percentage
  double get coordinatesCoverage {
    if (totalFacilities == 0) return 0.0;
    return facilitiesWithCoordinates / totalFacilities;
  }

  /// Check if has data
  bool get hasData => totalFacilities > 0;
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
