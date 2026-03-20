import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../services/auth.dart';
import '../../../../services/api.dart';
import '../models/favorites_models.dart';

/// Services for favorites functionality
class FavoritesServices {
  static final AuthService _auth = AuthService.instance;

  /// Load favorites from backend or local storage
  static Future<List<FavoriteFacility>> loadFavorites() async {
    try {
      if (_auth.isLoggedIn && _auth.user != null) {
        // Load from backend
        return await _loadFromBackend();
      } else {
        // Fallback to local storage
        return await _loadFromLocalStorage();
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      rethrow;
    }
  }

  /// Load favorites from backend
  static Future<List<FavoriteFacility>> _loadFromBackend() async {
    final userId = _auth.user?['id'] ?? _auth.user?['_id'];
    if (userId == null) throw Exception('No user id');

    final response = await Api.get('/users/$userId/saved');
    final savedList = (response['saved'] as List<dynamic>?) ?? [];

    return savedList
        .map((item) => FavoriteFacility.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  /// Load favorites from local storage
  static Future<List<FavoriteFacility>> _loadFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(FavoritesConstants.favoritesStorageKey);

    if (favoritesJson != null) {
      final List<dynamic> list = jsonDecode(favoritesJson);
      return list
          .map((item) => FavoriteFacility.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    return [];
  }

  /// Add favorite to backend or local storage
  static Future<FavoriteActionResult> addFavorite(Map<String, dynamic> facility) async {
    try {
      final facilityId = facility['_id'] ?? facility['id'];
      if (facilityId == null) throw Exception('Missing facility id');

      // Check if already favorited
      if (await isFavoritedById(facilityId)) {
        return FavoriteActionResult.success('Already in favorites');
      }

      if (_auth.isLoggedIn && _auth.user != null) {
        // Add to backend
        return await _addToBackend(facilityId);
      } else {
        // Add to local storage
        return await _addToLocalStorage(facility);
      }
    } catch (e) {
      debugPrint('Error adding favorite: $e');
      return FavoriteActionResult.failure('${FavoritesConstants.failedToAddMessage}$e');
    }
  }

  /// Add favorite to backend
  static Future<FavoriteActionResult> _addToBackend(String facilityId) async {
    final userId = _auth.user?['id'] ?? _auth.user?['_id'];
    if (userId == null) throw Exception('Missing user id');

    await Api.post('/users/$userId/saved', {'facilityId': facilityId});
    
    return FavoriteActionResult.success(FavoritesConstants.addedToFavoritesMessage);
  }

  /// Add favorite to local storage
  static Future<FavoriteActionResult> _addToLocalStorage(Map<String, dynamic> facility) async {
    // Try to fetch full facility details before saving
    Map<String, dynamic> facilityToSave = facility;
    
    try {
      final facilityId = facility['_id'] ?? facility['id'];
      if (facilityId != null) {
        final response = await Api.get('/facilities/$facilityId');
        
        if (response is Map && response.containsKey('name')) {
          facilityToSave = Map<String, dynamic>.from(response);
        } else if (response is Map && response['facility'] is Map) {
          facilityToSave = Map<String, dynamic>.from(response['facility']);
        }
      }
    } catch (e) {
      // Ignore, keep original minimal facility
      debugPrint('Could not fetch full facility details: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    final currentFavorites = await _loadFromLocalStorage();
    
    final favoriteFacility = FavoriteFacility.fromJson(facilityToSave);
    currentFavorites.add(favoriteFacility);
    
    await prefs.setString(
      FavoritesConstants.favoritesStorageKey,
      jsonEncode(currentFavorites.map((f) => f.rawData).toList()),
    );

    return FavoriteActionResult.success(FavoritesConstants.addedToFavoritesMessage);
  }

  /// Remove favorite from backend or local storage
  static Future<FavoriteActionResult> removeFavorite(FavoriteFacility facility) async {
    try {
      if (_auth.isLoggedIn && _auth.user != null) {
        // Remove from backend
        return await _removeFromBackend(facility.id);
      } else {
        // Remove from local storage
        return await _removeFromLocalStorage(facility.id);
      }
    } catch (e) {
      debugPrint('Error removing favorite: $e');
      return FavoriteActionResult.failure('${FavoritesConstants.failedToRemoveMessage}$e');
    }
  }

  /// Remove favorite from backend
  static Future<FavoriteActionResult> _removeFromBackend(String facilityId) async {
    final userId = _auth.user?['id'] ?? _auth.user?['_id'];
    if (userId == null) throw Exception('Missing user id');

    await Api.delete('/users/$userId/saved/$facilityId');
    
    return FavoriteActionResult.success(FavoritesConstants.removedFromFavoritesMessage);
  }

  /// Remove favorite from local storage
  static Future<FavoriteActionResult> _removeFromLocalStorage(String facilityId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentFavorites = await _loadFromLocalStorage();
    
    final updatedFavorites = currentFavorites
        .where((f) => f.id != facilityId)
        .toList();
    
    await prefs.setString(
      FavoritesConstants.favoritesStorageKey,
      jsonEncode(updatedFavorites.map((f) => f.rawData).toList()),
    );

    return FavoriteActionResult.success(FavoritesConstants.removedFromFavoritesMessage);
  }

  /// Check if facility is favorited by ID
  static Future<bool> isFavoritedById(String facilityId) async {
    try {
      final favorites = await loadFavorites();
      return favorites.any((f) => f.id == facilityId);
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
      return false;
    }
  }

  /// Search facilities for adding to favorites
  static Future<FacilitySearchResult> searchFacilities({String query = ''}) async {
    try {
      final response = await Api.get(FavoritesConstants.facilitiesEndpoint);
      
      List<dynamic> facilitiesList = [];
      if (response is List) {
        facilitiesList = response;
      } else if (response is Map) {
        if (response['items'] is List) {
          facilitiesList = response['items'];
        } else if (response['facilities'] is List) {
          facilitiesList = response['facilities'];
        }
      }

      final facilities = facilitiesList
          .map((item) => FavoriteFacility.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      // Filter by query if provided
      if (query.isNotEmpty) {
        final filtered = facilities.where((facility) => facility.matchesQuery(query)).toList();
        return FacilitySearchResult.success(filtered);
      }

      return FacilitySearchResult.success(facilities);
    } catch (e) {
      debugPrint('Error searching facilities: $e');
      return FacilitySearchResult.error('Failed to fetch facilities');
    }
  }

  /// Rate a facility
  static Future<RatingResult> rateFacility(String facilityId, int rating) async {
    try {
      final response = await Api.post(
        '/facilities/$facilityId/rate',
        {'rating': rating},
      );

      return RatingResult.success(
        newAverageRating: (response['averageRating'] as num?)?.toDouble(),
        newRatingCount: response['ratingCount'] as int?,
        message: 'Rating submitted successfully',
      );
    } catch (e) {
      debugPrint('Error rating facility: $e');
      return RatingResult.failure('Failed to submit rating: $e');
    }
  }

  /// Record facility view
  static Future<void> recordFacilityView(String facilityId) async {
    try {
      await Api.post('/facilities/$facilityId/view', {});
    } catch (e) {
      debugPrint('Error recording facility view: $e');
      // Ignore errors for analytics
    }
  }

  /// Make phone call
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

  /// Open facility in maps
  static Future<bool> openInMaps(FavoriteFacility facility) async {
    try {
      final url = facility.mapsUrl;
      if (url.isEmpty) return false;
      return await launchUrlString(url);
    } catch (e) {
      debugPrint('Error opening maps: $e');
      return false;
    }
  }

  /// Get favorite statistics
  static Map<String, dynamic> getFavoriteStatistics(List<FavoriteFacility> favorites) {
    final totalFavorites = favorites.length;
    final hospitalCount = favorites.where((f) => f.type.toLowerCase() == 'hospital').length;
    final pharmacyCount = favorites.where((f) => f.type.toLowerCase() == 'pharmacy').length;
    final withPhoneCount = favorites.where((f) => f.hasPhone).length;
    final withRatingCount = favorites.where((f) => f.hasRating).length;
    
    final averageRating = withRatingCount > 0
        ? favorites
            .where((f) => f.hasRating)
            .map((f) => f.averageRating!)
            .reduce((a, b) => a + b) / withRatingCount
        : 0.0;

    return {
      'total': totalFavorites,
      'hospitals': hospitalCount,
      'pharmacies': pharmacyCount,
      'withPhone': withPhoneCount,
      'withRating': withRatingCount,
      'averageRating': averageRating,
    };
  }

  /// Export favorites to JSON
  static String exportFavoritesToJson(List<FavoriteFacility> favorites) {
    final exportData = favorites.map((f) => f.rawData).toList();
    return jsonEncode(exportData);
  }

  /// Import favorites from JSON
  static Future<FavoriteActionResult> importFavoritesFromJson(String json) async {
    try {
      final List<dynamic> data = jsonDecode(json);
      final facilities = data
          .map((item) => FavoriteFacility.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      int imported = 0;
      int skipped = 0;

      for (final facility in facilities) {
        try {
          final result = await addFavorite(facility.rawData);
          if (result.success) {
            imported++;
          } else {
            skipped++;
          }
        } catch (e) {
          skipped++;
        }
      }

      return FavoriteActionResult.success(
        'Imported $imported favorites, $skipped skipped',
      );
    } catch (e) {
      return FavoriteActionResult.failure('Failed to import favorites: $e');
    }
  }

  /// Clear all favorites (local only)
  static Future<FavoriteActionResult> clearAllFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(FavoritesConstants.favoritesStorageKey);
      
      return FavoriteActionResult.success('All favorites cleared');
    } catch (e) {
      return FavoriteActionResult.failure('Failed to clear favorites: $e');
    }
  }

  /// Sync local favorites with backend
  static Future<FavoriteActionResult> syncWithBackend() async {
    if (!_auth.isLoggedIn) {
      return FavoriteActionResult.failure('User not logged in');
    }

    try {
      final localFavorites = await _loadFromLocalStorage();
      int synced = 0;

      for (final facility in localFavorites) {
        try {
          await _addToBackend(facility.id);
          synced++;
        } catch (e) {
          // Continue with next facility
          debugPrint('Failed to sync facility ${facility.id}: $e');
        }
      }

      // Clear local favorites after successful sync
      await clearAllFavorites();

      return FavoriteActionResult.success('Synced $synced favorites to backend');
    } catch (e) {
      return FavoriteActionResult.failure('Failed to sync favorites: $e');
    }
  }

  /// Validate facility data
  static bool isValidFacility(Map<String, dynamic> facility) {
    final name = facility['name'] as String?;
    final id = facility['_id'] as String? ?? facility['id'] as String?;
    
    return name != null && name.isNotEmpty && id != null && id.isNotEmpty;
  }

  /// Format phone number for display
  static String formatPhoneNumber(String phone) {
    if (phone.isEmpty) return '';
    
    // Remove non-digit characters
    final digits = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Basic formatting for Ethiopian numbers
    if (digits.startsWith('+251') && digits.length == 12) {
      return '+251 ${digits.substring(3, 6)} ${digits.substring(6)}';
    }
    
    return phone;
  }
}
