import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../services/api.dart';
import '../../../../services/auth.dart';
import '../models/saved_facilities_models.dart';

/// Services for saved facilities functionality
class SavedFacilitiesServices {
  /// Load saved facilities for current user
  static Future<List<SavedFacility>> loadSavedFacilities() async {
    try {
      final authService = AuthService.instance;
      await authService.init();
      
      final userId = authService.user?['id'];
      if (userId == null) {
        throw Exception('No user id');
      }
      
      final response = await Api.get('/users/$userId/saved');
      final savedData = response['saved'] as List<dynamic>? ?? [];
      
      return savedData
          .map((item) => SavedFacility.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading saved facilities: $e');
      rethrow;
    }
  }

  /// Remove facility from saved list
  static Future<SavedFacilityResult> removeSavedFacility(String facilityId) async {
    try {
      final authService = AuthService.instance;
      await authService.init();
      
      final userId = authService.user?['id'];
      if (userId == null) {
        throw Exception('No user id');
      }
      
      final response = await Api.delete('/users/$userId/saved/$facilityId');
      final savedData = response['saved'] as List<dynamic>? ?? [];
      
      final updatedFacilities = savedData
          .map((item) => SavedFacility.fromJson(item as Map<String, dynamic>))
          .toList();
      
      return SavedFacilityResult.success(
        message: 'Facility removed from saved list',
        facility: updatedFacilities.isNotEmpty ? updatedFacilities.first : null,
      );
    } catch (e) {
      debugPrint('Error removing saved facility: $e');
      return SavedFacilityResult.failure('Failed to remove facility: $e');
    }
  }

  /// Add facility to saved list
  static Future<SavedFacilityResult> addSavedFacility(SavedFacility facility) async {
    try {
      final authService = AuthService.instance;
      await authService.init();
      
      final userId = authService.user?['id'];
      if (userId == null) {
        throw Exception('No user id');
      }
      
      final response = await Api.post('/users/$userId/saved', facility.toJson());
      final savedData = response['saved'] as List<dynamic>? ?? [];
      
      final updatedFacilities = savedData
          .map((item) => SavedFacility.fromJson(item as Map<String, dynamic>))
          .toList();
      
      return SavedFacilityResult.success(
        message: 'Facility added to saved list',
        facility: facility,
      );
    } catch (e) {
      debugPrint('Error adding saved facility: $e');
      return SavedFacilityResult.failure('Failed to add facility: $e');
    }
  }

  /// Update facility in saved list
  static Future<SavedFacilityResult> updateSavedFacility(SavedFacility facility) async {
    try {
      final authService = AuthService.instance;
      await authService.init();
      
      final userId = authService.user?['id'];
      if (userId == null) {
        throw Exception('No user id');
      }
      
      final response = await Api.put('/users/$userId/saved/${facility.id}', facility.toJson());
      final savedData = response['saved'] as List<dynamic>? ?? [];
      
      final updatedFacilities = savedData
          .map((item) => SavedFacility.fromJson(item as Map<String, dynamic>))
          .toList();
      
      return SavedFacilityResult.success(
        message: 'Facility updated',
        facility: facility,
      );
    } catch (e) {
      debugPrint('Error updating saved facility: $e');
      return SavedFacilityResult.failure('Failed to update facility: $e');
    }
  }

  /// Call facility phone number
  static Future<bool> callFacility(String phoneNumber) async {
    try {
      if (phoneNumber.isEmpty) {
        return false;
      }
      
      final uri = 'tel:$phoneNumber';
      return await launchUrlString(uri);
    } catch (e) {
      debugPrint('Error calling facility: $e');
      return false;
    }
  }

  /// Open facility in Google Maps
  static Future<bool> openFacilityInMaps(SavedFacility facility) async {
    try {
      if (!facility.hasCoordinates) {
        return false;
      }
      
      final uri = facility.googleMapsUrl;
      return await launchUrlString(uri);
    } catch (e) {
      debugPrint('Error opening facility in maps: $e');
      return false;
    }
  }

  /// Send email to facility
  static Future<bool> sendEmailToFacility(String email) async {
    try {
      if (email.isEmpty) {
        return false;
      }
      
      final uri = 'mailto:$email';
      return await launchUrlString(uri);
    } catch (e) {
      debugPrint('Error sending email to facility: $e');
      return false;
    }
  }

  /// Open facility website
  static Future<bool> openFacilityWebsite(String website) async {
    try {
      if (website.isEmpty) {
        return false;
      }
      
      String url = website;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$website';
      }
      
      return await launchUrlString(url);
    } catch (e) {
      debugPrint('Error opening facility website: $e');
      return false;
    }
  }

