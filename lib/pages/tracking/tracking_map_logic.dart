import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:moviroo_driver_app/core/models/geo_point.dart';
import 'package:moviroo_driver_app/services/mapbox/mapbox_service.dart';
import 'map/map_painters.dart';
import 'map/camera_controller.dart';
import 'map/driver_marker_manager.dart';
import 'map/route_manager.dart';

/// Lightweight coordinator for map tracking logic.
/// Delegates to specialized modules: camera, markers, and routes.
class TrackingMapLogic {
  final GeoPoint pickupPt;
  final GeoPoint dropoffPt;
  final void Function(String eta, String dist, String label) onEtaUpdate;

  MapboxMap? _map;
  PointAnnotationManager? _pointMgr;

  late CameraController _camera;
  late DriverMarkerManager _driverMarker;
  late RouteManager _route;

  DateTime? _lastEtaRefresh;

  TrackingMapLogic({
    required this.pickupPt,
    required this.dropoffPt,
    required this.onEtaUpdate,
  }) {
    _camera = CameraController(pickupPt: pickupPt, dropoffPt: dropoffPt);
    _driverMarker = DriverMarkerManager();
    _route = RouteManager(
      pickupPt: pickupPt,
      dropoffPt: dropoffPt,
      onEtaUpdate: onEtaUpdate,
    );
  }

  // ── Init ──────────────────────────────────────────────────────────────────

  void onMapCreated(MapboxMap map) {
    _map = map;
    _camera.setMap(map);
    _route.setMap(map);
  }

  /// Call this when user manually interacts with the map (pan, zoom, etc.).
  /// Disables follow mode so camera stops auto-snapping to driver.
  void disableFollowMode() {
    _camera.disableFollowMode();
  }

  /// Expose camera controller for accessing follow mode state
  CameraController get camera => _camera;

  /// Expose route manager for direct access
  RouteManager get route => _route;

  /// Handle reroute event - update route with new geometry
  Future<void> handleReroute(List<double> routeGeometry, int sequence) async {
    await _route.updateRouteGeometry(routeGeometry, sequence);
  }

  Future<void> onStyleLoaded() async {
    if (_map == null) return;

    _pointMgr = await _map!.annotations.createPointAnnotationManager();
    final driverMgr = await _map!.annotations.createPointAnnotationManager();
    await _driverMarker.setManager(driverMgr);

    // Always show BOTH markers from the start
    await _pointMgr!.create(
      PointAnnotationOptions(
        geometry: Point(coordinates: Position(pickupPt.lon, pickupPt.lat)),
        image: await MapPainters.renderPickupBitmap(),
        iconSize: 1.0,
        iconAnchor: IconAnchor.CENTER,
      ),
    );

    await _pointMgr!.create(
      PointAnnotationOptions(
        geometry: Point(coordinates: Position(dropoffPt.lon, dropoffPt.lat)),
        image: await MapPainters.renderDropoffBitmap(),
        iconSize: 1.0,
        iconAnchor: IconAnchor.BOTTOM,
      ),
    );

    await _route.initialize();

    // Fit camera to show both pickup and drop-off markers
    _camera.fitBothMarkers();
  }

  // ── Driver symbol ─────────────────────────────────────────────────────────

  Future<void> updateDriverSymbol(GeoPoint pos, double bearing) async {
    await _driverMarker.update(pos, bearing);

    // Camera follow: on first position, fly in to navigation zoom.
    // After that, only pan without resetting zoom (preserves user's zoom).
    _camera.shouldFollowDriver(pos, bearing);
  }

  Future<void> truncateRoute(GeoPoint driverPos) async {
    await _route.truncateRoute(driverPos);
  }

  // ── Phase 1: Driver → Pickup ──────────────────────────────────────────────

  Future<void> drawPhase1Route(GeoPoint driver) async {
    await _route.drawPhase1Route(driver);
  }

  // ── Phase 2: Pickup → Drop-off ────────────────────────────────────────────

  Future<void> drawPhase2Route(GeoPoint? driver) async {
    await _route.drawPhase2Route(driver);
  }

  // ── Clear route (remove line but keep markers) ────────────────────────────

  Future<void> clearRoute() async {
    await _route.clearRoute();
  }

  // ── Route deviation and re-routing ─────────────────────────────────────────

  /// Check if driver has deviated from route and trigger re-routing if needed.
  ///
  /// Returns true if re-route was triggered, false otherwise.
  /// Call this on each GPS update to enable automatic re-routing.
  Future<bool> checkAndReroute(GeoPoint driverPos, bool isPrePickup) async {
    if (!_route.deviationDetector.shouldReroute(driverPos)) {
      return false;
    }

    debugPrint('🗺️ [MapLogic] Driver off-route — re-routing');

    // Draw new route from current position (without auto-fit to preserve camera).
    // Old route stays visible while fetching new route to prevent fade effect.
    if (isPrePickup) {
      await _route.drawPhase1Route(driverPos);
    } else {
      await _route.drawPhase2Route(driverPos);
    }

    return true;
  }

  // ── ETA refresh ───────────────────────────────────────────────────────────

  Future<void> maybeRefreshEta(
    GeoPoint driver,
    bool isPrePickup,
    bool isInTrip,
  ) async {
    final now = DateTime.now();
    if (_lastEtaRefresh != null &&
        now.difference(_lastEtaRefresh!).inSeconds < 30) {
      return;
    }
    _lastEtaRefresh = now;
    if (isPrePickup) {
      final r = await MapboxService.getRoute(
        driver.lat,
        driver.lon,
        pickupPt.lat,
        pickupPt.lon,
      );
      if (r != null) onEtaUpdate(r.etaText, r.distanceText, 'To Pickup');
    } else if (isInTrip) {
      final r = await MapboxService.getRoute(
        driver.lat,
        driver.lon,
        dropoffPt.lat,
        dropoffPt.lon,
      );
      if (r != null) onEtaUpdate(r.etaText, r.distanceText, 'To Drop-off');
    }
  }

  // ── Camera ────────────────────────────────────────────────────────────────

  void fitToPickup() {
    _camera.fitToPickup();
  }

  void fitBothMarkers() {
    _camera.fitBothMarkers();
  }

  void fitBoundsDriverToPickup(GeoPoint driver) {
    _camera.fitBoundsDriverToPickup(driver);
  }

  void fitToFullRoute() {
    _camera.fitToFullRoute();
  }

  void animateToDriver(GeoPoint pos, {double bearing = 0}) {
    _camera.animateToDriver(pos, bearing: bearing);
  }

  void stopAnimations() {
    _camera.stopAnimations();
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  void dispose() {
    _driverMarker.dispose();
  }
}
