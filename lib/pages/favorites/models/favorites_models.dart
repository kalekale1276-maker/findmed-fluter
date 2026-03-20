/// Models and constants for favorites functionality
class FavoritesConstants {
  // UI labels
  static const String pageTitle = 'Favorites';
  static const String addFavoriteLabel = 'Add favorite';
  static const String noFavoritesMessage = 'No favorites yet';
  static const String searchHint = 'Search facilities';
  static const String addFavoriteSheetTitle = 'Add Favorite';
  static const String rateFacilityTitle = 'Rate facility';
  static const String submitLabel = 'Submit';
  static const String cancelLabel = 'Cancel';
  
  // Sort options
  static const String sortManual = 'manual';
  static const String sortMostViewed = 'most_viewed';
  static const String sortTopRated = 'top_rated';
  static const String sortRecent = 'recent';
  
  // Sort labels
  static const String sortManualLabel = 'Manual';
  static const String sortMostViewedLabel = 'Sort: Most viewed';
  static const String sortTopRatedLabel = 'Sort: Top rated';
  static const String sortRecentLabel = 'Sort: Recently viewed';
  
  // Toast messages
  static const String addedToFavoritesMessage = 'Added to favorites';
  static const String failedToAddMessage = 'Failed to add: ';
  static const String removedFromFavoritesMessage = 'Removed from favorites';
  static const String failedToRemoveMessage = 'Failed to remove: ';
  
  // API endpoints
  static const String savedFacilitiesEndpoint = '/users/{userId}/saved';
  static const String saveFacilityEndpoint = '/users/{userId}/saved';
  static const String removeSavedFacilityEndpoint = '/users/{userId}/saved/{facilityId}';
  static const String rateFacilityEndpoint = '/facilities/{facilityId}/rate';
  static const String viewFacilityEndpoint = '/facilities/{facilityId}/view';
  static const String facilitiesEndpoint = '/facilities';
  
  // Storage keys
  static const String favoritesStorageKey = 'favorites';
  
  // Rating settings
  static const int maxRating = 5;
  static const int defaultRating = 5;
  
  // Animation durations
  static const int animationDurationMs = 300;
  static const int sheetAnimationDurationMs = 250;
}

/// Favorite facility model
class FavoriteFacility {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String type;
  final int? viewsTotal;
  final double? averageRating;
  final int? ratingCount;
  final DateTime? lastViewedAt;
  final Map<String, dynamic> rawData;

  FavoriteFacility({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.type,
    this.viewsTotal,
    this.averageRating,
    this.ratingCount,
    this.lastViewedAt,
    this.rawData = const {},
  });

  factory FavoriteFacility.fromJson(Map<String, dynamic> json) {
    return FavoriteFacility(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Facility',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      viewsTotal: json['viewsTotal'] as int?,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      ratingCount: json['ratingCount'] as int?,
      lastViewedAt: json['lastViewedAt'] != null 
          ? DateTime.tryParse(json['lastViewedAt'].toString())
          : null,
      rawData: json,
    );
  }

  /// Check if facility has phone
  bool get hasPhone => phone.isNotEmpty;

  /// Check if facility has rating
  bool get hasRating => averageRating != null && averageRating! > 0;

  /// Check if facility has views
  bool get hasViews => viewsTotal != null && viewsTotal! > 0;

  /// Get formatted rating display
  String get formattedRating {
    if (!hasRating) return '0.0';
    return averageRating!.toStringAsFixed(1);
  }

  /// Get formatted views display
  String get formattedViews {
    if (!hasViews) return '0';
    return viewsTotal!.toString();
  }

  /// Get formatted last viewed date
  String get formattedLastViewed {
    if (lastViewedAt == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(lastViewedAt!);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${lastViewedAt!.day}/${lastViewedAt!.month}/${lastViewedAt!.year}';
    }
  }

  /// Get facility type icon
  IconData get typeIcon {
    return type.toLowerCase() == 'hospital' ? Icons.local_hospital : Icons.local_pharmacy;
  }

  /// Get phone URL
  String get phoneUrl {
    if (!hasPhone) return '';
    return 'tel:$phone';
  }

  /// Get coordinates for maps
  LatLng? get coordinates {
    final loc = rawData['location'];
    if (loc is Map && loc['coordinates'] is List && (loc['coordinates'] as List).length >= 2) {
      final coords = List.from(loc['coordinates']);
      final lng = (coords[0] as num).toDouble();
      final lat = (coords[1] as num).toDouble();
      return LatLng(lat, lng);
    }
    return null;
  }