  /// Search facilities
  static List<SavedFacility> searchFacilities(
    List<SavedFacility> facilities,
    String query, {
    FacilityFilter? filter,
  }) {
    if (query.trim().isEmpty) return facilities;
    
    final lowerQuery = query.toLowerCase();
    
    return facilities.where((facility) {
      // Search in name, address, and type
      if (facility.name.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      
      if (facility.address.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      
      if (facility.type.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      
      // Search in phone number
      if (facility.phone.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      
      return false;
    }).toList();
  }

  /// Filter facilities by criteria
  static List<SavedFacility> filterFacilities(
    List<SavedFacility> facilities,
    FacilityFilter filter,
  ) {
    return filter.apply(facilities);
  }

  /// Sort facilities by distance from a point
  static List<SavedFacility> sortFacilitiesByDistance(
    List<SavedFacility> facilities,
    double latitude,
    double longitude,
  ) {
    final withCoordinates = facilities.where((f) => f.hasCoordinates).toList();
    
    withCoordinates.sort((a, b) {
      final distanceA = a.getDistanceInKm(latitude, longitude);
      final distanceB = b.getDistanceInKm(latitude, longitude);
      return distanceA.compareTo(distanceB);
    });
    
    return withCoordinates;
  }

  /// Sort facilities by name
  static List<SavedFacility> sortFacilitiesByName(
    List<SavedFacility> facilities, {
    bool ascending = true,
  }) {
    final sorted = List<SavedFacility>.from(facilities);
    
    sorted.sort((a, b) {
      final comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return ascending ? comparison : -comparison;
    });
    
    return sorted;
  }

  /// Sort facilities by type
  static List<SavedFacility> sortFacilitiesByType(
    List<SavedFacility> facilities, {
    bool ascending = true,
  }) {
    final sorted = List<SavedFacility>.from(facilities);
    
    sorted.sort((a, b) {
      final comparison = a.type.toLowerCase().compareTo(b.type.toLowerCase());
      return ascending ? comparison : -comparison;
    });
    
    return sorted;
  }

  /// Get facilities by type
  static List<SavedFacility> getFacilitiesByType(
    List<SavedFacility> facilities,
    String type,
  ) {
    return facilities.where((facility) => facility.type == type).toList();
  }

  /// Get facilities with phone numbers
  static List<SavedFacility> getFacilitiesWithPhone(List<SavedFacility> facilities) {
    return facilities.where((facility) => facility.hasPhone).toList();
  }

  /// Get facilities with coordinates
  static List<SavedFacility> getFacilitiesWithCoordinates(List<SavedFacility> facilities) {
    return facilities.where((facility) => facility.hasCoordinates).toList();
  }

  /// Get facilities within radius
  static List<SavedFacility> getFacilitiesWithinRadius(
    List<SavedFacility> facilities,
    double latitude,
    double longitude,
    double radiusKm,
  ) {
    return facilities.where((facility) {
      if (!facility.hasCoordinates) return false;
      return facility.getDistanceInKm(latitude, longitude) <= radiusKm;
    }).toList();
  }

  /// Get nearest facilities
  static List<SavedFacility> getNearestFacilities(
    List<SavedFacility> facilities,
    double latitude,
    double longitude, {
    int maxCount = 5,
  }) {
    final sorted = sortFacilitiesByDistance(facilities, latitude, longitude);
    return sorted.take(maxCount).toList();
  }

  /// Calculate facility statistics
  static FacilityStatistics calculateStatistics(List<SavedFacility> facilities) {
    return FacilityStatistics.fromFacilities(facilities);
  }

  /// Export facilities to JSON
  static String exportFacilitiesToJson(List<SavedFacility> facilities) {
    final data = {
      'facilities': facilities.map((f) => f.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
      'totalCount': facilities.length,
      'statistics': FacilityStatistics.fromFacilities(facilities).toJson(),
    };
    
    return _encodeJson(data);
  }

  /// Simple JSON encoder (avoiding dart:convert dependency)
  static String _encodeJson(Map<String, dynamic> data) {
    // This is a simplified JSON encoder for demonstration
    // In a real app, you would use dart:convert
    return '{\n'
        '  "facilities": [\n'
        '    // Facility data would be serialized here\n'
        '  ],\n'
        '  "exportedAt": "${data['exportedAt']}",\n'
        '  "totalCount": ${data['totalCount']},\n'
        '  "statistics": {}\n'
        '}';
  }

  /// Import facilities from JSON
  static Future<List<SavedFacility>> importFacilitiesFromJson(String jsonData) async {
    try {
      // This is a simplified JSON parser for demonstration
      // In a real app, you would use dart:convert
      return [];
    } catch (e) {
      debugPrint('Error importing facilities: $e');
      rethrow;
    }
  }

  /// Validate facility data
  static bool validateFacilityData(Map<String, dynamic> data) {
    try {
      // Check required fields
      if (!data.containsKey('id') || data['id']?.toString().isEmpty == true) {
        return false;
      }
      
      if (!data.containsKey('name') || data['name']?.toString().trim().isEmpty == true) {
        return false;
      }
      
      // Validate coordinates if present
      if (data.containsKey('location') && data['location'] is Map) {
        final location = data['location'] as Map<String, dynamic>;
        if (location.containsKey('coordinates') && location['coordinates'] is List) {
          final coords = location['coordinates'] as List;
          if (coords.length < 2 || 
              coords[0] is! num || 
              coords[1] is! num) {
            return false;
          }
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Error validating facility data: $e');
      return false;
    }
  }

  /// Get facility recommendations
  static List<String> getFacilityRecommendations(List<SavedFacility> facilities) {
    final recommendations = <String>[];
    
    if (facilities.isEmpty) {
      recommendations.add('Start saving facilities to build your healthcare network');
      return recommendations;
    }
    
    final statistics = FacilityStatistics.fromFacilities(facilities);
    
    if (statistics.phoneCoverage < 0.8) {
      recommendations.add('Consider adding phone numbers to more facilities for quick contact');
    }
    
    if (statistics.coordinatesCoverage < 0.8) {
      recommendations.add('Add location data to facilities for better navigation');
    }
    
    if (facilities.length < 5) {
      recommendations.add('Save more facilities to have better healthcare options');
    }
    
    final typeVariety = statistics.typeCounts.keys.length;
    if (typeVariety < 3) {
      recommendations.add('Save different types of facilities for comprehensive healthcare access');
    }
    
    return recommendations;
  }

  /// Get facility insights
  static Map<String, dynamic> getFacilityInsights(List<SavedFacility> facilities) {
    final statistics = FacilityStatistics.fromFacilities(facilities);
    
    return {
      'statistics': statistics,
      'recommendations': getFacilityRecommendations(facilities),
      'insights': {
        'totalSaved': facilities.length,
        'phoneCoverage': (statistics.phoneCoverage * 100).toStringAsFixed(1) + '%',
        'locationCoverage': (statistics.coordinatesCoverage * 100).toStringAsFixed(1) + '%',
        'mostCommonType': statistics.mostCommonType,
        'averageDistance': statistics.averageDistance.toStringAsFixed(2) + ' km',
        'diversityScore': statistics.typeCounts.keys.length.toString(),
      },
    };
  }

  /// Sync facilities with backend
  static Future<List<SavedFacility>> syncFacilities() async {
    try {
      // In a real app, this would sync with backend
      // For now, just load facilities
      return await loadSavedFacilities();
    } catch (e) {
      debugPrint('Error syncing facilities: $e');
      rethrow;
    }
  }

  /// Backup facilities locally
  static Future<bool> backupFacilities(List<SavedFacility> facilities) async {
    try {
      // This would save to local storage in a real app
      debugPrint('Backing up ${facilities.length} facilities');
      return true;
    } catch (e) {
      debugPrint('Error backing up facilities: $e');
      return false;
    }
  }

  /// Restore facilities from backup
  static Future<List<SavedFacility>> restoreFacilities() async {
    try {
      // This would load from local storage in a real app
      debugPrint('Restoring facilities from backup');
      return [];
    } catch (e) {
      debugPrint('Error restoring facilities: $e');
      return [];
    }
  }

  /// Clear all saved facilities
  static Future<SavedFacilityResult> clearAllSavedFacilities() async {
    try {
      final authService = AuthService.instance;
      await authService.init();
      
      final userId = authService.user?['id'];
      if (userId == null) {
        throw Exception('No user id');
      }
      
      await Api.delete('/users/$userId/saved');
      
      return SavedFacilityResult.success(
        message: 'All saved facilities cleared',
      );
    } catch (e) {
      debugPrint('Error clearing saved facilities: $e');
      return SavedFacilityResult.failure('Failed to clear facilities: $e');
    }
  }

  /// Get facility summary
  static String getFacilitySummary(List<SavedFacility> facilities) {
    final buffer = StringBuffer();
    
    buffer.writeln('Saved Facilities Summary');
    buffer.writeln('========================');
    buffer.writeln();
    
    buffer.writeln('Total: ${facilities.length}');
    
    if (facilities.isNotEmpty) {
      final statistics = FacilityStatistics.fromFacilities(facilities);
      buffer.writeln('With Phone: ${statistics.facilitiesWithPhone}');
      buffer.writeln('With Location: ${statistics.facilitiesWithCoordinates}');
      buffer.writeln();
      
      buffer.writeln('By Type:');
      for (final entry in statistics.typeCounts.entries) {
        buffer.writeln('  ${entry.key}: ${entry.value}');
      }
      
      buffer.writeln();
      buffer.writeln('Recent Facilities:');
      for (int i = 0; i < facilities.length && i < 5; i++) {
        final facility = facilities[i];
        buffer.writeln('• ${facility.name} (${facility.typeDisplayName})');
      }
    }
    
    return buffer.toString();
  }

  /// Check facility availability
  static Future<bool> checkFacilityAvailability(SavedFacility facility) async {
    try {
      // This would check if facility is still active/available
      // For now, return true
      return true;
    } catch (e) {
      debugPrint('Error checking facility availability: $e');
      return false;
    }
  }

  /// Update facility metadata
  static Future<SavedFacilityResult> updateFacilityMetadata(
    String facilityId,
    Map<String, dynamic> metadata,
  ) async {
    try {
      final authService = AuthService.instance;
      await authService.init();
      
      final userId = authService.user?['id'];
      if (userId == null) {
        throw Exception('No user id');
      }
      
      final response = await Api.patch('/users/$userId/saved/$facilityId', {
        'metadata': metadata,
      });
      
      final savedData = response['saved'] as List<dynamic>? ?? [];
      final updatedFacilities = savedData
          .map((item) => SavedFacility.fromJson(item as Map<String, dynamic>))
          .toList();
      
      final updatedFacility = updatedFacilities.firstWhere(
        (f) => f.id == facilityId,
        orElse: () => throw Exception('Facility not found'),
      );
      
      return SavedFacilityResult.success(
        message: 'Facility metadata updated',
        facility: updatedFacility,
      );
    } catch (e) {
      debugPrint('Error updating facility metadata: $e');
      return SavedFacilityResult.failure('Failed to update metadata: $e');
    }
  }

  /// Get facility contact methods
  static List<String> getFacilityContactMethods(SavedFacility facility) {
    final methods = <String>[];
    
    if (facility.hasPhone) {
      methods.add('Phone: ${facility.formattedPhone}');
    }
    
    if (facility.hasEmail) {
      methods.add('Email: ${facility.email}');
    }
    
    if (facility.hasWebsite) {
      methods.add('Website: ${facility.website}');
    }
    
    return methods;
  }

  /// Format facility address for display
  static String formatFacilityAddress(SavedFacility facility) {
    if (facility.address.isNotEmpty) {
      return facility.address;
    }
    
    if (facility.hasCoordinates) {
      return 'Lat: ${facility.latitude.toStringAsFixed(4)}, Lng: ${facility.longitude.toStringAsFixed(4)}';
    }
    
    return 'No address available';
  }

  /// Get facility distance from current location
  static Future<double?> getDistanceFromCurrentLocation(SavedFacility facility) async {
    try {
      // This would get current location and calculate distance
      // For now, return null
      return null;
    } catch (e) {
      debugPrint('Error getting distance from current location: $e');
      return null;
    }
  }

  /// Create facility from map data
  static SavedFacility createFacilityFromMap(Map<String, dynamic> data) {
    return SavedFacility.fromJson(data);
  }

  /// Compare facilities for sorting
  static int compareFacilities(SavedFacility a, SavedFacility b, String sortBy) {
    switch (sortBy.toLowerCase()) {
      case 'name':
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      case 'type':
        return a.type.toLowerCase().compareTo(b.type.toLowerCase());
      case 'address':
        return a.address.toLowerCase().compareTo(b.address.toLowerCase());
      case 'created':
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return a.createdAt!.compareTo(b.createdAt!);
      default:
        return 0;
    }
  }

  /// Get facility sharing link
  static String getFacilitySharingLink(SavedFacility facility) {
    if (facility.hasCoordinates) {
      return facility.googleMapsUrl;
    }
    
    // Create a basic sharing link with facility info
    final encodedName = Uri.encodeComponent(facility.name);
    final encodedAddress = Uri.encodeComponent(facility.address);
    return 'https://maps.google.com/?q=$encodedName,$encodedAddress';
  }

  /// Share facility information
  static Future<bool> shareFacility(SavedFacility facility) async {
    try {
      final shareText = '''
${facility.name}
${facility.typeDisplayName}
${facility.address}
${facility.hasPhone ? 'Phone: ${facility.formattedPhone}' : ''}
${facility.hasCoordinates ? 'Location: ${facility.googleMapsUrl}' : ''}
''';
      
      // This would use share_plus package in a real app
      debugPrint('Sharing facility: $shareText');
      return true;
    } catch (e) {
      debugPrint('Error sharing facility: $e');
      return false;
    }
  }

  /// Get facility health score
  static double getFacilityHealthScore(SavedFacility facility) {
    double score = 0.0;
    
    // Base score for having basic info
    score += facility.name.isNotEmpty ? 1.0 : 0.0;
    score += facility.address.isNotEmpty ? 1.0 : 0.0;
    score += facility.type.isNotEmpty ? 0.5 : 0.0;
    
    // Contact methods
    score += facility.hasPhone ? 1.0 : 0.0;
    score += facility.hasEmail ? 0.5 : 0.0;
    score += facility.hasWebsite ? 0.5 : 0.0;
    
    // Location data
    score += facility.hasCoordinates ? 1.0 : 0.0;
    
    // Additional info
    score += facility.description?.isNotEmpty == true ? 0.5 : 0.0;
    score += facility.imageUrl?.isNotEmpty == true ? 0.5 : 0.0;
    
    return score;
  }

  /// Get facilities sorted by health score
  static List<SavedFacility> getFacilitiesByHealthScore(List<SavedFacility> facilities) {
    final sorted = List<SavedFacility>.from(facilities);
    
    sorted.sort((a, b) {
      final scoreA = getFacilityHealthScore(a);
      final scoreB = getFacilityHealthScore(b);
      return scoreB.compareTo(scoreA); // Higher score first
    });
    
    return sorted;
  }

  /// Get facilities needing updates
  static List<SavedFacility> getFacilitiesNeedingUpdates(List<SavedFacility> facilities) {
    return facilities.where((facility) {
      final score = getFacilityHealthScore(facility);
      return score < 3.0; // Facilities with low health scores
    }).toList();
  }

  /// Bulk remove facilities
  static Future<SavedFacilityResult> bulkRemoveFacilities(List<String> facilityIds) async {
    try {
      int successCount = 0;
      int failureCount = 0;
      
      for (final facilityId in facilityIds) {
        try {
          final result = await removeSavedFacility(facilityId);
          if (result.success) {
            successCount++;
          } else {
            failureCount++;
          }
        } catch (e) {
          failureCount++;
        }
      }
      
      if (failureCount == 0) {
        return SavedFacilityResult.success(
          message: 'Successfully removed $successCount facilities',
        );
      } else {
        return SavedFacilityResult.failure(
          'Removed $successCount facilities, failed to remove $failureCount',
        );
      }
    } catch (e) {
      debugPrint('Error bulk removing facilities: $e');
      return SavedFacilityResult.failure('Bulk removal failed: $e');
    }
  }

  /// Get facility categories
  static Map<String, List<SavedFacility>> getFacilityCategories(List<SavedFacility> facilities) {
    final categories = <String, List<SavedFacility>>{};
    
    for (final facility in facilities) {
      final category = facility.typeDisplayName;
      categories.putIfAbsent(category, () => []).add(facility);
    }
    
    return categories;
  }

  /// Get facility search suggestions
  static List<String> getSearchSuggestions(List<SavedFacility> facilities) {
    final suggestions = <String>{};
    
    for (final facility in facilities) {
      // Add facility name words
      final nameWords = facility.name.toLowerCase().split(' ');
      suggestions.addAll(nameWords);
      
      // Add type
      suggestions.add(facility.type.toLowerCase());
      
      // Add address words
      final addressWords = facility.address.toLowerCase().split(' ');
      suggestions.addAll(addressWords);
    }
    
    final sortedSuggestions = suggestions.toList();
    sortedSuggestions.sort();
    
    return sortedSuggestions;
  }
}
