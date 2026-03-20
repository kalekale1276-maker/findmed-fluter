import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

/// Models and constants for emergency functionality
class EmergencyConstants {
  // UI labels
  static const String pageTitle = 'Emergency';
  static const String sosButtonLabel = 'SOS / Panic';
  static const String sosDialogTitle = 'SOS';
  static const String sosDialogMessage = 'SOS activated — share your location with emergency contacts.';
  static const String nearestHospitalsTitle = 'Nearest Emergency Hospitals';
  static const String noHospitalsMessage = 'No hospitals found';
  static const String searchHint = 'Search hospitals by name or address';
  static const String clearSearchLabel = 'Clear';
  static const String searchTooltip = 'Search';
  static const String refreshTooltip = 'Refresh';
  
  // API endpoints
  static const List<String> apiBases = [
    'https://findmed-backend-1.onrender.com',
  ];
  static const String facilitiesEndpoint = '/api/facilities';
  
  // Facility types
  static const String hospitalType = 'hospital';
  
  // SOS settings
  static const int sosDialogDuration = 0; // No auto-dismiss
  static const Color sosButtonColor = Colors.red;
  
  // Distance settings
  static const double earthRadiusKm = 6371.0;
  static const String distanceFormat = '{distance} km';
  
  // Search settings
  static const int minSearchLength = 1;
  
  // Location settings
  static const LocationAccuracy defaultLocationAccuracy = LocationAccuracy.high;
  static const Duration locationTimeout = Duration(seconds: 60);
}

/// Emergency facility model
class EmergencyFacility {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String type;
  final LatLng location;
  final double? distanceKm;
  final Map<String, dynamic> rawData;

  EmergencyFacility({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.type,
    required this.location,
    this.distanceKm,
    this.rawData = const {},
  });

  factory EmergencyFacility.fromJson(Map<String, dynamic> json) {
    // Extract location coordinates
    LatLng? facilityLocation;
    final loc = json['location'];
    if (loc is Map && loc['coordinates'] is List && (loc['coordinates'] as List).length >= 2) {
      final coords = List.from(loc['coordinates']);
      final lng = (coords[0] as num).toDouble();
      final lat = (coords[1] as num).toDouble();
      facilityLocation = LatLng(lat, lng);
    }

    return EmergencyFacility(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Facility',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      location: facilityLocation ?? LatLng(0.0, 0.0),
      rawData: json,
    );
  }

  /// Check if facility has valid location
  bool get hasValidLocation => location.latitude != 0.0 || location.longitude != 0.0;

  /// Check if facility has phone number
  bool get hasPhone => phone.isNotEmpty;

  /// Get formatted distance
  String get formattedDistance {
    if (distanceKm == null) return '-';
    return '${distanceKm!.toStringAsFixed(2)} km';
  }

  /// Get display subtitle
  String get displaySubtitle {
    final distancePart = formattedDistance;
    final addressPart = address.isNotEmpty ? address : 'No address';
    return '$distancePart km — $addressPart';
  }

  /// Check if facility matches search query
  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    
    final lowerQuery = query.toLowerCase();
    final nameMatch = name.toLowerCase().contains(lowerQuery);
    final addressMatch = address.toLowerCase().contains(lowerQuery);
    
    return nameMatch || addressMatch;
  }

  /// Create copy with distance
  EmergencyFacility copyWithDistance(double distance) {
    return EmergencyFacility(
      id: id,
      name: name,
      address: address,
      phone: phone,
      type: type,
      location: location,
      distanceKm: distance,
      rawData: rawData,
    );
  }

  /// Generate Google Maps directions URL
  String get directionsUrl {
    if (!hasValidLocation) return '';
    return 'https://www.google.com/maps/dir/?api=1&destination=${location.latitude},${location.longitude}';
  }

  /// Generate phone call URL
  String get phoneUrl {
    if (!hasPhone) return '';
    return 'tel:$phone';
  }
}

/// Emergency state model
class EmergencyState {
  final bool sosActivated;
  final LatLng? currentLocation;
  final List<EmergencyFacility> facilities;
  final List<EmergencyFacility> filteredFacilities;
  final bool isSearching;
  final bool isLoading;
  final String searchQuery;
  final String? error;

  const EmergencyState({
    this.sosActivated = false,
    this.currentLocation,
    this.facilities = const [],
    this.filteredFacilities = const [],
    this.isSearching = false,
    this.isLoading = true,
    this.searchQuery = '',
    this.error,
  });

