import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../widgets/app_drawer.dart';
import '../widgets/top_notification.dart';
import 'models/map_models.dart';
import 'services/map_services.dart';
import 'widgets/map_widgets.dart';

/// Custom UpscalingTileProvider for high zoom levels
class UpscalingTileProvider extends TileProvider {
  final int maxNativeZoom;
  
  UpscalingTileProvider({this.maxNativeZoom = 18});

  @override
  ImageProvider getImage(dynamic coords, dynamic options) {
    final int x = (coords.x as num).floor();
    final int y = (coords.y as num).floor();
    final double z = (coords.z as num).toDouble();

    int parentZoom = maxNativeZoom;
    int parentX = x;
    int parentY = y;

    if (z > maxNativeZoom) {
      final double scale = pow(2, z - maxNativeZoom).toDouble();
      parentX = (x / scale).floor();
      parentY = (y / scale).floor();
      parentZoom = maxNativeZoom;
    } else {
      parentZoom = z.floor();
    }

    String url = (options?.urlTemplate ?? MapConstants.tileUrlTemplate);
    final subs = (options?.subdomains ?? MapConstants.tileSubdomains);
    final s = subs[(parentX + parentY) % subs.length];

    url = url
        .replaceAll('{s}', s)
        .replaceAll('{z}', parentZoom.toString())
        .replaceAll('{x}', parentX.toString())
        .replaceAll('{y}', parentY.toString());

    return NetworkImage(url);
  }

  @override
  String getTileUrl(dynamic coords, dynamic options) {
    final int x = (coords.x as num).floor();
    final int y = (coords.y as num).floor();
    final double z = (coords.z as num).toDouble();

    int parentZoom = maxNativeZoom;
    int parentX = x;
    int parentY = y;

    if (z > maxNativeZoom) {
      final double scale = pow(2, z - maxNativeZoom).toDouble();
      parentX = (x / scale).floor();
      parentY = (y / scale).floor();
      parentZoom = maxNativeZoom;
    } else {
      parentZoom = z.floor();
    }

    String url = (options?.urlTemplate ?? MapConstants.tileUrlTemplate);
    final subs = (options?.subdomains ?? MapConstants.tileSubdomains);
    final s = subs[(parentX + parentY) % subs.length];

    return url
        .replaceAll('{s}', s)
        .replaceAll('{z}', parentZoom.toString())
        .replaceAll('{x}', parentX.toString())
        .replaceAll('{y}', parentY.toString());
  }
}

/// Map Page - Interactive map with facilities and routing
class MapPage extends StatefulWidget {
  final LatLng? from;
  final LatLng? to;
  const MapPage({super.key, this.from, this.to});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  // Controllers
  final MapController _mapController = MapController();
  
  // State
  MapState _state = const MapState();
  Timer? _connRetryTimer;
  StreamSubscription<MapLocation>? _trackingSub;
  
