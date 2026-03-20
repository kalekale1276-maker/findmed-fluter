import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../models/facility_detail_models.dart';

/// Services for facility detail functionality
class FacilityDetailServices {
  /// Launch phone call
  static Future<FacilityActionResult> makePhoneCall(FacilityDetail facility) async {
    if (!facility.hasPhone) {
      return FacilityActionResult.failure(
        FacilityAction.call,
        'No phone number available',
      );
    }

    try {
      final url = facility.phoneUrl;
      final success = await launchUrlString(url);
      
      if (success) {
        return FacilityActionResult.success(
          FacilityAction.call,
          message: 'Calling ${facility.phone}',
        );
      } else {
        return FacilityActionResult.failure(
          FacilityAction.call,
          'Unable to make phone call',
        );
      }
    } catch (e) {
      debugPrint('Error making phone call: $e');
      return FacilityActionResult.failure(
        FacilityAction.call,
        'Failed to make phone call: $e',
      );
    }
  }

  /// Launch Google Maps directions
  static Future<FacilityActionResult> launchDirections(FacilityDetail facility) async {
    if (!facility.hasValidLocation) {
      return FacilityActionResult.failure(
        FacilityAction.directions,
        'No location information available',
      );
    }

    try {
      final url = facility.googleMapsDirectionsUrl;
      final success = await launchUrlString(url);
      
      if (success) {
        return FacilityActionResult.success(
          FacilityAction.directions,
          message: 'Opening directions to ${facility.name}',
        );
      } else {
        return FacilityActionResult.failure(
          FacilityAction.directions,
          'Unable to open directions',
        );
      }
    } catch (e) {
      debugPrint('Error launching directions: $e');
      return FacilityActionResult.failure(
        FacilityAction.directions,
        'Failed to open directions: $e',
      );
    }
  }

  /// Launch Google Maps search
  static Future<FacilityActionResult> launchMapSearch(FacilityDetail facility) async {
    if (!facility.hasValidLocation) {
      return FacilityActionResult.failure(
        FacilityAction.directions,
        'No location information available',
      );
    }

    try {
      final url = facility.googleMapsSearchUrl;
      final success = await launchUrlString(url);
      
      if (success) {
        return FacilityActionResult.success(
          FacilityAction.directions,
          message: 'Searching for ${facility.name}',
        );
      } else {
        return FacilityActionResult.failure(
          FacilityAction.directions,
          'Unable to open map search',
        );
      }
    } catch (e) {
      debugPrint('Error launching map search: $e');
      return FacilityActionResult.failure(
        FacilityAction.directions,
        'Failed to open map search: $e',
      );
    }
  }

  /// Send email
  static Future<FacilityActionResult> sendEmail(FacilityDetail facility) async {
    if (!facility.hasEmail) {
      return FacilityActionResult.failure(
        FacilityAction.email,
        'No email address available',
      );
    }

    try {
      final url = facility.emailUrl;
      final success = await launchUrlString(url);
      
      if (success) {
        return FacilityActionResult.success(
          FacilityAction.email,
          message: 'Opening email app',
        );
      } else {
        return FacilityActionResult.failure(
          FacilityAction.email,
          'Unable to open email app',
        );
      }
    } catch (e) {
      debugPrint('Error sending email: $e');
      return FacilityActionResult.failure(
        FacilityAction.email,
        'Failed to open email: $e',
      );
    }
  }

  /// Share facility information
  static Future<FacilityActionResult> shareFacility(FacilityDetail facility) async {
    try {
      final shareText = _generateShareText(facility);
      
      // This would typically use the share package
      // For now, return success as mock
      return FacilityActionResult.success(
        FacilityAction.share,
        message: 'Sharing facility information',
      );
    } catch (e) {
      debugPrint('Error sharing facility: $e');
      return FacilityActionResult.failure(
        FacilityAction.share,
        'Failed to share facility: $e',
      );
    }
  }

  /// Generate share text
  static String _generateShareText(FacilityDetail facility) {
    final buffer = StringBuffer();
    buffer.writeln('${facility.name}');
    
    if (facility.address.isNotEmpty) {
      buffer.writeln('📍 ${facility.address}');
    }
    
    if (facility.hasPhone) {
      buffer.writeln('📞 ${facility.phone}');
    }
    
    if (facility.hasEmail) {
      buffer.writeln('📧 ${facility.email}');
    }
    
    if (facility.hasValidLocation) {
      buffer.writeln('🗺️ ${facility.googleMapsSearchUrl}');
    }
    
    if (facility.hasServices) {
      buffer.writeln('🏥 Services: ${facility.formattedServices}');
    }
    
    buffer.writeln('\nShared via FindMed App');
    
    return buffer.toString();
  }

  /// Get facility rating (mock implementation)
  static Future<FacilityRating?> getFacilityRating(String facilityId) async {
    try {
      // This would typically call an API to get ratings
      // For now, return mock rating
      await Future.delayed(const Duration(milliseconds: 500));
      
      return FacilityRating(
        averageRating: 4.2,
        totalRatings: 156,
        ratingDistribution: {
          1: 5,
          2: 8,
          3: 23,
          4: 67,
          5: 53,
        },
      );
    } catch (e) {
      debugPrint('Error getting facility rating: $e');
      return null;
    }
  }

