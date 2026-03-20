import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import '../core/utils/tailwind_extensions.dart';
import '../widgets/branding_widgets.dart';

/// Map Page - Interactive map view
class MapPage extends StatefulWidget {
  final LatLng? from;
  final LatLng? to;
  
  const MapPage({
    super.key,
    this.from,
    this.to,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandingWidgets.buildBrandHeader(
        title: 'Map',
        subtitle: widget.from != null && widget.to != null 
            ? 'Navigation from ${widget.from} to ${widget.to}'
            : 'Interactive map view',
        showBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Center(
        child: BrandingWidgets.buildEmptyState(
          message: 'Map View',
          subtitle: 'Map functionality will be implemented here',
          icon: Icons.map,
        ),
      ),
    );
  }
}