  /// Get Google Maps URL
  String get mapsUrl {
    final coords = coordinates;
    if (coords == null) return '';
    return 'https://www.google.com/maps/search/?api=1&query=${coords.latitude},${coords.longitude}';
  }

  /// Check if matches search query
  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    
    final lowerQuery = query.toLowerCase();
    final nameMatch = name.toLowerCase().contains(lowerQuery);
    final addressMatch = address.toLowerCase().contains(lowerQuery);
    
    return nameMatch || addressMatch;
  }
}

/// Favorites state model
class FavoritesState {
  final List<FavoriteFacility> favorites;
  final bool isLoading;
  final String? error;
  final String sortOption;
  final String searchQuery;

  const FavoritesState({
    this.favorites = const [],
    this.isLoading = true,
    this.error,
    this.sortOption = FavoritesConstants.sortManual,
    this.searchQuery = '',
  });

  FavoritesState copyWith({
    List<FavoriteFacility>? favorites,
    bool? isLoading,
    String? error,
    String? sortOption,
    String? searchQuery,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      sortOption: sortOption ?? this.sortOption,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Check if there are any favorites
  bool get hasFavorites => favorites.isNotEmpty;

  /// Get filtered favorites based on search
  List<FavoriteFacility> get filteredFavorites {
    if (searchQuery.isEmpty) return favorites;
    
    return favorites.where((facility) => facility.matchesQuery(searchQuery)).toList();
  }

  /// Get sorted favorites
  List<FavoriteFacility> get sortedFavorites {
    final sorted = List<FavoriteFacility>.from(filteredFavorites);
    
    switch (sortOption) {
      case FavoritesConstants.sortMostViewed:
        sorted.sort((a, b) => (b.viewsTotal ?? 0).compareTo(a.viewsTotal ?? 0));
        break;
      case FavoritesConstants.sortTopRated:
        sorted.sort((a, b) => (b.averageRating ?? 0).compareTo(a.averageRating ?? 0));
        break;
      case FavoritesConstants.sortRecent:
        sorted.sort((a, b) {
          final dateA = a.lastViewedAt;
          final dateB = b.lastViewedAt;
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA);
        });
        break;
      case FavoritesConstants.sortManual:
      default:
        // Keep original order
        break;
    }
    
    return sorted;
  }

  /// Clear error
  FavoritesState clearError() => copyWith(error: null);

  /// Set loading
  FavoritesState setLoading(bool loading) => copyWith(isLoading: loading, error: null);

  /// Set error
  FavoritesState setError(String error) => copyWith(isLoading: false, error: error);

  /// Update sort option
  FavoritesState updateSortOption(String option) => copyWith(sortOption: option);

  /// Update search query
  FavoritesState updateSearchQuery(String query) => copyWith(searchQuery: query);
}

/// Favorite action result
class FavoriteActionResult {
  final bool success;
  final String? message;

  FavoriteActionResult({
    required this.success,
    this.message,
  });

  factory FavoriteActionResult.success(String message) {
    return FavoriteActionResult(
      success: true,
      message: message,
    );
  }

  factory FavoriteActionResult.failure(String message) {
    return FavoriteActionResult(
      success: false,
      message: message,
    );
  }
}

/// Rating result
class RatingResult {
  final bool success;
  final double? newAverageRating;
  final int? newRatingCount;
  final String? message;

  RatingResult({
    required this.success,
    this.newAverageRating,
    this.newRatingCount,
    this.message,
  });

  factory RatingResult.success({
    double? newAverageRating,
    int? newRatingCount,
    String? message,
  }) {
    return RatingResult(
      success: true,
      newAverageRating: newAverageRating,
      newRatingCount: newRatingCount,
      message: message,
    );
  }

  factory RatingResult.failure(String message) {
    return RatingResult(
      success: false,
      message: message,
    );
  }
}

/// Facility search result
class FacilitySearchResult {
  final List<FavoriteFacility> facilities;
  final bool isLoading;
  final String? error;

  FacilitySearchResult({
    required this.facilities,
    this.isLoading = false,
    this.error,
  });

  factory FacilitySearchResult.loading() {
    return FacilitySearchResult(
      facilities: [],
      isLoading: true,
    );
  }

  factory FacilitySearchResult.error(String error) {
    return FacilitySearchResult(
      facilities: [],
      error: error,
    );
  }

  factory FacilitySearchResult.success(List<FavoriteFacility> facilities) {
    return FacilitySearchResult(
      facilities: facilities,
    );
  }
}

/// Import LatLng
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