  /// Get facility operating hours (mock implementation)
  static Future<FacilityOperatingHours?> getFacilityOperatingHours(String facilityId) async {
    try {
      // This would typically call an API to get operating hours
      // For now, return mock hours
      await Future.delayed(const Duration(milliseconds: 300));
      
      return FacilityOperatingHours(
        weeklyHours: {
          'monday': ['8:00 AM - 6:00 PM'],
          'tuesday': ['8:00 AM - 6:00 PM'],
          'wednesday': ['8:00 AM - 6:00 PM'],
          'thursday': ['8:00 AM - 6:00 PM'],
          'friday': ['8:00 AM - 6:00 PM'],
          'saturday': ['9:00 AM - 2:00 PM'],
          'sunday': ['Closed'],
        },
        timezone: 'UTC+3',
      );
    } catch (e) {
      debugPrint('Error getting facility operating hours: $e');
      return null;
    }
  }

  /// Save facility to favorites (mock implementation)
  static Future<FacilityActionResult> saveToFavorites(FacilityDetail facility) async {
    try {
      // This would typically save to local storage or API
      // For now, return success as mock
      await Future.delayed(const Duration(milliseconds: 200));
      
      return FacilityActionResult.success(
        FacilityAction.share,
        message: 'Added to favorites',
      );
    } catch (e) {
      debugPrint('Error saving to favorites: $e');
      return FacilityActionResult.failure(
        FacilityAction.share,
        'Failed to save to favorites: $e',
      );
    }
  }

  /// Check if facility is in favorites (mock implementation)
  static Future<bool> isFavorite(String facilityId) async {
    try {
      // This would typically check local storage or API
      // For now, return false as mock
      await Future.delayed(const Duration(milliseconds: 100));
      return false;
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
      return false;
    }
  }

  /// Remove from favorites (mock implementation)
  static Future<FacilityActionResult> removeFromFavorites(String facilityId) async {
    try {
      // This would typically remove from local storage or API
      // For now, return success as mock
      await Future.delayed(const Duration(milliseconds: 200));
      
      return FacilityActionResult.success(
        FacilityAction.share,
        message: 'Removed from favorites',
      );
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
      return FacilityActionResult.failure(
        FacilityAction.share,
        'Failed to remove from favorites: $e',
      );
    }
  }

  /// Report facility issue (mock implementation)
  static Future<FacilityActionResult> reportIssue({
    required String facilityId,
    required String issueType,
    required String description,
  }) async {
    try {
      // This would typically send report to API
      // For now, return success as mock
      await Future.delayed(const Duration(milliseconds: 500));
      
      return FacilityActionResult.success(
        FacilityAction.share,
        message: 'Issue reported successfully',
      );
    } catch (e) {
      debugPrint('Error reporting issue: $e');
      return FacilityActionResult.failure(
        FacilityAction.share,
        'Failed to report issue: $e',
      );
    }
  }

  /// Get facility reviews (mock implementation)
  static Future<List<Map<String, dynamic>>> getFacilityReviews(String facilityId) async {
    try {
      // This would typically call an API to get reviews
      // For now, return mock reviews
      await Future.delayed(const Duration(milliseconds: 400));
      
      return [
        {
          'id': '1',
          'userName': 'John Doe',
          'rating': 5,
          'comment': 'Excellent service and very professional staff.',
          'createdAt': '2024-01-15T10:30:00Z',
        },
        {
          'id': '2',
          'userName': 'Jane Smith',
          'rating': 4,
          'comment': 'Good facility but wait times can be long.',
          'createdAt': '2024-01-10T14:20:00Z',
        },
      ];
    } catch (e) {
      debugPrint('Error getting facility reviews: $e');
      return [];
    }
  }

  /// Submit facility review (mock implementation)
  static Future<FacilityActionResult> submitReview({
    required String facilityId,
    required int rating,
    required String comment,
  }) async {
    try {
      // This would typically send review to API
      // For now, return success as mock
      await Future.delayed(const Duration(milliseconds: 600));
      
      return FacilityActionResult.success(
        FacilityAction.share,
        message: 'Review submitted successfully',
      );
    } catch (e) {
      debugPrint('Error submitting review: $e');
      return FacilityActionResult.failure(
        FacilityAction.share,
        'Failed to submit review: $e',
      );
    }
  }

  /// Validate facility data
  static bool isValidFacility(Map<String, dynamic> facilityData) {
    final name = facilityData['name'] as String?;
    final id = facilityData['_id'] as String? ?? facilityData['id'] as String?;
    
    return name != null && name.isNotEmpty && id != null && id.isNotEmpty;
  }

  /// Get facility completion score
  static double getCompletionScore(FacilityDetail facility) {
    return facility.completionPercentage;
  }

  /// Format phone number for display
  static String formatPhoneNumber(String phone) {
    // Basic phone formatting - can be enhanced based on region
    if (phone.isEmpty) return '';
    
    // Remove non-digit characters
    final digits = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Basic formatting for Ethiopian numbers
    if (digits.startsWith('+251') && digits.length == 12) {
      return '+251 ${digits.substring(3, 6)} ${digits.substring(6)}';
    }
    
    // Return original if no formatting rules apply
    return phone;
  }

  /// Get facility type icon
  static String getFacilityTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'hospital':
        return '🏥';
      case 'pharmacy':
        return '💊';
      case 'clinic':
        return '🏥';
      case 'laboratory':
        return '🔬';
      case 'dental':
        return '🦷';
      default:
        return '🏥';
    }
  }

  /// Get facility type color
  static String getFacilityTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'hospital':
        return '#FF5252';
      case 'pharmacy':
        return '#4CAF50';
      case 'clinic':
        return '#2196F3';
      case 'laboratory':
        return '#9C27B0';
      case 'dental':
        return '#FF9800';
      default:
        return '#757575';
    }
  }
}
