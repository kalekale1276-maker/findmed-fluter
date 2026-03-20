/// Models and constants for map functionality
class MapConstants {
  // UI labels
  static const String pageTitle = 'Map View';
  static const String yourLocationLabel = 'Your location';
  static const String destinationLabel = 'Destination';
  static const String routeLabel = 'Route';
  static const String facilitiesLabel = 'Facilities';
  static const String addPlaceLabel = 'Add a missing place';
  static const String addBusinessLabel = 'Add your business';
  static const String addLabelLabel = 'Add a label';
  static const String shareLabel = 'Share';
  static const String moreFacilitiesLabel = 'More facilities';
  static const String backLabel = 'Back';
  static const String closeLabel = 'Close';
  static const String showAllLabel = 'Show all';
  static const String selectedLabel = 'Selected';
  static const String directionsLabel = 'Directions';
  static const String openInMapsLabel = 'Open in Maps';
  static const String centerOnMapLabel = 'Center on map';
  static const String getDirectionsLabel = 'Get directions';
  static const String clearRouteLabel = 'Clear route';
  static const String startLabel = 'Start';
  static const String stopLabel = 'Stop';
  static const String myLocationLabel = 'My Location (refresh)';
  static const String zoomInLabel = 'Zoom In';
  static const String zoomOutLabel = 'Zoom Out';
  static const String exitFullscreenLabel = 'Exit full screen';
  static const String fullscreenLabel = 'Full screen';
  
  // Map settings
  static const double minMapZoom = 10.0;
  static const double maxMapZoom = 22.0;
  static const double defaultZoom = 10.0;
  static const double defaultLatitude = 12.0;
  static const double defaultLongitude = 38.0;
  static const int maxNativeZoom = 19;
  static const int tileSize = 256;
  static const int markerSize = 44;
  static const int smallMarkerSize = 32;
  static const int routeMarkerSize = 24;
  
  // Tile URL template
  static const String tileUrlTemplate = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const List<String> tileSubdomains = ['a', 'b', 'c'];
  
  // Route settings
  static const String routeApiUrl = 'https://router.project-osrm.org/route/v1/driving';
  static const int routeTimeoutSeconds = 60;
  static const int routeConnectorDots = 6;
  static const double routeStrokeWidth = 4.0;
  static const double connectorStrokeWidth = 2.0;
  
  // Location settings
  static const int locationTimeoutSeconds = 8;
  static const double poorAccuracyThreshold = 100.0;
  static const double goodAccuracyThreshold = 50.0;
  static const int locationListenSeconds = 6;
  static const double locationDistanceFilter = 5.0;
  
  // Animation durations
  static const int animationDurationMs = 300;
  static const int connectionRetryIntervalSeconds = 5;
  
  // Colors
  static const Color routeColor = Color(0xFF2196F3);
  static const Color connectorColor = Color(0xFFBDBDBD);
  static const Color locationColor = Colors.green;
  static const Color destinationColor = Colors.red;
  static const Color facilityColor = Colors.green;
  static const Color selectedFacilityColor = Colors.blueAccent;
  static const Color panelBackgroundColor = Color(0xFFEFF6FF);
  
  // Earth radius for distance calculations
  static const double earthRadiusKm = 6371.0;
}

/// Map location model
class MapLocation {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime? timestamp;
  final String? source;

  MapLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.timestamp,
    this.source,
  });

  factory MapLocation.fromLatLng(LatLng latLng, {double? accuracy, DateTime? timestamp, String? source}) {
    return MapLocation(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
      accuracy: accuracy,
      timestamp: timestamp,
      source: source,
    );
  }

  /// Convert to LatLng
  LatLng toLatLng() => LatLng(latitude, longitude);

  /// Check if location is valid
  bool get isValid => latitude.isFinite && longitude.isFinite;

  /// Get formatted coordinates
  String get formattedCoordinates => '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  /// Get accuracy string
  String get accuracyString => accuracy != null ? '${accuracy!.toStringAsFixed(0)} m accuracy' : '';

  /// Check if accuracy is poor
  bool get isPoorAccuracy => (accuracy ?? double.infinity) > MapConstants.poorAccuracyThreshold;

  /// Check if accuracy is good
  bool get isGoodAccuracy => (accuracy ?? double.infinity) <= MapConstants.goodAccuracyThreshold;
}

