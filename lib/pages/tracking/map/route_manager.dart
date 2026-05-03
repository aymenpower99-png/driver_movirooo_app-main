import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:moviroo_driver_app/core/models/geo_point.dart';
import 'package:moviroo_driver_app/services/mapbox/mapbox_service.dart';
import '../route_deviation_detector.dart';
import 'geojson_helper.dart';

/// Manages route drawing, clearing, and ETA updates on the map.
class RouteManager {
  MapboxMap? _map;
  GeoPoint? _pickupPt;
  GeoPoint? _dropoffPt;
  RouteDeviationDetector? _deviationDetector;

  bool _pickupRouteDrawn = false;
  bool _dropoffRouteDrawn = false;
  bool _srcReady = false;

  final void Function(String eta, String dist, String label) onEtaUpdate;

  RouteManager({
    GeoPoint? pickupPt,
    GeoPoint? dropoffPt,
    required this.onEtaUpdate,
  }) {
    _pickupPt = pickupPt;
    _dropoffPt = dropoffPt;
    _deviationDetector = RouteDeviationDetector();
  }

  void setMap(MapboxMap map) {
    _map = map;
  }

  void setPickupDropoff(GeoPoint pickup, GeoPoint dropoff) {
    _pickupPt = pickup;
    _dropoffPt = dropoff;
  }

  RouteDeviationDetector get deviationDetector => _deviationDetector!;

  /// Initialize the route source and layer on the map.
  Future<void> initialize() async {
    if (_map == null) return;

    await _map!.style.addSource(
      GeoJsonSource(id: 'route-src', data: GeoJsonHelper.emptyGeoJson()),
    );
    _srcReady = true;

    await _map!.style.addLayer(
      LineLayer(
        id: 'route-layer',
        sourceId: 'route-src',
        lineColor: const Color(0xFFA855F7).toARGB32(),
        lineWidth: 8.0,
        lineOpacity: 1.0,
        lineCap: LineCap.ROUND,
        lineJoin: LineJoin.ROUND,
      ),
    );
  }

  /// Draw Phase 1 route (Driver → Pickup).
  Future<void> drawPhase1Route(GeoPoint driver, {bool fitCamera = true}) async {
    if (!_srcReady || _pickupRouteDrawn) return;
    _pickupRouteDrawn = true;

    final result = await MapboxService.getRoute(
      driver.lat,
      driver.lon,
      _pickupPt!.lat,
      _pickupPt!.lon,
    );

    if (result != null) {
      onEtaUpdate(result.etaText, result.distanceText, 'To Pickup');
      _deviationDetector!.setCurrentRoute(result.geometry, _pickupPt!);
      await _map!.style.setStyleSourceProperty(
        'route-src',
        'data',
        GeoJsonHelper.geometryToGeoJson(result.geometry),
      );
    } else {
      // Fallback to straight line if Mapbox fails
      final pts = [driver, _pickupPt!];
      await _map!.style.setStyleSourceProperty(
        'route-src',
        'data',
        GeoJsonHelper.ptsToGeoJson(pts),
      );
    }
  }

  /// Draw Phase 2 route (Pickup → Drop-off).
  Future<void> drawPhase2Route(
    GeoPoint? driver, {
    bool fitCamera = true,
  }) async {
    if (!_srcReady || _dropoffRouteDrawn) return;
    _dropoffRouteDrawn = true;

    final result = await MapboxService.getRoute(
      _pickupPt!.lat,
      _pickupPt!.lon,
      _dropoffPt!.lat,
      _dropoffPt!.lon,
    );

    if (result != null) {
      onEtaUpdate(result.etaText, result.distanceText, 'To Drop-off');
      _deviationDetector!.setCurrentRoute(result.geometry, _dropoffPt!);
      await _map!.style.setStyleSourceProperty(
        'route-src',
        'data',
        GeoJsonHelper.geometryToGeoJson(result.geometry),
      );
    } else {
      // Fallback to straight line if Mapbox fails
      final pts = [_pickupPt!, _dropoffPt!];
      await _map!.style.setStyleSourceProperty(
        'route-src',
        'data',
        GeoJsonHelper.ptsToGeoJson(pts),
      );
    }
  }

  /// Clear the route line from the map (keeps markers).
  Future<void> clearRoute() async {
    if (!_srcReady) return;
    await _map!.style.setStyleSourceProperty(
      'route-src',
      'data',
      GeoJsonHelper.emptyGeoJson(),
    );
    _pickupRouteDrawn = false;
    _dropoffRouteDrawn = false;
    _deviationDetector!.clearRoute();
  }

  /// Check if Phase 1 route has been drawn.
  bool get pickupRouteDrawn => _pickupRouteDrawn;

  /// Check if Phase 2 route has been drawn.
  bool get dropoffRouteDrawn => _dropoffRouteDrawn;

  /// Update route with new geometry from reroute event
  Future<void> updateRouteGeometry(
    List<double> routeGeometry,
    int sequence,
  ) async {
    if (!_srcReady) return;

    if (routeGeometry.isEmpty || routeGeometry.length < 4) {
      debugPrint('⚠️ [RouteManager] Invalid reroute geometry');
      return;
    }

    // Update the route on the map with flattened coordinates
    await _map!.style.setStyleSourceProperty(
      'route-src',
      'data',
      GeoJsonHelper.geometryToGeoJson(routeGeometry),
    );

    // Update deviation detector with new route
    if (_dropoffRouteDrawn && _dropoffPt != null) {
      _deviationDetector!.setCurrentRoute(routeGeometry, _dropoffPt!);
    } else if (_pickupRouteDrawn && _pickupPt != null) {
      _deviationDetector!.setCurrentRoute(routeGeometry, _pickupPt!);
    }

    debugPrint(
      '✅ [RouteManager] Route updated with sequence $sequence (${routeGeometry.length ~/ 2} points)',
    );
  }
}
