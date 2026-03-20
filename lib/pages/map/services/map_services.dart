import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../models/map_models.dart';

/// Services for map functionality
class MapServices {
  static const List<String> _backendBases = [
    'https://findmed-backend-1.onrender.com',
  ];

  static const String _facilitiesEndpoint = '/api/facilities';
  static const String _routeApiUrl = 'https://router.project-osrm.org/route/v1/driving';

  /// Fetch facilities from backend
  static Future<List<FacilityMarker>> fetchFacilities() async {
    for (final base in _backendBases) {
      try {
        final baseUri = Uri.tryParse(base);
        if (baseUri == null || baseUri.host.isEmpty) continue;
        
        final uri = baseUri.replace(
          path: '${baseUri.path.replaceAll(RegExp(r'/$'), '')}$_facilitiesEndpoint',
        );
        
        final response = await http.get(uri).timeout(const Duration(seconds: 60));
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as List<dynamic>;
          return data
              .map((e) => FacilityMarker.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
      } catch (e) {
        debugPrint('Error fetching facilities from $base: $e');
        continue;
      }
    }
    
    return [];
  }

  /// Get current device location
  static Future<MapLocation?> getCurrentLocation() async {
    try {
      LocationPermission status = await Geolocator.checkPermission();
      if (status == LocationPermission.denied) {
        status = await Geolocator.requestPermission();
      }
      
      if (status == LocationPermission.deniedForever || status == LocationPermission.denied) {
        return null;
      }

      // Try to get high-accuracy position
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: MapConstants.locationTimeoutSeconds),
        );
      } catch (_) {
        // Fallback to last known position
        position = await Geolocator.getLastKnownPosition();
      }

      if (position != null) {
        return MapLocation.fromLatLng(
          LatLng(position.latitude, position.longitude),
          accuracy: position.accuracy,
          timestamp: position.timestamp.toLocal(),
          source: 'device',
        );
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
    }
    