  EmergencyState copyWith({
    bool? sosActivated,
    LatLng? currentLocation,
    List<EmergencyFacility>? facilities,
    List<EmergencyFacility>? filteredFacilities,
    bool? isSearching,
    bool? isLoading,
    String? searchQuery,
    String? error,
  }) {
    return EmergencyState(
      sosActivated: sosActivated ?? this.sosActivated,
      currentLocation: currentLocation ?? this.currentLocation,
      facilities: facilities ?? this.facilities,
      filteredFacilities: filteredFacilities ?? this.filteredFacilities,
      isSearching: isSearching ?? this.isSearching,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error ?? this.error,
    );
  }

  /// Check if there are any facilities
  bool get hasFacilities => facilities.isNotEmpty;

  /// Check if there are any filtered facilities
  bool get hasFilteredFacilities => filteredFacilities.isNotEmpty;

  /// Get nearest facility
  EmergencyFacility? get nearestFacility {
    if (filteredFacilities.isEmpty) return null;
    return filteredFacilities.first;
  }

  /// Clear error
  EmergencyState clearError() => copyWith(error: null);

  /// Set loading
  EmergencyState setLoading(bool loading) => copyWith(isLoading: loading, error: null);

  /// Set error
  EmergencyState setError(String error) => copyWith(isLoading: false, error: error);

  /// Activate SOS
  EmergencyState activateSOS() => copyWith(sosActivated: true);

  /// Deactivate SOS
  EmergencyState deactivateSOS() => copyWith(sosActivated: false);

  /// Toggle search mode
  EmergencyState toggleSearch() => copyWith(isSearching: !isSearching);

  /// Update search query and apply filter
  EmergencyState updateSearchQuery(String query) {
    final filtered = query.isEmpty 
        ? facilities 
        : facilities.where((f) => f.matchesQuery(query)).toList();
    
    return copyWith(searchQuery: query, filteredFacilities: filtered);
  }

  /// Clear search
  EmergencyState clearSearch() => copyWith(
    searchQuery: '',
    isSearching: false,
    filteredFacilities: facilities,
  );
}

/// SOS action result
class SOSActionResult {
  final bool success;
  final String? message;
  final DateTime? timestamp;

  SOSActionResult({
    required this.success,
    this.message,
    this.timestamp,
  });

  factory SOSActionResult.success(String message) {
    return SOSActionResult(
      success: true,
      message: message,
      timestamp: DateTime.now(),
    );
  }

  factory SOSActionResult.failure(String message) {
    return SOSActionResult(
      success: false,
      message: message,
      timestamp: DateTime.now(),
    );
  }
}

/// Location permission status
enum LocationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  unableToDetermine,
}

/// Emergency contact model
class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relationship;
  final bool isPrimary;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
    this.isPrimary = false,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      relationship: json['relationship']?.toString() ?? '',
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  /// Get phone URL
  String get phoneUrl => 'tel:$phone';

  /// Check if phone is valid
  bool get hasValidPhone => phone.isNotEmpty;
}

/// Emergency alert model
class EmergencyAlert {
  final String id;
  final String userId;
  final LatLng location;
  final String message;
  final DateTime timestamp;
  final List<String> contactIds;
  final bool isResolved;
  final DateTime? resolvedAt;

  EmergencyAlert({
    required this.id,
    required this.userId,
    required this.location,
    required this.message,
    required this.timestamp,
    required this.contactIds,
    this.isResolved = false,
    this.resolvedAt,
  });

  factory EmergencyAlert.fromJson(Map<String, dynamic> json) {
    return EmergencyAlert(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      location: LatLng(
        json['location']?['lat'] as double? ?? 0.0,
        json['location']?['lng'] as double? ?? 0.0,
      ),
      message: json['message']?.toString() ?? '',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      contactIds: (json['contactIds'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isResolved: json['isResolved'] as bool? ?? false,
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.tryParse(json['resolvedAt']) 
          : null,
    );
  }

  /// Get formatted timestamp
  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}



/// Location model using latlong2.LatLng
class EmergencyLocation {
  final double latitude;
  final double longitude;
  final LocationAccuracy accuracy;

  const EmergencyLocation(this.latitude, this.longitude, {this.accuracy = LocationAccuracy.high});

  /// Convert to latlong2.LatLng
  LatLng toLatLng() => LatLng(latitude, longitude);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other.runtimeType == other.runtimeType &&
          other.latitude == latitude &&
          other.longitude == longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() => 'LatLng($latitude, $longitude)';
}

/// Location model
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other.runtimeType == other.runtimeType &&
          other.latitude == latitude &&
          other.longitude == longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
  
  @override
  String toString() => 'LatLng($latitude, $longitude)';
}
