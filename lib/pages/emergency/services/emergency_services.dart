import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import '../models/emergency_models.dart';

/// Services for emergency functionality
class EmergencyServices {
  /// Get current location
  static Future<LatLng?> getCurrentLocation() async {
    try {
      await _ensureLocationPermission();
      
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: EmergencyConstants.defaultLocationAccuracy,
        timeLimit: EmergencyConstants.locationTimeout,
      );
      
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  /// Ensure location permissions
  static Future<void> _ensureLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    } else if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions permanently denied');
    }
  }

  /// Load emergency facilities
  static Future<List<EmergencyFacility>> loadEmergencyFacilities({
    LatLng? currentLocation,
    String facilityType = EmergencyConstants.hospitalType,
  }) async {
    try {
      final facilities = await _fetchFacilitiesFromAPI();
      
      // Filter by facility type
      final filteredFacilities = facilities
          .where((f) => f.type.toLowerCase() == facilityType.toLowerCase())
          .toList();
      
      // Calculate distances if current location is available
      if (currentLocation != null) {
        for (final facility in filteredFacilities) {
          if (facility.hasValidLocation) {
            final distance = calculateDistance(
              currentLocation.latitude,
              currentLocation.longitude,
              facility.location.latitude,
              facility.location.longitude,
            );
            // Update facility with distance
            facility.copyWithDistance(distance);
          }
        }
        
        // Sort by distance
        filteredFacilities.sort((a, b) {
          final aDist = a.distanceKm ?? double.infinity;
          final bDist = b.distanceKm ?? double.infinity;
          return aDist.compareTo(bDist);
        });
      }
      
      return filteredFacilities;
    } catch (e) {
      debugPrint('Error loading emergency facilities: $e');
      rethrow;
    }
  }

  /// Fetch facilities from API
  static Future<List<EmergencyFacility>> _fetchFacilitiesFromAPI() async {
    for (final baseUrl in EmergencyConstants.apiBases) {
      try {
        final uri = Uri.parse('$baseUrl${EmergencyConstants.facilitiesEndpoint}');
        final response = await http.get(uri).timeout(
          const Duration(seconds: 60),
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as List<dynamic>;
          return data
              .map((item) => EmergencyFacility.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList();
        }
      } catch (e) {
        debugPrint('Error fetching from $baseUrl: $e');
        continue;
      }
    }
    
    throw Exception('Failed to fetch facilities from all endpoints');
  }

  /// Calculate distance between two coordinates
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = EmergencyConstants.earthRadiusKm;
    
    final double dLat = _deg2rad(lat2 - lat1);
    final double dLon = _deg2rad(lon2 - lon1);
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// Convert degrees to radians
  static double _deg2rad(double deg) {
    return deg * (pi / 180.0);
  }

  /// Launch phone call
  static Future<bool> makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) return false;
    
    try {
      final url = 'tel:$phoneNumber';
      return await launchUrlString(url);
    } catch (e) {
      debugPrint('Error making phone call: $e');
      return false;
    }
  }

  /// Launch Google Maps directions
  static Future<bool> launchDirections(LatLng destination) async {
    try {
      final url = 'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}';
      return await launchUrlString(url);
    } catch (e) {
      debugPrint('Error launching directions: $e');
      return false;
    }
  }

  /// Search facilities by query
  static List<EmergencyFacility> searchFacilities(
    List<EmergencyFacility> facilities,
    String query,
  ) {
    if (query.trim().isEmpty) return facilities;
    
    final lowerQuery = query.toLowerCase();
    
    return facilities.where((facility) {
      final nameMatch = facility.name.toLowerCase().contains(lowerQuery);
      final addressMatch = facility.address.toLowerCase().contains(lowerQuery);
      return nameMatch || addressMatch;
    }).toList();
  }

  /// Activate SOS alert
  static Future<SOSActionResult> activateSOS({
    required LatLng location,
    String? message,
    List<String>? contactIds,
  }) async {
    try {
      // This would typically send SOS to emergency services and contacts
      // For now, return success as mock
      
      final sosMessage = message ?? 'SOS activated at location: ${location.latitude}, ${location.longitude}';
      
      // Mock API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      return SOSActionResult.success(sosMessage);
    } catch (e) {
      debugPrint('Error activating SOS: $e');
      return SOSActionResult.failure('Failed to activate SOS: $e');
    }
  }

  /// Get location permission status
  static Future<LocationPermissionStatus> getLocationPermissionStatus() async {
    try {
      final permission = await Geolocator.checkPermission();
      
      switch (permission) {
        case LocationPermission.always:
        case LocationPermission.whileInUse:
          return LocationPermissionStatus.granted;
        case LocationPermission.denied:
          return LocationPermissionStatus.denied;
        case LocationPermission.deniedForever:
          return LocationPermissionStatus.permanentlyDenied;
        case LocationPermission.unableToDetermine:
          return LocationPermissionStatus.unableToDetermine;
      }
    } catch (e) {
      debugPrint('Error checking location permission: $e');
      return LocationPermissionStatus.unableToDetermine;
    }
  }

  /// Request location permission
  static Future<LocationPermissionStatus> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      
      switch (permission) {
        case LocationPermission.always:
        case LocationPermission.whileInUse:
          return LocationPermissionStatus.granted;
        case LocationPermission.denied:
          return LocationPermissionStatus.denied;
        case LocationPermission.deniedForever:
          return LocationPermissionStatus.permanentlyDenied;
        case LocationPermission.unableToDetermine:
          return LocationPermissionStatus.unableToDetermine;
      }
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return LocationPermissionStatus.unableToDetermine;
    }
  }

  /// Get emergency contacts (mock implementation)
  static Future<List<EmergencyContact>> getEmergencyContacts() async {
    try {
      // This would typically fetch from local storage or API
      // For now, return mock contacts
      await Future.delayed(const Duration(milliseconds: 300));
      
      return [
        EmergencyContact(
          id: '1',
          name: 'Emergency Services',
          phone: '911',
          relationship: 'Emergency',
          isPrimary: true,
        ),
        EmergencyContact(
          id: '2',
          name: 'Local Hospital',
          phone: '555-0123',
          relationship: 'Healthcare',
          isPrimary: false,
        ),
      ];
    } catch (e) {
      debugPrint('Error loading emergency contacts: $e');
      return [];
    }
  }

  /// Share location with emergency contacts
  static Future<bool> shareLocationWithContacts({
    required LatLng location,
    required List<EmergencyContact> contacts,
    String? message,
  }) async {
    try {
      // This would typically share location via SMS, email, or app notification
      // For now, return success as mock
      await Future.delayed(const Duration(milliseconds: 1000));
      
      for (final contact in contacts) {
        if (contact.hasValidPhone) {
          // Mock sending location via SMS
          debugPrint('Sharing location with ${contact.name}: ${contact.phone}');
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Error sharing location: $e');
      return false;
    }
  }

  /// Get nearby facilities within radius
  static List<EmergencyFacility> getFacilitiesWithinRadius(
    List<EmergencyFacility> facilities,
    LatLng center,
    double radiusKm,
  ) {
    return facilities.where((facility) {
      if (!facility.hasValidLocation) return false;
      
      final distance = calculateDistance(
        center.latitude,
        center.longitude,
        facility.location.latitude,
        facility.location.longitude,
      );
      
      return distance <= radiusKm;
    }).toList();
  }

  /// Sort facilities by distance
  static List<EmergencyFacility> sortFacilitiesByDistance(
    List<EmergencyFacility> facilities,
    LatLng center,
  ) {
    final withDistance = facilities.map((facility) {
      if (!facility.hasValidLocation) {
        return MapEntry(facility, double.infinity);
      }
      
      final distance = calculateDistance(
        center.latitude,
        center.longitude,
        facility.location.latitude,
        facility.location.longitude,
      );
      
      return MapEntry(facility, distance);
    }).toList();
    
    withDistance.sort((a, b) => a.value.compareTo(b.value));
    
    return withDistance.map((entry) => entry.key.copyWithDistance(entry.value)).toList();
  }

  /// Validate facility data
  static bool isValidFacility(Map<String, dynamic> facilityData) {
    final name = facilityData['name'] as String?;
    final type = facilityData['type'] as String?;
    final location = facilityData['location'] as Map?;
    
    return name != null && name.isNotEmpty &&
           type != null && type.isNotEmpty &&
           location != null &&
           location['coordinates'] is List &&
           (location['coordinates'] as List).length >= 2;
  }

  /// Get facility statistics
  static Map<String, dynamic> getFacilityStatistics(List<EmergencyFacility> facilities) {
    final withPhone = facilities.where((f) => f.hasPhone).length;
    final withLocation = facilities.where((f) => f.hasValidLocation).length;
    final withDistance = facilities.where((f) => f.distanceKm != null).length;
    
    final avgDistance = withDistance > 0
        ? facilities
            .where((f) => f.distanceKm != null)
            .map((f) => f.distanceKm!)
            .reduce((a, b) => a + b) / withDistance
        : 0.0;
    
    return {
      'total': facilities.length,
      'withPhone': withPhone,
      'withLocation': withLocation,
      'withDistance': withDistance,
      'averageDistance': avgDistance,
      'nearestDistance': facilities.isNotEmpty && facilities.first.distanceKm != null
          ? facilities.first.distanceKm
          : null,
    };
  }
}