    return null;
  }

  /// Start location tracking stream
  static Stream<MapLocation> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: MapConstants.locationDistanceFilter,
      ),
    ).map((position) => MapLocation.fromLatLng(
      LatLng(position.latitude, position.longitude),
      accuracy: position.accuracy,
      timestamp: position.timestamp.toLocal(),
      source: 'device',
    ));
  }

  /// Fetch route between two points
  static Future<RouteInfo> fetchRoute(LatLng from, LatLng to) async {
    try {
      final url = Uri.parse(
        '$_routeApiUrl/${from.longitude},${from.latitude};${to.longitude},${to.latitude}?overview=full&geometries=geojson'
      );
      
      final response = await http.get(url).timeout(const Duration(seconds: MapConstants.routeTimeoutSeconds));
      
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
        final routes = jsonBody['routes'] as List<dynamic>?;
        
        if (routes != null && routes.isNotEmpty) {
          final route = routes[0] as Map<String, dynamic>;
          
          final distance = (route['distance'] is num) 
              ? (route['distance'] as num).toDouble() 
              : 0.0;
          
          final duration = (route['duration'] is num) 
              ? (route['duration'] as num).toDouble() 
              : 0.0;
          
          final geometry = route['geometry'] as Map<String, dynamic>?;
          final points = <LatLng>[];
          
          if (geometry != null && geometry['coordinates'] is List) {
            final coords = geometry['coordinates'] as List;
            points.addAll(coords.map((c) {
              final lon = (c[0] as num).toDouble();
              final lat = (c[1] as num).toDouble();
              return LatLng(lat, lon);
            }));
          }
          
          return RouteInfo(
            points: points,
            distanceMeters: distance,
            durationSeconds: duration,
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
    }
    
    // Fallback to straight line
    return RouteInfo.straightLine(from, to);
  }

  /// Check internet connectivity
  static Future<bool> checkConnectivity() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        return false;
      }
      
      // Test actual connectivity
      final response = await http.get(
        Uri.parse('https://www.google.com/generate_204')
      ).timeout(const Duration(seconds: 60));
      
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }

  /// Launch phone call
  static Future<bool> launchPhoneCall(String phoneNumber) async {
    try {
      final url = 'tel:$phoneNumber';
      return await launchUrlString(url);
    } catch (e) {
      debugPrint('Error launching phone call: $e');
      return false;
    }
  }

  /// Launch email
  static Future<bool> launchEmail(String emailAddress) async {
    try {
      final url = 'mailto:$emailAddress';
      return await launchUrlString(url);
    } catch (e) {
      debugPrint('Error launching email: $e');
      return false;
    }
  }

  /// Launch website
  static Future<bool> launchWebsite(String url) async {
    try {
      return await launchUrlString(url);
    } catch (e) {
      debugPrint('Error launching website: $e');
      return false;
    }
  }

  /// Launch Google Maps with directions
  static Future<bool> launchDirections(LatLng from, LatLng to) async {
    try {
      final url = 'https://www.google.com/maps/dir/?api=1&origin=${from.latitude},${from.longitude}&destination=${to.latitude},${to.longitude}&travelmode=driving';
      return await launchUrlString(url);
    } catch (e) {
      debugPrint('Error launching directions: $e');
      return false;
    }
  }

  /// Launch Google Maps search for location
  static Future<bool> launchMapsSearch(LatLng location) async {
    try {
      final url = 'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
      return await launchUrlString(url);
    } catch (e) {
      debugPrint('Error launching maps search: $e');
      return false;
    }
  }

  /// Calculate distance between two points
  static double calculateDistance(LatLng point1, LatLng point2) {
    const double R = MapConstants.earthRadiusKm;
    
    final double lat1 = point1.latitude * (pi / 180.0);
    final double lon1 = point1.longitude * (pi / 180.0);
    final double lat2 = point2.latitude * (pi / 180.0);
    final double lon2 = point2.longitude * (pi / 180.0);

    final double dlat = lat2 - lat1;
    final double dlon = lon2 - lon1;

    final double a = sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  /// Find closest point on polyline
  static LatLng findClosestPointOnPolyline(LatLng point, List<LatLng> polyline) {
    if (polyline.isEmpty) return point;
    
    double bestDist = double.infinity;
    LatLng bestPoint = polyline.first;

    for (var i = 0; i < polyline.length - 1; i++) {
      final a = polyline[i];
      final b = polyline[i + 1];
      
      // Treat lat/lng as Cartesian for projection
      final double vx = b.longitude - a.longitude;
      final double vy = b.latitude - a.latitude;
      final double wx = point.longitude - a.longitude;
      final double wy = point.latitude - a.latitude;
      
      final double segLen2 = vx * vx + vy * vy;
      double t = 0.0;
      
      if (segLen2 > 0) {
        t = ((wx * vx) + (wy * vy)) / segLen2;
      }
      
      if (t < 0) t = 0;
      if (t > 1) t = 1;
      
      final double projLon = a.longitude + t * vx;
      final double projLat = a.latitude + t * vy;
      
      final double d2 = (projLat - point.latitude) * (projLat - point.latitude) +
          (projLon - point.longitude) * (projLon - point.longitude);
      
      if (d2 < bestDist) {
        bestDist = d2;
        bestPoint = LatLng(projLat, projLon);
      }
    }
    
    return bestPoint;
  }

  /// Find closest point and index on polyline
  static Map<String, dynamic> findClosestPointAndIndex(LatLng point, List<LatLng> polyline) {
    if (polyline.isEmpty) return {'point': point, 'index': 0};
    
    double bestDist = double.infinity;
    LatLng bestPoint = polyline.first;
    int bestIndex = 0;

    for (var i = 0; i < polyline.length - 1; i++) {
      final a = polyline[i];
      final b = polyline[i + 1];
      
      final double vx = b.longitude - a.longitude;
      final double vy = b.latitude - a.latitude;
      final double wx = point.longitude - a.longitude;
      final double wy = point.latitude - a.latitude;
      
      final double segLen2 = vx * vx + vy * vy;
      double t = 0.0;
      
      if (segLen2 > 0) {
        t = ((wx * vx) + (wy * vy)) / segLen2;
      }
      
      if (t < 0) t = 0;
      if (t > 1) t = 1;
      
      final double projLon = a.longitude + t * vx;
      final double projLat = a.latitude + t * vy;
      
      final double d2 = (projLat - point.latitude) * (projLat - point.latitude) +
          (projLon - point.longitude) * (projLon - point.longitude);
      
      if (d2 < bestDist) {
        bestDist = d2;
        bestPoint = LatLng(projLat, projLon);
        bestIndex = i;
      }
    }
    
    return {'point': bestPoint, 'index': bestIndex};
  }

  /// Calculate remaining distance from index
  static double calculateRemainingDistance(int index, LatLng closestPoint, List<LatLng> routePoints) {
    if (routePoints.isEmpty) return 0.0;
    
    double remaining = 0.0;
    
    // Distance from closest point to next point
    final nextIndex = index + 1;
    if (nextIndex < routePoints.length) {
      remaining += calculateDistance(closestPoint, routePoints[nextIndex]);
      
      for (var i = nextIndex; i < routePoints.length - 1; i++) {
        remaining += calculateDistance(routePoints[i], routePoints[i + 1]);
      }
    }
    
    return remaining;
  }

  /// Calculate zoom level to fit bounds
  static double calculateZoomForBounds(MapBounds bounds, double mapWidth, double mapHeight) {
    final double latDiff = bounds.northEast.latitude - bounds.southWest.latitude;
    final double lngDiff = bounds.northEast.longitude - bounds.southWest.longitude;
    
    // Rough estimation - in production, use proper mercator projection calculations
    if (latDiff > 10 || lngDiff > 10) {
      return 6.0;
    } else if (latDiff > 5 || lngDiff > 5) {
      return 8.0;
    } else if (latDiff > 1 || lngDiff > 1) {
      return 10.0;
    } else if (latDiff > 0.2 || lngDiff > 0.2) {
      return 13.0;
    } else {
      return 15.0;
    }
  }

  /// Fix swapped coordinates
  static MapLocation fixSwappedCoordinates(MapLocation location) {
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

  /// Validate coordinates
  static bool isValidCoordinates(double latitude, double longitude) {
    return latitude.isFinite && longitude.isFinite &&
           latitude >= -90 && latitude <= 90 &&
           longitude >= -180 && longitude <= 180;
  }

  /// Format distance
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
  }

  /// Format duration
  static String formatDuration(double seconds) {
    if (seconds < 60) {
      return '${seconds.toStringAsFixed(0)} sec';
    } else if (seconds < 3600) {
      return '${(seconds / 60).toStringAsFixed(0)} min';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = ((seconds % 3600) / 60).round();
      return '${hours}h ${minutes}min';
    }
  }

  /// Get map bounds for points
  static MapBounds getBoundsForPoints(List<LatLng> points) {
    if (points.isEmpty) {
      return MapBounds(
        northEast: LatLng(MapConstants.defaultLatitude, MapConstants.defaultLongitude),
        southWest: LatLng(MapConstants.defaultLatitude, MapConstants.defaultLongitude),
      );
    }
    
    return MapBounds.fromPoints(points);
  }

  /// Generate connector markers between two points
  static List<LatLng> generateConnectorMarkers(LatLng from, LatLng to, {int count = 6}) {
    final markers = <LatLng>[];
    
    for (var i = 1; i <= count; i++) {
      final double t = i / (count + 1);
      final double lat = from.latitude + (to.latitude - from.latitude) * t;
      final double lon = from.longitude + (to.longitude - from.longitude) * t;
      markers.add(LatLng(lat, lon));
    }
    
    return markers;
  }

  /// Get facility statistics
  static Map<String, dynamic> getFacilityStatistics(List<FacilityMarker> facilities) {
    final Map<String, int> typeCounts = {};
    int totalWithPhone = 0;
    int totalWithEmail = 0;
    int totalWithWebsite = 0;
    
    for (final facility in facilities) {
      // Count by type
      final type = facility.type ?? 'unknown';
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
      
      // Count contact info
      if (facility.hasPhone) totalWithPhone++;
      if (facility.hasEmail) totalWithEmail++;
      if (facility.hasWebsite) totalWithWebsite++;
    }
    
    return {
      'total': facilities.length,
      'typeCounts': typeCounts,
      'withPhone': totalWithPhone,
      'withEmail': totalWithEmail,
      'withWebsite': totalWithWebsite,
    };
  }

  /// Search facilities by name
  static List<FacilityMarker> searchFacilities(List<FacilityMarker> facilities, String query) {
    if (query.trim().isEmpty) return facilities;
    
    final lowerQuery = query.toLowerCase();
    return facilities.where((facility) {
      return facility.name.toLowerCase().contains(lowerQuery) ||
             (facility.address?.toLowerCase().contains(lowerQuery) ?? false) ||
             (facility.type?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// Filter facilities by type
  static List<FacilityMarker> filterFacilitiesByType(List<FacilityMarker> facilities, String? type) {
    if (type == null || type.isEmpty) return facilities;
    
    return facilities.where((facility) => facility.type == type).toList();
  }

  /// Get nearest facilities to a point
  static List<FacilityMarker> getNearestFacilities(
    List<FacilityMarker> facilities,
    LatLng point, {
    int maxCount = 10,
    double maxDistanceKm = 50.0,
  }) {
    final facilitiesWithDistance = facilities.map((facility) {
      final distance = calculateDistance(point, facility.location.toLatLng());
      return MapEntry(facility, distance);
    }).toList();
    
    // Sort by distance and filter
    facilitiesWithDistance.sort((a, b) => a.value.compareTo(b.value));
    
    return facilitiesWithDistance
        .where((entry) => entry.value <= maxDistanceKm)
        .take(maxCount)
        .map((entry) => entry.key)
        .toList();
  }

  /// Validate facility data
  static bool validateFacilityData(Map<String, dynamic> data) {
    try {
      // Check required fields
      if (!data.containsKey('name') || data['name'].toString().trim().isEmpty) {
        return false;
      }
      
      // Check if location can be extracted
      final location = FacilityMarker._extractLocation(data);
      return location.isValid;
    } catch (e) {
      debugPrint('Error validating facility data: $e');
      return false;
    }
  }

  /// Export facilities to JSON
  static String exportFacilitiesToJson(List<FacilityMarker> facilities) {
    final data = facilities.map((f) => f.toJson()).toList();
    return jsonEncode({
      'facilities': data,
      'exported_at': DateTime.now().toIso8601String(),
      'total': facilities.length,
    });
  }

  /// Import facilities from JSON
  static List<FacilityMarker> importFacilitiesFromJson(String jsonString) {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final facilities = data['facilities'] as List<dynamic>?;
      
      if (facilities != null) {
        return facilities
            .map((f) => FacilityMarker.fromJson(Map<String, dynamic>.from(f as Map)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error importing facilities: $e');
    }
    
    return [];
  }
}
