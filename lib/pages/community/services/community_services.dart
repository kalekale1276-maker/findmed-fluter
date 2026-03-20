import 'package:flutter/foundation.dart';
import '../models/community_models.dart';

/// Services for community functionality
class CommunityServices {
  /// Get all community features
  static List<CommunityFeature> getCommunityFeatures() {
    return CommunityFeature.getAllFeatures();
  }

  /// Get community statistics
  static Future<CommunityStats> getCommunityStats() async {
    try {
      // This would typically call an API to get real stats
      // For now, return mock stats
      await Future.delayed(const Duration(milliseconds: 500));
      return CommunityStats.mockStats;
    } catch (e) {
      debugPrint('Error loading community stats: $e');
      rethrow;
    }
  }

  /// Get recent community activity
  static Future<List<CommunityActivity>> getRecentActivity({int limit = 10}) async {
    try {
      // This would typically call an API to get real activity
      // For now, return mock activities
      await Future.delayed(const Duration(milliseconds: 300));
      return CommunityActivity.mockActivities.take(limit).toList();
    } catch (e) {
      debugPrint('Error loading recent activity: $e');
      rethrow;
    }
  }

  /// Get user contributions
  static Future<List<CommunityContribution>> getUserContributions(String userId) async {
    try {
      // This would typically call an API to get user contributions
      // For now, return empty list as mock
      await Future.delayed(const Duration(milliseconds: 400));
      return [];
    } catch (e) {
      debugPrint('Error loading user contributions: $e');
      rethrow;
    }
  }

  /// Get pending contributions for review
  static Future<List<CommunityContribution>> getPendingContributions() async {
    try {
      // This would typically call an API to get pending contributions
      // For now, return empty list as mock
      await Future.delayed(const Duration(milliseconds: 300));
      return [];
    } catch (e) {
      debugPrint('Error loading pending contributions: $e');
      rethrow;
    }
  }

  /// Submit new facility contribution
  static Future<CommunityActionResult> submitFacility({
    required String name,
    required String type,
    required String address,
    required String description,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // This would typically call an API to submit facility
      // For now, return success as mock
      await Future.delayed(const Duration(milliseconds: 1000));
      return CommunityActionResult.success('Facility submitted for review');
    } catch (e) {
      debugPrint('Error submitting facility: $e');
      return CommunityActionResult.failure('Failed to submit facility: $e');
    }
  }

  /// Update facility contribution
  static Future<CommunityActionResult> updateFacility({
    required String facilityId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      // This would typically call an API to update facility
      // For now, return success as mock
      await Future.delayed(const Duration(milliseconds: 800));
      return CommunityActionResult.success('Facility update submitted for review');
    } catch (e) {
      debugPrint('Error updating facility: $e');
      return CommunityActionResult.failure('Failed to update facility: $e');
    }
  }

  /// Submit forum post
  static Future<CommunityActionResult> submitForumPost({
    required String title,
    required String content,
    required String category,
    List<String>? tags,
  }) async {
    try {
      // This would typically call an API to submit forum post
      // For now, return success as mock
      await Future.delayed(const Duration(milliseconds: 600));
      return CommunityActionResult.success('Forum post submitted successfully');
    } catch (e) {
      debugPrint('Error submitting forum post: $e');
      return CommunityActionResult.failure('Failed to submit forum post: $e');
    }
  }

  /// Submit crowdsourced update
  static Future<CommunityActionResult> submitCrowdsourcedUpdate({
    required String facilityId,
    required String updateType,
    required String description,
    Map<String, dynamic? evidence,
  }) async {
    try {
      // This would typically call an API to submit update
      // For now, return success as mock
      await Future.delayed(const Duration(milliseconds: 700));
      return CommunityActionResult.success('Update submitted for review');
    } catch (e) {
      debugPrint('Error submitting crowdsourced update: $e');
      return CommunityActionResult.failure('Failed to submit update: $e');
    }
  }

  /// Search community contributions
  static Future<List<CommunityContribution>> searchContributions({
    String query = '',
    String? featureId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // This would typically call an API to search contributions
      // For now, return empty list as mock
      await Future.delayed(const Duration(milliseconds: 400));
      return [];
    } catch (e) {
      debugPrint('Error searching contributions: $e');
      rethrow;
    }
  }

