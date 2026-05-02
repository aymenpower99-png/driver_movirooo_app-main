import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:moviroo_driver_app/core/models/geo_point.dart';

/// Manages camera control for the tracking map.
/// Handles zoom, pan, and follow mode logic.
class CameraController {
  MapboxMap? _map;
  GeoPoint? _pickupPt;
  GeoPoint? _dropoffPt;

  /// Default zoom used when user explicitly taps GPS button or on first center.
  static const double _defaultFollowZoom = 17.0;

  /// Whether the camera should follow the driver (pans without resetting zoom).
  /// Disabled by default so camera doesn't auto-follow after manual interaction.
  /// Only enabled when user explicitly taps the GPS button.
  bool _followMode = false;

  /// Whether we're currently performing a programmatic camera move.
  /// Used to distinguish programmatic moves from user interactions.
  bool _isProgrammaticMove = false;

  /// Whether we've centered on the driver at least once (to set initial zoom).
  bool _initialCenterDone = false;

  /// Timestamp of last manual zoom to prevent auto-zoom reset.
  DateTime? _lastManualZoom;

  CameraController({GeoPoint? pickupPt, GeoPoint? dropoffPt}) {
    _pickupPt = pickupPt;
    _dropoffPt = dropoffPt;
  }

  void setMap(MapboxMap map) {
    _map = map;
  }

  void setPickupDropoff(GeoPoint pickup, GeoPoint dropoff) {
    _pickupPt = pickup;
    _dropoffPt = dropoff;
  }

  /// Call this when user manually interacts with the map (pan, zoom, etc.).
  /// Disables follow mode so camera stops auto-snapping to driver.
  void disableFollowMode() {
    if (_followMode) {
      _followMode = false;
      debugPrint('🗺️ [CameraController] Follow mode disabled');
    }
  }

  /// Called by the GPS location button OR for initial centering.
  /// Resets zoom to a navigation-friendly level and centers on driver.
  /// Re-enables follow mode.
  void animateToDriver(GeoPoint pos, {double bearing = 0}) {
    _lastManualZoom = DateTime.now();
    _followMode = true;
    _initialCenterDone = true;
    _isProgrammaticMove = true;
    _map
        ?.flyTo(
          CameraOptions(
            center: Point(coordinates: Position(pos.lon, pos.lat)),
            zoom: _defaultFollowZoom,
            bearing: bearing,
            pitch: 45.0,
          ),
          MapAnimationOptions(duration: 800),
        )
        .then((_) => _isProgrammaticMove = false);
  }

  /// Pan the camera to driver's position WITHOUT changing zoom.
  /// Preserves any zoom level the user or system previously set.
  void followCameraToDriver(GeoPoint pos, double bearing) {
    if (_map == null) return;
    _isProgrammaticMove = true;
    _map!
        .easeTo(
          CameraOptions(
            center: Point(coordinates: Position(pos.lon, pos.lat)),
            bearing: bearing,
          ),
          MapAnimationOptions(duration: 500),
        )
        .then((_) => _isProgrammaticMove = false);
  }

  /// Fit camera to show both pickup and dropoff markers (no route needed).
  void fitBothMarkers() {
    if (_map == null || _pickupPt == null || _dropoffPt == null) return;
    final sw = GeoPoint(
      math.min(_pickupPt!.lat, _dropoffPt!.lat),
      math.min(_pickupPt!.lon, _dropoffPt!.lon),
    );
    final ne = GeoPoint(
      math.max(_pickupPt!.lat, _dropoffPt!.lat),
      math.max(_pickupPt!.lon, _dropoffPt!.lon),
    );
    _isProgrammaticMove = true;
    _map!
        .cameraForCoordinateBounds(
          CoordinateBounds(
            southwest: Point(coordinates: Position(sw.lon, sw.lat)),
            northeast: Point(coordinates: Position(ne.lon, ne.lat)),
            infiniteBounds: false,
          ),
          MbxEdgeInsets(top: 120, left: 60, bottom: 300, right: 60),
          null,
          null,
          null,
          null,
        )
        .then((c) => _map?.flyTo(c, MapAnimationOptions(duration: 1000)))
        .then((_) => _isProgrammaticMove = false)
        .catchError((_) => _isProgrammaticMove = false);
  }