/// Facility marker model
class FacilityMarker {
  final String id;
  final String name;
  final MapLocation location;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final String? type;
  final bool isSelected;

  FacilityMarker({
    required this.id,
    required this.name,
    required this.location,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.type,
    this.isSelected = false,
  });

  factory FacilityMarker.fromJson(Map<String, dynamic> json) {
    final location = _extractLocation(json);
    
    return FacilityMarker(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Facility',
      location: location,
      address: json['address']?.toString(),
      phone: json['phone']?.toString() ?? json['phones']?.toString() ?? json['phone1']?.toString(),
      email: json['email']?.toString(),
      website: json['website']?.toString(),
      type: json['type']?.toString(),
    );
  }

  /// Extract location from JSON
  static MapLocation _extractLocation(Map<String, dynamic> json) {
    // Try direct latitude/longitude fields
    if (json['latitude'] != null && json['longitude'] != null) {
      final lat = _toNum(json['latitude']);
      final lon = _toNum(json['longitude']);
      if (lat != null && lon != null) {
        return MapLocation(latitude: lat.toDouble(), longitude: lon.toDouble());
      }
    }

    // Try lat/lng fields
    if (json['lat'] != null && json['lng'] != null) {
      final lat = _toNum(json['lat']);
      final lng = _toNum(json['lng']);
      if (lat != null && lng != null) {
        return MapLocation(latitude: lat.toDouble(), longitude: lng.toDouble());
      }
    }

    // Try location.coordinates
    final loc = json['location'];
    if (loc is Map && loc['coordinates'] is List) {
      final coords = loc['coordinates'] as List;
      if (coords.length >= 2) {
        final val1 = _toNum(coords[0]);
        final val2 = _toNum(coords[1]);
        if (val1 != null && val2 != null) {
          // Detect ordering: [lon, lat] vs [lat, lon]
          final firstLooksLikeLon = (val1.abs() > 90 && val1.abs() <= 180 && val2.abs() <= 90);
          if (firstLooksLikeLon) {
            return MapLocation(latitude: val2.toDouble(), longitude: val1.toDouble());
          }
          return MapLocation(latitude: val1.toDouble(), longitude: val2.toDouble());
        }
      }
    }

    // Try location.lat/lng
    if (loc is Map && loc['lat'] != null && loc['lng'] != null) {
      final lat = _toNum(loc['lat']);
      final lng = _toNum(loc['lng']);
      if (lat != null && lng != null) {
        return MapLocation(latitude: lat.toDouble(), longitude: lng.toDouble());
      }
    }

    throw Exception('Invalid location data');
  }

