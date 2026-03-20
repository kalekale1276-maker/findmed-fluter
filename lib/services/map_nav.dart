import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class MapNav {
  MapNav._internal();
  static final MapNav instance = MapNav._internal();

  /// When non-null the AppShell should open the Map tab and show the route.
  final ValueNotifier<Map<String, LatLng>?> target = ValueNotifier(null);

  void open(LatLng from, LatLng to) {
    target.value = {'from': from, 'to': to};
  }

  void clear() => target.value = null;
}
