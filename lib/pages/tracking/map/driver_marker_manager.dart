import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:moviroo_driver_app/core/models/geo_point.dart';
import 'map_painters.dart';

/// Manages driver marker creation and updates on the map.
class DriverMarkerManager {
  PointAnnotationManager? _manager;
  PointAnnotation? _annotation;
  bool _creating = false;
  bool _updating = false;
  Uint8List? _cachedBitmap;

  Future<void> setManager(PointAnnotationManager manager) async {
    _manager = manager;
  }

  /// Update or create the driver marker with the given position and bearing.
  /// Throttles updates to prevent method channel bottleneck.
  Future<void> update(GeoPoint pos, double bearing) async {
    if (_manager == null) return;
    final pt = Point(coordinates: Position(pos.lon, pos.lat));

    // Add 180° offset to bearing because the icon is drawn pointing UP (north)
    // but we want it to point in the direction of travel
    final correctedBearing = (bearing + 180) % 360;

    if (_annotation == null) {
      if (_creating) return;
      _creating = true;
      try {
        _cachedBitmap ??= await MapPainters.renderCarBitmap();
        _annotation = await _manager!.create(
          PointAnnotationOptions(
            geometry: pt,
            image: _cachedBitmap!,
            iconSize: 0.9,
            iconAnchor: IconAnchor.CENTER,
            iconRotate: correctedBearing,
          ),
        );
      } catch (e) {
        debugPrint('🗺️ [DriverMarker] ❌ Failed to create marker: $e');
      } finally {
        _creating = false;
      }
    } else {
      if (_updating) return;
      _updating = true;
      try {
        _annotation!.geometry = pt;
        _annotation!.iconRotate = correctedBearing;
        await _manager!.update(_annotation!);
      } catch (e) {
        // silent fail — marker will catch up on next tick
      } finally {
        _updating = false;
      }
    }
  }

  void dispose() {
    _annotation = null;
    _cachedBitmap = null;
  }
}