  /// Convert dynamic to number
  static num? _toNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }

  /// Get phone URL
  String get phoneUrl => phone != null ? 'tel:$phone' : '';

  /// Get email URL
  String get emailUrl => email != null ? 'mailto:$email' : '';

  /// Get website URL
  String get websiteUrl => website ?? '';

  /// Get Google Maps URL
  String get googleMapsUrl => 'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';

  /// Check if has coordinates
  bool get hasCoordinates => location.isValid;

  /// Check if has phone
  bool get hasPhone => phone?.isNotEmpty == true;

  /// Check if has email
  bool get hasEmail => email?.isNotEmpty == true;

  /// Check if has website
  bool get hasWebsite => website?.isNotEmpty == true;

  /// Get display address
  String get displayAddress => address?.isNotEmpty == true ? address! : 'No address available';

  /// Create copy with selection state
  FacilityMarker copyWith({bool? isSelected}) {
    return FacilityMarker(
      id: id,
      name: name,
      location: location,
      address: address,
      phone: phone,
      email: email,
      website: website,
      type: type,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

/// Route model
class RouteInfo {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
  final bool isLoading;

  RouteInfo({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    this.isLoading = false,
  });

  /// Create empty route
  factory RouteInfo.empty() {
    return RouteInfo(
      points: [],
      distanceMeters: 0.0,
      durationSeconds: 0.0,
    );
  }

  /// Create loading route
  factory RouteInfo.loading() {
    return RouteInfo(
      points: [],
      distanceMeters: 0.0,
      durationSeconds: 0.0,
      isLoading: true,
    );

  }

  /// Create straight line route
  factory RouteInfo.straightLine(LatLng from, LatLng to) {
    return RouteInfo(
      points: [from, to],
      distanceMeters: _calculateDistance(from, to) * 1000.0,
      durationSeconds: 0.0,
    );
  }

  /// Check if has route
  bool get hasRoute => points.isNotEmpty;

  /// Get distance in kilometers
  double get distanceKm => distanceMeters / 1000.0;

  /// Get formatted distance
  String get formattedDistance => '${distanceKm.toStringAsFixed(2)} km';

  /// Get formatted duration
  String get formattedDuration => durationSeconds > 0 
      ? 'Approx. ${(durationSeconds / 60).toStringAsFixed(0)} minutes'
      : '';

  /// Calculate distance between two points
  static double _calculateDistance(LatLng point1, LatLng point2) {
    const double R = MapConstants.earthRadiusKm;
    
    final double lat1 = point1.latitude * (3.14159265359 / 180.0);
    final double lon1 = point1.longitude * (3.14159265359 / 180.0);
    final double lat2 = point2.latitude * (3.14159265359 / 180.0);
    final double lon2 = point2.longitude * (3.14159265359 / 180.0);

    final double dlat = lat2 - lat1;
    final double dlon = lon2 - lon1;

    final double a = (3.14159265359 / 180.0) * (dlat / 2) * (3.14159265359 / 180.0) * (dlat / 2) +
        cos(lat1) * cos(lat2) * (3.14159265359 / 180.0) * (dlon / 2) * (3.14159265359 / 180.0) * (dlon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }
}

/// Map state model
class MapState {
  final MapLocation? currentLocation;
  final MapLocation? destination;
  final List<FacilityMarker> facilities;
  final RouteInfo route;
  final bool isLoading;
  final bool isLoadingRoute;
  final bool isTracking;
  final bool isFullScreen;
  final bool showOnlySelected;
  final FacilityMarker? selectedFacility;
  final ConnectionStatus connectionStatus;
  final double zoom;
  final LatLng? mapCenter;
  final double? remainingMeters;
  final int? nearestRouteIndex;

  MapState({
    this.currentLocation,
    this.destination,
    this.facilities = const [],
    this.route = const RouteInfo.empty(),
    this.isLoading = false,
    this.isLoadingRoute = false,
    this.isTracking = false,
    this.isFullScreen = false,
    this.showOnlySelected = false,
    this.selectedFacility,
    this.connectionStatus = ConnectionStatus.connecting,
    this.zoom = MapConstants.defaultZoom,
    this.mapCenter,
    this.remainingMeters,
    this.nearestRouteIndex,
  });

  MapState copyWith({
    MapLocation? currentLocation,
    MapLocation? destination,
    List<FacilityMarker>? facilities,
    RouteInfo? route,
    bool? isLoading,
    bool? isLoadingRoute,
    bool? isTracking,
    bool? isFullScreen,
    bool? showOnlySelected,
    FacilityMarker? selectedFacility,
    ConnectionStatus? connectionStatus,
    double? zoom,
    LatLng? mapCenter,
    double? remainingMeters,
    int? nearestRouteIndex,
  }) {
    return MapState(
      currentLocation: currentLocation ?? this.currentLocation,
      destination: destination ?? this.destination,
      facilities: facilities ?? this.facilities,
      route: route ?? this.route,
      isLoading: isLoading ?? this.isLoading,
      isLoadingRoute: isLoadingRoute ?? this.isLoadingRoute,
      isTracking: isTracking ?? this.isTracking,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      showOnlySelected: showOnlySelected ?? this.showOnlySelected,
      selectedFacility: selectedFacility ?? this.selectedFacility,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      zoom: zoom ?? this.zoom,
      mapCenter: mapCenter ?? this.mapCenter,
      remainingMeters: remainingMeters ?? this.remainingMeters,
      nearestRouteIndex: nearestRouteIndex ?? this.nearestRouteIndex,
    );
  }

  /// Check if has current location
  bool get hasCurrentLocation => currentLocation != null;

  /// Check if has destination
  bool get hasDestination => destination != null;

  /// Check if is directions mode
  bool get isDirectionsMode => hasCurrentLocation && hasDestination;

  /// Check if has facilities
  bool get hasFacilities => facilities.isNotEmpty;

  /// Check if has route
  bool get hasRoute => route.hasRoute;

  /// Get corrected current location
  MapLocation? get correctedCurrentLocation {
    if (currentLocation == null) return null;
    return _fixSwappedCoordinates(currentLocation!);
  }

  /// Get corrected destination
  MapLocation? get correctedDestination {
    if (destination == null) return null;
    return _fixSwappedCoordinates(destination!);
  }

  /// Fix swapped coordinates
  MapLocation _fixSwappedCoordinates(MapLocation location) {
    try {
      final lat = location.latitude;
      final lon = location.longitude;
      if ((lat.abs() > 90 && lon.abs() <= 90) ||
          (lat.abs() <= 90 && lon.abs() > 180)) {
        return MapLocation(
          latitude: lon,
          longitude: lat,
          accuracy: location.accuracy,
          timestamp: location.timestamp,
          source: location.source,
        );
      }
    } catch (_) {}
    return location;
  }
}

/// Connection status enum
enum ConnectionStatus {
  connecting,
  connected,
  disconnected,
}

/// Map bounds model
class MapBounds {
  final LatLng northEast;
  final LatLng southWest;

  MapBounds({
    required this.northEast,
    required this.southWest,
  });

  /// Create bounds from points
  factory MapBounds.fromPoints(List<LatLng> points) {
    if (points.isEmpty) {
      throw ArgumentError('Points list cannot be empty');
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLon = points.first.longitude;
    double maxLon = points.first.longitude;

    for (final point in points) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLon = math.min(minLon, point.longitude);
      maxLon = math.max(maxLon, point.longitude);
    }

    return MapBounds(
      northEast: LatLng(maxLat, maxLon),
      southWest: LatLng(minLat, minLon),
    );
  }

  /// Get center point
  LatLng get center => LatLng(
    (northEast.latitude + southWest.latitude) / 2,
    (northEast.longitude + southWest.longitude) / 2,
  );

  /// Get span
  LatLng get span => LatLng(
    northEast.latitude - southWest.latitude,
    northEast.longitude - southWest.longitude,
  );
}

/// Map marker type
enum MapMarkerType {
  currentLocation,
  destination,
  facility,
  routePoint,
}

/// Map marker model
class MapMarker {
  final String id;
  final LatLng point;
  final MapMarkerType type;
  final String? label;
  final Color color;
  final double size;
  final IconData? icon;
  final Map<String, dynamic>? data;

  MapMarker({
    required this.id,
    required this.point,
    required this.type,
    this.label,
    required this.color,
    this.size = MapConstants.markerSize,
    this.icon,
    this.data,
  });

  /// Create current location marker
  factory MapMarker.currentLocation(LatLng point, {double? accuracy}) {
    return MapMarker(
      id: 'current_location',
      point: point,
      type: MapMarkerType.currentLocation,
      color: MapConstants.locationColor,
      icon: Icons.person_pin_circle,
      label: accuracy != null ? 'Your location — ${accuracy.toStringAsFixed(0)} m accuracy' : 'Your location',
    );
  }

  /// Create destination marker
  factory MapMarker.destination(LatLng point) {
    return MapMarker(
      id: 'destination',
      point: point,
      type: MapMarkerType.destination,
      color: MapConstants.destinationColor,
      icon: Icons.location_on,
      label: 'Destination',
    );
  }

  /// Create facility marker
  factory MapMarker.facility(FacilityMarker facility) {
    return MapMarker(
      id: facility.id,
      point: facility.location.toLatLng(),
      type: MapMarkerType.facility,
      color: facility.isSelected ? MapConstants.selectedFacilityColor : MapConstants.facilityColor,
      size: facility.isSelected ? MapConstants.markerSize : MapConstants.smallMarkerSize,
      icon: Icons.medical_services,
      label: facility.name,
      data: facility.toJson(),
    );
  }

  /// Create route point marker
  factory MapMarker.routePoint(LatLng point, {String? label}) {
    return MapMarker(
      id: 'route_point_${point.latitude}_${point.longitude}',
      point: point,
      type: MapMarkerType.routePoint,
      color: MapConstants.routeColor,
      size: MapConstants.routeMarkerSize,
      label: label,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'point': {
        'latitude': point.latitude,
        'longitude': point.longitude,
      },
      'type': type.toString(),
      'label': label,
      'color': color.value,
      'size': size,
      'icon': icon?.toString(),
      'data': data,
    };
  }
}

/// Import required types
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