  void fitToPickup() {
    if (_map == null || _pickupPt == null) return;
    _isProgrammaticMove = true;
    _map
        ?.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(_pickupPt!.lon, _pickupPt!.lat),
            ),
            zoom: 15.0,
          ),
          MapAnimationOptions(duration: 800),
        )
        .then((_) => _isProgrammaticMove = false);
  }

  void fitBoundsDriverToPickup(GeoPoint driver) {
    if (_map == null || _pickupPt == null) return;
    // Skip auto-zoom if manual zoom happened within last 5 seconds
    if (_lastManualZoom != null &&
        DateTime.now().difference(_lastManualZoom!).inSeconds < 5) {
      return;
    }
    final sw = GeoPoint(
      math.min(driver.lat, _pickupPt!.lat),
      math.min(driver.lon, _pickupPt!.lon),
    );
    final ne = GeoPoint(
      math.max(driver.lat, _pickupPt!.lat),
      math.max(driver.lon, _pickupPt!.lon),
    );
    _isProgrammaticMove = true;
    _map!
        .cameraForCoordinateBounds(
          CoordinateBounds(
            southwest: Point(coordinates: Position(sw.lon, sw.lat)),
            northeast: Point(coordinates: Position(ne.lon, ne.lat)),
            infiniteBounds: false,
          ),
          MbxEdgeInsets(top: 120, left: 60, bottom: 300, right: 60),
          null,
          null,
          null,
          null,
        )
        .then((c) => _map?.flyTo(c, MapAnimationOptions(duration: 1000)))
        .then((_) => _isProgrammaticMove = false)
        .catchError((_) => _isProgrammaticMove = false);
  }

  void fitToFullRoute() {
    if (_map == null || _pickupPt == null || _dropoffPt == null) return;
    // Skip auto-zoom if manual zoom happened within last 5 seconds
    if (_lastManualZoom != null &&
        DateTime.now().difference(_lastManualZoom!).inSeconds < 5) {
      return;
    }
    final sw = GeoPoint(
      math.min(_pickupPt!.lat, _dropoffPt!.lat),
      math.min(_pickupPt!.lon, _dropoffPt!.lon),
    );
    final ne = GeoPoint(
      math.max(_pickupPt!.lat, _dropoffPt!.lat),
      math.max(_pickupPt!.lon, _dropoffPt!.lon),
    );
    _isProgrammaticMove = true;
    _map!
        .cameraForCoordinateBounds(
          CoordinateBounds(
            southwest: Point(coordinates: Position(sw.lon, sw.lat)),
            northeast: Point(coordinates: Position(ne.lon, ne.lat)),
            infiniteBounds: false,
          ),
          MbxEdgeInsets(top: 120, left: 60, bottom: 300, right: 60),
          null,
          null,
          null,
          null,
        )
        .then((c) => _map?.flyTo(c, MapAnimationOptions(duration: 1000)))
        .then((_) => _isProgrammaticMove = false)
        .catchError((_) => _isProgrammaticMove = false);
  }

  void stopAnimations() {}

  /// Handle camera follow logic when driver position updates.
  /// Returns true if camera should follow, false otherwise.
  bool shouldFollowDriver(GeoPoint pos, double bearing) {
    if (!_followMode) return false;

    if (!_initialCenterDone) {
      _initialCenterDone = true;
      animateToDriver(pos, bearing: bearing);
      return false; // animateToDriver handles it
    } else {
      followCameraToDriver(pos, bearing);
      return true;
    }
  }

  bool get followMode => _followMode;

  bool get isProgrammaticMove => _isProgrammaticMove;
}