  /// Upvote contribution
  static Future<CommunityActionResult> upvoteContribution(String contributionId) async {
    try {
      // This would typically call an API to upvote
      // For now, return success as mock
      await Future.delayed(const Duration(milliseconds: 200));
      return CommunityActionResult.success('Upvoted successfully');
    } catch (e) {
      debugPrint('Error upvoting contribution: $e');
      return CommunityActionResult.failure('Failed to upvote: $e');
    }
  }

  /// Report contribution
  static Future<CommunityActionResult> reportContribution({
    required String contributionId,
    required String reason,
    String? details,
  }) async {
    try {
      // This would typically call an API to report
      // For now, return success as mock
      await Future.delayed(const Duration(milliseconds: 300));
      return CommunityActionResult.success('Contribution reported successfully');
    } catch (e) {
      debugPrint('Error reporting contribution: $e');
      return CommunityActionResult.failure('Failed to report: $e');
    }
  }

  /// Get community guidelines
  static List<CommunityGuideline> getCommunityGuidelines() {
    return CommunityGuideline.getAllGuidelines();
  }

  /// Validate contribution data
  static ValidationResult validateFacilitySubmission({
    required String name,
    required String type,
    required String address,
    required String description,
  }) {
    if (name.trim().isEmpty) {
      return ValidationResult.invalid('Facility name is required');
    }

    if (name.trim().length < 3) {
      return ValidationResult.invalid('Facility name must be at least 3 characters');
    }

    if (type.trim().isEmpty) {
      return ValidationResult.invalid('Facility type is required');
    }

    if (address.trim().isEmpty) {
      return ValidationResult.invalid('Address is required');
    }

    if (description.trim().isEmpty) {
      return ValidationResult.invalid('Description is required');
    }

    if (description.trim().length < 10) {
      return ValidationResult.invalid('Description must be at least 10 characters');
    }

    return ValidationResult.valid;
  }

  /// Validate forum post data
  static ValidationResult validateForumPost({
    required String title,
    required String content,
    required String category,
  }) {
    if (title.trim().isEmpty) {
      return ValidationResult.invalid('Title is required');
    }

    if (title.trim().length < 5) {
      return ValidationResult.invalid('Title must be at least 5 characters');
    }

    if (content.trim().isEmpty) {
      return ValidationResult.invalid('Content is required');
    }

    if (content.trim().length < 20) {
      return ValidationResult.invalid('Content must be at least 20 characters');
    }

    if (category.trim().isEmpty) {
      return ValidationResult.invalid('Category is required');
    }

    return ValidationResult.valid;
  }

  /// Get contribution statistics for user
  static Future<Map<String, int>> getUserContributionStats(String userId) async {
    try {
      // This would typically call an API to get user stats
      // For now, return mock stats
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'total': 12,
        'approved': 8,
        'pending': 3,
        'rejected': 1,
        'upvotes': 45,
      };
    } catch (e) {
      debugPrint('Error loading user contribution stats: $e');
      rethrow;
    }
  }

  /// Check if user can contribute
  static Future<bool> canUserContribute(String userId) async {
    try {
      // This would typically check user permissions
      // For now, return true as mock
      await Future.delayed(const Duration(milliseconds: 200));
      return true;
    } catch (e) {
      debugPrint('Error checking user permissions: $e');
      return false;
    }
  }

  /// Get contribution types
  static List<String> getContributionTypes() {
    return [
      'new_facility',
      'facility_update',
      'forum_post',
      'review',
      'crowdsourced_update',
      'correction',
    ];
  }

  /// Get forum categories
  static List<String> getForumCategories() {
    return [
      'General Discussion',
      'Facility Reviews',
      'Health Tips',
      'Questions',
      'Announcements',
      'Feedback',
    ];
  }

  /// Get facility types
  static List<String> getFacilityTypes() {
    return [
      'Hospital',
      'Pharmacy',
      'Clinic',
      'Laboratory',
      'Dental Clinic',
      'Eye Clinic',
      'Mental Health',
      'Emergency Care',
    ];
  }
}

/// Community action result
class CommunityActionResult {
  final bool success;
  final String? message;
  final String? contributionId;

  CommunityActionResult({
    required this.success,
    this.message,
    this.contributionId,
  });

  factory CommunityActionResult.success(String message, {String? contributionId}) {
    return CommunityActionResult(
      success: true,
      message: message,
      contributionId: contributionId,
    );
  }

  factory CommunityActionResult.failure(String message) {
    return CommunityActionResult(
      success: false,
      message: message,
    );
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
