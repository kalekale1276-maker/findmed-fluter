import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/utils/tailwind_extensions.dart';
import '../models/map_models.dart';
import '../services/map_services.dart';

/// UI components for map functionality
class MapWidgets {
  /// Build map loading indicator
  static Widget buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Build route loading overlay
  static Widget buildRouteLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  /// Build zoom controls
  static Widget buildZoomControls({
    required double currentZoom,
    required ValueChanged<double> onZoomChanged,
    required LatLng mapCenter,
    required MapController mapController,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8.r,
            spreadRadius: 1.r,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.add, size: 20.w),
            color: Colors.black87,
            onPressed: () {
              final newZoom = (currentZoom + 1.0)
                  .clamp(MapConstants.minMapZoom, MapConstants.maxMapZoom)
                  .toDouble();
              mapController.move(mapCenter, newZoom);
              onZoomChanged(newZoom);
            },
            tooltip: MapConstants.zoomInLabel,
          ),
          Container(
            width: 36.w,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              currentZoom.toStringAsFixed(1),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.remove, size: 20.w),
            color: Colors.black87,
            onPressed: () {
              final newZoom = (currentZoom - 1.0)
                  .clamp(MapConstants.minMapZoom, MapConstants.maxMapZoom)
                  .toDouble();
              mapController.move(mapCenter, newZoom);
              onZoomChanged(newZoom);
            },
            tooltip: MapConstants.zoomOutLabel,
          ),
          SizedBox(height: 4.h),
          Divider(
            color: Colors.grey[300],
            height: 1.h,
            indent: 8.w,
            endIndent: 8.w,
          ),
          SizedBox(height: 4.h),
          IconButton(
            icon: Icon(Icons.my_location, size: 20.w),
            color: Colors.black87,
            onPressed: () async {
              // This would need to be handled by the parent
              // For now, just show the tooltip
            },
            tooltip: MapConstants.myLocationLabel,
          ),
        ],
      ),
    );
  }

  /// Build fullscreen toggle button
  static Widget buildFullscreenToggle({
    required bool isFullScreen,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(
        isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
        color: Colors.black87,
      ),
      onPressed: onPressed,
      tooltip: isFullScreen ? MapConstants.exitFullscreenLabel : MapConstants.fullscreenLabel,
    );
  }

  /// Build zoom slider
  static Widget buildZoomSlider({
    required double currentZoom,
    required ValueChanged<double> onZoomChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.r,
            spreadRadius: 1.r,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Icon(Icons.zoom_out, size: 18.w),
          Expanded(
            child: Slider(
              value: currentZoom.clamp(MapConstants.minMapZoom, MapConstants.maxMapZoom).toDouble(),
              min: MapConstants.minMapZoom,
              max: MapConstants.maxMapZoom,
              divisions: ((MapConstants.maxMapZoom - MapConstants.minMapZoom) * 2).toInt(),
              label: currentZoom.toStringAsFixed(1),
              onChanged: onZoomChanged,
            ),
          ),
          Icon(Icons.zoom_in, size: 18.w),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              '${currentZoom.toStringAsFixed(1)}x',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build route information card
  static Widget buildRouteInfoCard({
    required RouteInfo route,
    required VoidCallback onClearRoute,
    required VoidCallback onOpenDirections,
    required VoidCallback onStartTracking,
    required VoidCallback onStopTracking,
    required bool isTracking,
    double? remainingMeters,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.r,
            spreadRadius: 1.r,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.route, color: Colors.blue, size: 24.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.formattedDistance,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (route.durationSeconds > 0)
                  Text(
                    route.formattedDuration,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.directions, color: Colors.blue, size: 20.w),
            onPressed: onOpenDirections,
            tooltip: MapConstants.openInMapsLabel,
          ),
          SizedBox(width: 8.w),
          // Live tracking controls
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(44.w, 36.h),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                ),
                onPressed: isTracking ? onStopTracking : onStartTracking,
                icon: Icon(isTracking ? Icons.stop : Icons.play_arrow, size: 16.w),
                label: Text(isTracking ? MapConstants.stopLabel : MapConstants.startLabel),
              ),
              SizedBox(width: 8.w),
              if (remainingMeters != null)
                Text(
                  MapServices.formatDistance(remainingMeters),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              SizedBox(width: 8.w),
              IconButton(
                icon: Icon(Icons.clear, color: Colors.grey, size: 20.w),
                onPressed: onClearRoute,
                tooltip: MapConstants.clearRouteLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build facility details sheet
  static Widget buildFacilityDetailsSheet({
    required FacilityMarker facility,
    required VoidCallback onClose,
    required VoidCallback onGetDirections,
    required VoidCallback onOpenInMaps,
    required VoidCallback onCenterOnMap,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  facility.name,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: Icon(Icons.close, size: 20.w),
              ),
            ],
          ),
          if (facility.address != null) ...[
            SizedBox(height: 8.h),
            Text(facility.address!),
          ],
          if (facility.hasPhone) ...[
            SizedBox(height: 8.h),
            ListTile(
              leading: Icon(Icons.phone, size: 20.w),
              title: Text(facility.phone!),
              trailing: TextButton(
                onPressed: () => MapServices.launchPhoneCall(facility.phone!),
                child: const Text('Call'),
              ),
            ),
          ],
          if (facility.hasEmail) ...[
            ListTile(
              leading: Icon(Icons.email, size: 20.w),
              title: Text(facility.email!),
              trailing: TextButton(
                onPressed: () => MapServices.launchEmail(facility.email!),
                child: const Text('Email'),
              ),
            ),
          ],
          if (facility.hasWebsite) ...[
            ListTile(
              leading: Icon(Icons.link, size: 20.w),
              title: Text(facility.website!),
              trailing: TextButton(
                onPressed: () => MapServices.launchWebsite(facility.website!),
                child: const Text('Open'),
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onGetDirections,
                  icon: Icon(Icons.directions, size: 18.w),
                  label: Text(MapConstants.directionsLabel),
                ),
              ),
              SizedBox(width: 8.w),
              OutlinedButton.icon(
                onPressed: onOpenInMaps,
                icon: Icon(Icons.map, size: 18.w),
                label: Text(MapConstants.openInMapsLabel),
              ),
            ],
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  /// Build facilities list sheet
  static Widget buildFacilitiesListSheet({
    required List<FacilityMarker> facilities,
    required VoidCallback onClose,
    required Function(FacilityMarker) onCenterOnMap,
    required Function(FacilityMarker) onGetDirections,
    required Function(FacilityMarker) onOpenInMaps,
  }) {
    return Container(
      height: MediaQuery.of(Get.context!).size.height * 0.75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    MapConstants.facilitiesLabel,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: Icon(Icons.close, size: 20.w),
                ),
              ],
            ),
          ),
          Divider(height: 1.h),
          Expanded(
            child: ListView.separated(
              itemCount: facilities.length,
              separatorBuilder: (_, __) => Divider(height: 1.h),
              itemBuilder: (_, i) {
                final facility = facilities[i];
                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(facility.name),
                      SizedBox(height: 4.h),
                      Text(
                        'ID: ${facility.id}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    facility.hasCoordinates
                        ? facility.location.formattedCoordinates
                        : 'No coordinates',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.center_focus_strong, size: 20.w),
                        onPressed: facility.hasCoordinates
                            ? () => onCenterOnMap(facility)
                            : null,
                        tooltip: MapConstants.centerOnMapLabel,
                      ),
                      IconButton(
                        icon: Icon(Icons.directions, size: 20.w),
                        onPressed: facility.hasCoordinates
                            ? () => onGetDirections(facility)
                            : null,
                        tooltip: MapConstants.getDirectionsLabel,
                      ),
                      IconButton(
                        icon: Icon(Icons.map, size: 20.w),
                        onPressed: () => onOpenInMaps(facility),
                        tooltip: MapConstants.openInMapsLabel,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build left panel
  static Widget buildLeftPanel({
    required MapLocation? currentLocation,
    required VoidCallback onShare,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      elevation: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              color: MapConstants.panelBackgroundColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentLocation?.formattedCoordinates ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6.h),
              ],
            ),
          ),
          Divider(height: 1.h),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(12.w),
              children: [
                Text(
                  'HCQR+2G4 Gondar',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(MapConstants.addPlaceLabel),
                SizedBox(height: 8.h),
                Text(MapConstants.addBusinessLabel),
                SizedBox(height: 8.h),
                Text(MapConstants.addLabelLabel),
                SizedBox(height: 16.h),
                ElevatedButton.icon(
                  onPressed: onShare,
                  icon: Icon(Icons.share, size: 18.w),
                  label: Text(MapConstants.shareLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build selected facility overlay
  static Widget buildSelectedFacilityOverlay({
    required FacilityMarker facility,
    required RouteInfo route,
    required VoidCallback onShowAll,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    facility.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    route.formattedDistance,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            TextButton(
              onPressed: onShowAll,
              child: const Text(MapConstants.showAllLabel),
            ),
          ],
        ),
      ),
    );
  }

  /// Build hover label
  static Widget buildHoverLabel({
    required String text,
    required Offset position,
    required VoidCallback onHide,
  }) {
    final screen = MediaQuery.of(Get.context!).size;
    final left = (position.dx + 12).clamp(8.0, screen.width - 160.0);
    final top = (position.dy + 12).clamp(8.0, screen.height - 48.0);

    return Positioned(
      left: left,
      top: top,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: onHide,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 6.r,
                ),
              ],
            ),
            child: DefaultTextStyle(
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
              ),
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build facility hover card
  static Widget buildFacilityHoverCard({
    required FacilityMarker facility,
    required Offset position,
    required VoidCallback onHide,
    required VoidCallback onShowDetails,
    required VoidCallback onGetDirections,
  }) {
    final screen = MediaQuery.of(Get.context!).size;
    final left = (position.dx + 12).clamp(8.0, screen.width - 220.0);
    final top = (position.dy + 12).clamp(8.0, screen.height - 140.0);

    return Positioned(
      left: left,
      top: top,
      child: Material(
        child: Container(
          width: 200.w,
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8.r,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                facility.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6.h),
              Text(
                facility.displayAddress,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      onHide();
                      onShowDetails();
                    },
                    child: const Text('More'),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.directions, size: 20.w),
                    onPressed: () {
                      onHide();
                      onGetDirections();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build bottom navigation bar
  static Widget buildBottomNavigationBar({
    required bool isDirectionsMode,
    required VoidCallback onBack,
    required VoidCallback onClose,
    required VoidCallback onShowMoreFacilities,
    required VoidCallback onCenterOnLocation,
    required VoidCallback onOpenDestinationInMaps,
    required MapLocation? destination,
  }) {
    return BottomAppBar(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: isDirectionsMode
            ? Row(
                children: [
                  TextButton.icon(
                    onPressed: onBack,
                    icon: Icon(Icons.arrow_back, size: 18.w),
                    label: Text(MapConstants.backLabel),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onClose,
                    icon: Icon(Icons.close, size: 18.w),
                    label: Text(MapConstants.closeLabel),
                  ),
                ],
              )
            : Row(
                children: [
                  TextButton.icon(
                    onPressed: onShowMoreFacilities,
                    icon: Icon(Icons.more_horiz, size: 18.w),
                    label: Text(MapConstants.moreFacilitiesLabel),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: MapConstants.myLocationLabel,
                    onPressed: onCenterOnLocation,
                    icon: Icon(Icons.my_location, size: 18.w),
                  ),
                  IconButton(
                    tooltip: MapConstants.openInMapsLabel,
                    onPressed: destination != null ? onOpenDestinationInMaps : null,
                    icon: Icon(Icons.map, size: 18.w),
                  ),
                ],
              ),
      ),
    );
  }

  /// Build spacing
  static Widget buildSpacing({double height = 16}) {
    return SizedBox(height: height.h);
  }

  /// Build section divider
  static Widget buildSectionDivider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.h),
      height: 1.h,
      color: Get.context!.isDarkMode ? TailwindColors.gray700 : TailwindColors.gray200,
    );
  }
}

/// Helper class to get context
class Get {
  static BuildContext? _context;
  
  static BuildContext get context {
    if (_context == null) {
      throw Exception('Context not set. Call setContext() first.');
    }
    return _context!;
  }
  
  static void setContext(BuildContext context) {
    _context = context;
  }
  
  static void clearContext() {
    _context = null;
  }
}