  // UI state
  OverlayEntry? _hoverOverlay;
  bool _showLeftPanel = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() async {
    // Initialize location and facilities
    await _ensureDeviceLocation();
    await _loadFacilities();
    await _checkConnection();
    
    // Handle initial from/to parameters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialRoute();
    });
  }

  Future<void> _ensureDeviceLocation() async {
    try {
      final location = await MapServices.getCurrentLocation();
      if (location != null) {
        setState(() {
          _state = _state.copyWith(currentLocation: location);
        });
        
        // Improve accuracy if poor
        if (location.isPoorAccuracy) {
          await _listenForBetterLocation();
        }
      }
    } catch (e) {
      debugPrint('Error getting device location: $e');
    }
  }

  Future<void> _listenForBetterLocation() async {
    final stream = MapServices.getLocationStream();
    late final StreamSubscription<MapLocation> sub;
    
    sub = stream.listen((location) {
      if (mounted) {
        setState(() {
          _state = _state.copyWith(currentLocation: location);
        });
      }
      
      if (location.isGoodAccuracy) {
        sub.cancel();
      }
    });
    
    // Cancel after timeout
    Future.delayed(const Duration(seconds: MapConstants.locationListenSeconds), () => sub.cancel());
  }

  Future<void> _loadFacilities() async {
    try {
      final facilities = await MapServices.fetchFacilities();
      if (mounted) {
        setState(() {
          _state = _state.copyWith(facilities: facilities);
        });
      }
    } catch (e) {
      debugPrint('Error loading facilities: $e');
    }
  }

  Future<void> _checkConnection() async {
    bool connected = await MapServices.checkConnectivity();
    
    if (!mounted) return;
    
    if (connected) {
      _connRetryTimer?.cancel();
      _connRetryTimer = null;
      setState(() {
        _state = _state.copyWith(connectionStatus: ConnectionStatus.connected);
      });
      
      // Fetch route if in directions mode
      if (_state.isDirectionsMode && !_state.hasRoute) {
        await _fetchRoute();
      }
    } else {
      setState(() {
        _state = _state.copyWith(connectionStatus: ConnectionStatus.disconnected);
      });
      
      if (_connRetryTimer == null || !_connRetryTimer!.isActive) {
        _connRetryTimer = Timer.periodic(
          const Duration(seconds: MapConstants.connectionRetryIntervalSeconds),
          (_) => _checkConnection(),
        );
      }
    }
  }

  void _handleInitialRoute() {
    final from = _state.correctedCurrentLocation?.toLatLng();
    final to = _state.correctedDestination?.toLatLng();
    
    if (from != null && to != null) {
      _fitToBounds(from, to);
      _fetchRoute();
    }
  }

  @override
  void dispose() {
    _connRetryTimer?.cancel();
    _trackingSub?.cancel();
    _hideHoverLabel();
    MapWidgets.clearContext();
    super.dispose();
  }

  // State management
  void _updateState(MapState newState) {
    setState(() {
      _state = newState;
    });
  }

  // Route operations
  Future<void> _fetchRoute() async {
    final from = _state.correctedCurrentLocation?.toLatLng();
    final to = _state.correctedDestination?.toLatLng();
    
    if (from == null || to == null) return;
    
    _updateState(_state.copyWith(isLoadingRoute: true));
    
    try {
      final route = await MapServices.fetchRoute(from, to);
      _updateState(_state.copyWith(route: route, isLoadingRoute: false));
    } catch (e) {
      debugPrint('Error fetching route: $e');
      _updateState(_state.copyWith(isLoadingRoute: false));
    }
  }

  void _clearRoute() {
    _updateState(_state.copyWith(
      route: RouteInfo.empty(),
      selectedFacility: null,
      showOnlySelected: false,
      remainingMeters: null,
      nearestRouteIndex: null,
    ));
  }

  // Facility operations
  void _selectFacilityAndRoute(FacilityMarker facility) {
    // Toggle selection
    if (_state.selectedFacility?.id == facility.id) {
      _clearRoute();
      return;
    }
    
    final updatedFacility = facility.copyWith(isSelected: true);
    _updateState(_state.copyWith(
      selectedFacility: updatedFacility,
      showOnlySelected: true,
    ));
    
    final from = _state.correctedCurrentLocation?.toLatLng();
    final to = facility.location.toLatLng();
    
    if (from != null) {
      _fitToBounds(from, to);
      _fetchRoute();
    } else {
      TopNotification.show(context, message: 'Could not get current location');
    }
  }

  void _showFacilityDetails(FacilityMarker facility) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => MapWidgets.buildFacilityDetailsSheet(
        facility: facility,
        onClose: () => Navigator.of(ctx).pop(),
        onGetDirections: () {
          Navigator.of(ctx).pop();
          _selectFacilityAndRoute(facility);
        },
        onOpenInMaps: () => MapServices.launchMapsSearch(facility.location.toLatLng()),
        onCenterOnMap: () {
          Navigator.of(ctx).pop();
          _mapController.move(facility.location.toLatLng(), _state.zoom);
        },
      ),
    );
  }

  void _showMoreFacilities() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => MapWidgets.buildFacilitiesListSheet(
        facilities: _state.facilities,
        onClose: () => Navigator.of(ctx).pop(),
        onCenterOnMap: (facility) {
          Navigator.of(ctx).pop();
          _mapController.move(facility.location.toLatLng(), _state.zoom);
        },
        onGetDirections: (facility) {
          Navigator.of(ctx).pop();
          _selectFacilityAndRoute(facility);
        },
        onOpenInMaps: (facility) => MapServices.launchMapsSearch(facility.location.toLatLng()),
      ),
    );
  }

  // Location tracking
  Future<void> _startLiveTracking() async {
    await _ensureDeviceLocation();
    if (_state.currentLocation == null) {
      TopNotification.show(context, message: 'Could not obtain device location');
      return;
    }
    
    _trackingSub?.cancel();
    _trackingSub = MapServices.getLocationStream().listen((location) {
      if (!mounted) return;
      
      _updateState(_state.copyWith(currentLocation: location));
      _updateRouteProgress();
      
      try {
        _mapController.move(location.toLatLng(), _state.zoom);
      } catch (_) {}
    }, onError: (e) {
      debugPrint('Tracking error: $e');
    });
    
    _updateState(_state.copyWith(isTracking: true));
    _updateRouteProgress();
  }

  void _stopLiveTracking() {
    _trackingSub?.cancel();
    _trackingSub = null;
    _updateState(_state.copyWith(
      isTracking: false,
      remainingMeters: null,
      nearestRouteIndex: null,
    ));
  }

  void _updateRouteProgress() {
    if (_state.route.points.isEmpty || _state.currentLocation == null) return;
    
    final result = MapServices.findClosestPointAndIndex(
      _state.currentLocation!.toLatLng(),
      _state.route.points,
    );
    
    final closest = result['point'] as LatLng;
    final index = result['index'] as int;
    
    final remaining = MapServices.calculateDistance(
      _state.currentLocation!.toLatLng(),
      closest,
    ) * 1000 + MapServices.calculateRemainingDistance(
      index,
      closest,
      _state.route.points,
    );
    
    _updateState(_state.copyWith(
      nearestRouteIndex: index,
      remainingMeters: remaining,
    ));
  }

  // Map operations
  void _fitToBounds(LatLng from, LatLng to) {
    final bounds = MapServices.getBoundsForPoints([from, to]);
    final center = bounds.center;
    final zoom = MapServices.calculateZoomForBounds(
      bounds,
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height,
    );
    
    _mapController.move(center, zoom);
  }

  void _centerOnLocation() {
    final location = _state.correctedCurrentLocation?.toLatLng();
    if (location != null) {
      _mapController.move(location, _state.zoom);
    }
  }

  void _openDestinationInMaps() {
    final destination = _state.correctedDestination?.toLatLng();
    if (destination != null) {
      MapServices.launchMapsSearch(destination);
    }
  }

  // UI helpers
  void _showHoverLabel(String text, Offset position) {
    _hideHoverLabel();
    final overlay = OverlayEntry(
      builder: (ctx) => MapWidgets.buildHoverLabel(
        text: text,
        position: position,
        onHide: _hideHoverLabel,
      ),
    );
    Overlay.of(context).insert(overlay);
    _hoverOverlay = overlay;
  }

  void _showFacilityHover(FacilityMarker facility, Offset position) {
    _hideHoverLabel();
    final overlay = OverlayEntry(
      builder: (ctx) => MapWidgets.buildFacilityHoverCard(
        facility: facility,
        position: position,
        onHide: _hideHoverLabel,
        onShowDetails: () => _showFacilityDetails(facility),
        onGetDirections: () => _selectFacilityAndRoute(facility),
      ),
    );
    Overlay.of(context).insert(overlay);
    _hoverOverlay = overlay;
  }

  void _hideHoverLabel() {
    try {
      _hoverOverlay?.remove();
    } catch (_) {}
    _hoverOverlay = null;
  }

  Future<void> _toggleFullscreen() async {
    final entering = !_state.isFullScreen;
    if (entering) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    _updateState(_state.copyWith(isFullScreen: entering));
  }

  // Build map markers
  List<Marker> _buildMarkers() {
    final markers = <Marker>[];
    
    // Current location marker
    final currentLocation = _state.correctedCurrentLocation?.toLatLng();
    if (currentLocation != null && !_state.showOnlySelected) {
      markers.add(Marker(
        width: MapConstants.markerSize,
        height: MapConstants.markerSize,
        point: currentLocation,
        child: MouseRegion(
          onEnter: (e) => _showHoverLabel(
            'Your location${_state.currentLocation?.accuracyString ?? ''}',
            e.position,
          ),
          onHover: (e) => _showHoverLabel(
            'Your location${_state.currentLocation?.accuracyString ?? ''}',
            e.position,
          ),
          onExit: (_) => _hideHoverLabel(),
          child: Tooltip(
            message: 'Your location${_state.currentLocation?.accuracyString ?? ''}',
            child: Icon(Icons.person_pin_circle, color: MapConstants.locationColor, size: 40),
          ),
        ),
      ));
    }
    
    // Destination marker
    final destination = _state.correctedDestination?.toLatLng();
    if (destination != null) {
      markers.add(Marker(
        width: MapConstants.markerSize,
        height: MapConstants.markerSize,
        point: destination,
        child: MouseRegion(
          onEnter: (e) => _showHoverLabel(
            'Destination: ${destination.latitude.toStringAsFixed(6)}, ${destination.longitude.toStringAsFixed(6)}',
            e.position,
          ),
          onHover: (e) => _showHoverLabel(
            'Destination: ${destination.latitude.toStringAsFixed(6)}, ${destination.longitude.toStringAsFixed(6)}',
            e.position,
          ),
          onExit: (_) => _hideHoverLabel(),
          child: Tooltip(
            message: 'Destination: ${destination.latitude.toStringAsFixed(6)}, ${destination.longitude.toStringAsFixed(6)}',
            child: Icon(Icons.location_on, color: MapConstants.destinationColor, size: 40),
          ),
        ),
      ));
    }
    
    // Facility markers
    final facilities = _state.showOnlySelected && _state.selectedFacility != null
        ? [_state.selectedFacility!]
        : _state.facilities;
    
    for (final facility in facilities) {
      if (!facility.hasCoordinates) continue;
      
      markers.add(Marker(
        width: MapConstants.markerSize,
        height: MapConstants.markerSize,
        point: facility.location.toLatLng(),
        child: MouseRegion(
          onEnter: (e) => _showFacilityHover(facility, e.position),
          onHover: (e) => _showFacilityHover(facility, e.position),
          onExit: (_) => _hideHoverLabel(),
          child: GestureDetector(
            onTap: () => _showFacilityDetails(facility),
            child: Tooltip(
              message: facility.name,
              child: Icon(
                Icons.medical_services,
                color: facility.isSelected ? MapConstants.selectedFacilityColor : MapConstants.facilityColor,
                size: facility.isSelected ? 40 : 32,
              ),
            ),
          ),
        ),
      ));
    }
    
    // Route midpoint marker
    if (_state.route.points.isNotEmpty) {
      final midIndex = (_state.route.points.length / 2).floor();
      final mid = _state.route.points[midIndex];
      
      markers.add(Marker(
        width: MapConstants.routeMarkerSize,
        height: MapConstants.routeMarkerSize,
        point: mid,
        child: MouseRegion(
          onEnter: (e) => _showHoverLabel(
            _state.route.formattedDistance,
            e.position,
          ),
          onHover: (e) => _showHoverLabel(
            _state.route.formattedDistance,
            e.position,
          ),
          onExit: (_) => _hideHoverLabel(),
          child: Container(
            decoration: BoxDecoration(
              color: MapConstants.routeColor.withOpacity(0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
              ],
            ),
            width: 12,
            height: 12,
          ),
        ),
      ));
    }
    
    return markers;
  }

  // Build polylines
  List<Polyline> _buildPolylines() {
    final polylines = <Polyline>[];
    
    if (_state.route.points.isNotEmpty) {
      polylines.add(Polyline(
        points: _state.route.points,
        strokeWidth: MapConstants.routeStrokeWidth,
        color: MapConstants.routeColor,
      ));
      
      // Add connectors if needed
      final currentLocation = _state.correctedCurrentLocation?.toLatLng();
      final destination = _state.correctedDestination?.toLatLng();
      
      if (destination != null) {
        final nearest = MapServices.findClosestPointOnPolyline(destination, _state.route.points);
        final dlat = (nearest.latitude - destination.latitude).abs();
        final dlon = (nearest.longitude - destination.longitude).abs();
        
        if (dlat > 0.00001 || dlon > 0.00001) {
          polylines.add(Polyline(
            points: [destination, nearest],
            strokeWidth: MapConstants.connectorStrokeWidth,
            color: MapConstants.connectorColor,
          ));
        }
      }
      
      if (currentLocation != null) {
        final nearest = MapServices.findClosestPointOnPolyline(currentLocation, _state.route.points);
        final dlat = (nearest.latitude - currentLocation.latitude).abs();
        final dlon = (nearest.longitude - currentLocation.longitude).abs();
        
        if (dlat > 0.00001 || dlon > 0.00001) {
          polylines.add(Polyline(
            points: [currentLocation, nearest],
            strokeWidth: MapConstants.connectorStrokeWidth,
            color: MapConstants.connectorColor,
          ));
        }
      }
    } else if (_state.isDirectionsMode && !_state.isLoadingRoute) {
      final from = _state.correctedCurrentLocation?.toLatLng();
      final to = _state.correctedDestination?.toLatLng();
      
      if (from != null && to != null) {
        polylines.add(Polyline(
          points: [from, to],
          strokeWidth: 2.0,
          color: const Color.fromRGBO(33, 150, 243, 0.6),
        ));
      }
    }
    
    return polylines;
  }

  @override
  Widget build(BuildContext context) {
    MapWidgets.setContext(context);
    
    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            children: [
              _buildHeader(),
              SizedBox(height: 8.h),
              _buildMapContent(),
              if (!_state.isDirectionsMode && !_state.isFullScreen) ...[
                SizedBox(height: 8.h),
                MapWidgets.buildZoomSlider(
                  currentZoom: _state.zoom,
                  onZoomChanged: (zoom) {
                    _updateState(_state.copyWith(zoom: zoom));
                    final center = _state.mapCenter ?? _state.correctedCurrentLocation?.toLatLng() ??
                                 _state.correctedDestination?.toLatLng() ??
                                 LatLng(MapConstants.defaultLatitude, MapConstants.defaultLongitude);
                    _mapController.move(center, zoom);
                  },
                ),
              ],
              if (_state.hasRoute && !_state.isLoadingRoute)
                MapWidgets.buildRouteInfoCard(
                  route: _state.route,
                  onClearRoute: _clearRoute,
                  onOpenDirections: () {
                    final from = _state.correctedCurrentLocation?.toLatLng();
                    final to = _state.correctedDestination?.toLatLng();
                    if (from != null && to != null) {
                      MapServices.launchDirections(from, to);
                    }
                  },
                  onStartTracking: _startLiveTracking,
                  onStopTracking: _stopLiveTracking,
                  isTracking: _state.isTracking,
                  remainingMeters: _state.remainingMeters,
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MapWidgets.buildBottomNavigationBar(
        isDirectionsMode: _state.isDirectionsMode,
        onBack: () => Navigator.of(context).pop(),
        onClose: () => Navigator.of(context).pop(),
        onShowMoreFacilities: _showMoreFacilities,
        onCenterOnLocation: _centerOnLocation,
        onOpenDestinationInMaps: _openDestinationInMaps,
        destination: _state.correctedDestination,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Builder(builder: (ctx) {
          final canPop = Navigator.of(ctx).canPop();
          if (canPop || _state.isDirectionsMode) {
            return IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                if (Navigator.of(ctx).canPop()) {
                  Navigator.of(ctx).pop();
                }
              },
            );
          }
          return const SizedBox.shrink();
        }),
        Expanded(
          child: Text(
            MapConstants.pageTitle,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.bug_report),
          onPressed: _showDebugDialog,
          tooltip: 'Debug coordinates',
        ),
      ],
    );
  }

  Widget _buildMapContent() {
    final mapHeight = _state.isFullScreen
        ? MediaQuery.of(context).size.height * 0.95
        : _state.isDirectionsMode
            ? MediaQuery.of(context).size.height * 0.85
            : MediaQuery.of(context).size.height * 0.35;

    return SizedBox(
      height: mapHeight,
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final dpr = MediaQuery.of(ctx).devicePixelRatio;
          
          return Stack(
            children: [
              RepaintBoundary(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _state.mapCenter ??
                        _state.correctedCurrentLocation?.toLatLng() ??
                        _state.correctedDestination?.toLatLng() ??
                        LatLng(MapConstants.defaultLatitude, MapConstants.defaultLongitude),
                    initialZoom: _state.zoom.clamp(MapConstants.minMapZoom, MapConstants.maxMapZoom),
                    minZoom: MapConstants.minMapZoom,
                    maxZoom: MapConstants.maxMapZoom,
                    onPositionChanged: (pos, hasGesture) {
                      _updateState(_state.copyWith(mapCenter: pos.center));
                      final z = pos.zoom.clamp(MapConstants.minMapZoom, MapConstants.maxMapZoom);
                      _updateState(_state.copyWith(zoom: z));
                    },
                    interactionOptions: InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      pinchZoomThreshold: 0.5,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: MapConstants.tileUrlTemplate,
                      subdomains: MapConstants.tileSubdomains,
                      userAgentPackageName: 'com.example.findmed',
                      tileSize: MapConstants.tileSize,
                      maxNativeZoom: MapConstants.maxNativeZoom,
                      retinaMode: dpr > 1.0,
                      errorImage: const NetworkImage('https://via.placeholder.com/256/eee/ccc?text=Error'),
                      tileProvider: UpscalingTileProvider(maxNativeZoom: MapConstants.maxNativeZoom),
                    ),
                    if (_buildPolylines().isNotEmpty)
                      PolylineLayer(polylines: _buildPolylines()),
                    if (_buildMarkers().isNotEmpty)
                      MarkerLayer(markers: _buildMarkers()),
                  ],
                ),
              ),
              
              // Fullscreen toggle
              Positioned(
                right: 8.w,
                top: 56.h,
                child: MapWidgets.buildFullscreenToggle(
                  isFullScreen: _state.isFullScreen,
                  onPressed: _toggleFullscreen,
                ),
              ),
              
              // Zoom controls
              Positioned(
                right: 8.w,
                bottom: 8.h,
                child: MapWidgets.buildZoomControls(
                  currentZoom: _state.zoom,
                  onZoomChanged: (zoom) {
                    _updateState(_state.copyWith(zoom: zoom));
                  },
                  mapCenter: _state.mapCenter ?? LatLng(MapConstants.defaultLatitude, MapConstants.defaultLongitude),
                  mapController: _mapController,
                ),
              ),
              
              // Left panel
              if (_showLeftPanel && !_state.isFullScreen)
                Positioned(
                  left: 8.w,
                  top: 120.h,
                  bottom: 8.h,
                  width: MediaQuery.of(context).size.width * 0.38 < 360
                      ? MediaQuery.of(context).size.width * 0.38
                      : 360,
                  child: MapWidgets.buildLeftPanel(
                    currentLocation: _state.correctedCurrentLocation,
                    onShare: () {
                      // Implement share functionality
                    },
                  ),
                ),
              
              // Route loading overlay
              if (_state.isLoadingRoute)
                MapWidgets.buildRouteLoadingOverlay(),
              
              // Selected facility overlay
              if (_state.selectedFacility != null && _state.showOnlySelected)
                Positioned(
                  right: 12.w,
                  top: 12.h,
                  child: MapWidgets.buildSelectedFacilityOverlay(
                    facility: _state.selectedFacility!,
                    route: _state.route,
                    onShowAll: _clearRoute,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showDebugDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Coordinates Debug'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Current Location:'),
              Text('Raw: ${widget.from?.latitude}, ${widget.from?.longitude}'),
              Text('Corrected: ${_state.correctedCurrentLocation?.latitude}, ${_state.correctedCurrentLocation?.longitude}'),
              const SizedBox(height: 12),
              const Text('Facility Location:'),
              Text('Raw: ${widget.to?.latitude}, ${widget.to?.longitude}'),
              Text('Corrected: ${_state.correctedDestination?.latitude}, ${_state.correctedDestination?.longitude}'),
              const SizedBox(height: 12),
              if (_state.correctedCurrentLocation != null && _state.correctedDestination != null) ...[
                const Text('Calculations:'),
                Text('Haversine distance: ${MapServices.calculateDistance(_state.correctedCurrentLocation!.toLatLng(), _state.correctedDestination!.toLatLng()).toStringAsFixed(2)} km'),
                if (_state.route.distanceMeters > 0)
                  Text('Route distance: ${(_state.route.distanceMeters / 1000).toStringAsFixed(2)} km'),
              ],
              const SizedBox(height: 12),
              const Text('Expected facility: 12.5875, 37.4413'),
              const Text('Expected current: 9.0245, 38.7485'),
              const Text('Expected distance: ~421 km'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
