import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:moviroo_driver_app/core/models/geo_point.dart';
import 'package:moviroo_driver_app/services/mapbox/mapbox_service.dart';
import 'map/map_painters.dart';

/// Manages all Mapbox map logic: markers, route line, and camera.
class TrackingMapLogic {
  final GeoPoint pickupPt;
  final GeoPoint dropoffPt;
  final void Function(String eta, String dist, String label) onEtaUpdate;

  MapboxMap? _map;
  PointAnnotationManager? _pointMgr;
  PointAnnotationManager? _driverMgr;

  PointAnnotation? _driverAnn;
  bool _driverCreating = false;
  Uint8List? _cachedCarBitmap;

  bool _pickupRouteDrawn = false;
  bool _dropoffRouteDrawn = false;
  bool _srcReady = false;

  DateTime? _lastEtaRefresh;

  TrackingMapLogic({
    required this.pickupPt,
    required this.dropoffPt,
    required this.onEtaUpdate,
  });

  // ── Init ──────────────────────────────────────────────────────────────────

  void onMapCreated(MapboxMap map) {
    _map = map;
  }

  Future<void> onStyleLoaded() async {
    if (_map == null) return;

    _pointMgr = await _map!.annotations.createPointAnnotationManager();
    _driverMgr = await _map!.annotations.createPointAnnotationManager();

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

    await _map!.style.addSource(
      GeoJsonSource(id: 'route-src', data: _emptyGeoJson()),
    );
    _srcReady = true;

    await _map!.style.addLayer(
      LineLayer(
        id: 'route-layer',
        sourceId: 'route-src',
        lineColor: const Color(0xFFA855F7).toARGB32(),
        lineWidth: 4.0,
        lineOpacity: 1.0,
        lineCap: LineCap.ROUND,
        lineJoin: LineJoin.ROUND,
      ),
    );

    // Fit camera to show both pickup and drop-off markers
    fitBothMarkers();
  }

  // ── Driver symbol ─────────────────────────────────────────────────────────

  Future<void> updateDriverSymbol(GeoPoint pos, double bearing) async {
    debugPrint(
      '🗺️ [MapLogic] updateDriverSymbol called: ${pos.lat}, ${pos.lon}, bearing=$bearing',
    );
    if (_driverMgr == null) {
      debugPrint('🗺️ [MapLogic] ⚠️ _driverMgr is null, cannot update marker');
      return;
    }
    final pt = Point(coordinates: Position(pos.lon, pos.lat));

    if (_driverAnn == null) {
      if (_driverCreating) return; // guard: create already in-flight
      _driverCreating = true;
      try {
        debugPrint('🗺️ [MapLogic] Creating new driver marker...');
        _cachedCarBitmap ??= await MapPainters.renderCarBitmap();
        debugPrint(
          '🗺️ [MapLogic] Car bitmap rendered, creating annotation...',
        );
        _driverAnn = await _driverMgr!.create(
          PointAnnotationOptions(
            geometry: pt,
            image: _cachedCarBitmap!,
            iconSize: 0.9,
            iconAnchor: IconAnchor.CENTER,
            iconRotate: bearing,
          ),
        );
        debugPrint('🗺️ [MapLogic] ✅ Driver marker created successfully');
      } catch (e) {
        debugPrint('🗺️ [MapLogic] ❌ Failed to create driver marker: $e');
      } finally {
        _driverCreating = false;
      }
    } else {
      // Subsequent calls — update position & rotation in-place (no flicker)
      debugPrint('🗺️ [MapLogic] Updating existing driver marker...');
      _driverAnn!.geometry = pt;
      _driverAnn!.iconRotate = bearing;
      await _driverMgr!.update(_driverAnn!);
      debugPrint('🗺️ [MapLogic] ✅ Driver marker updated');
    }
  }

  // ── Phase 1: Driver → Pickup ──────────────────────────────────────────────

  Future<void> drawPhase1Route(GeoPoint driver) async {
    if (!_srcReady || _pickupRouteDrawn) return;
    _pickupRouteDrawn = true;

    final result = await MapboxService.getRoute(
      driver.lat,
      driver.lon,
      pickupPt.lat,
      pickupPt.lon,
    );

    if (result != null) {
      onEtaUpdate(result.etaText, result.distanceText, 'To Pickup');
      await _map!.style.setStyleSourceProperty(
        'route-src',
        'data',
        _geometryToGeoJson(result.geometry),
      );
    } else {
      // Fallback to straight line if Mapbox fails
      final pts = [driver, pickupPt];
      await _map!.style.setStyleSourceProperty(
        'route-src',
        'data',
        _ptsToGeoJson(pts),
      );
    }
    fitBoundsDriverToPickup(driver);
  }

  // ── Phase 2: Pickup → Drop-off ────────────────────────────────────────────

  Future<void> drawPhase2Route(GeoPoint? driver) async {
    if (!_srcReady || _dropoffRouteDrawn) return;
    _dropoffRouteDrawn = true;

    // Dropoff marker already created in onStyleLoaded — no need to recreate

    final result = await MapboxService.getRoute(
      pickupPt.lat,
      pickupPt.lon,
      dropoffPt.lat,
      dropoffPt.lon,
    );

    if (result != null) {
      onEtaUpdate(result.etaText, result.distanceText, 'To Drop-off');
      await _map!.style.setStyleSourceProperty(
        'route-src',
        'data',
        _geometryToGeoJson(result.geometry),
      );
    } else {
      // Fallback to straight line if Mapbox fails
      final pts = [pickupPt, dropoffPt];
      await _map!.style.setStyleSourceProperty(
        'route-src',
        'data',
        _ptsToGeoJson(pts),
      );
    }
    fitToFullRoute();
  }

  // ── Clear route (remove line but keep markers) ────────────────────────────

  Future<void> clearRoute() async {
    if (!_srcReady) return;
    await _map!.style.setStyleSourceProperty(
      'route-src',
      'data',
      _emptyGeoJson(),
    );
    _pickupRouteDrawn = false;
    _dropoffRouteDrawn = false;
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
    _map?.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(pickupPt.lon, pickupPt.lat)),
        zoom: 15.0,
      ),
      MapAnimationOptions(duration: 800),
    );
  }

  /// Fit camera to show both pickup and dropoff markers (no route needed).
  void fitBothMarkers() {
    if (_map == null) return;
    final sw = GeoPoint(
      math.min(pickupPt.lat, dropoffPt.lat),
      math.min(pickupPt.lon, dropoffPt.lon),
    );
    final ne = GeoPoint(
      math.max(pickupPt.lat, dropoffPt.lat),
      math.max(pickupPt.lon, dropoffPt.lon),
    );
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
        .catchError((_) {});
  }

  void fitBoundsDriverToPickup(GeoPoint driver) {
    if (_map == null) return;
    final sw = GeoPoint(
      math.min(driver.lat, pickupPt.lat),
      math.min(driver.lon, pickupPt.lon),
    );
    final ne = GeoPoint(
      math.max(driver.lat, pickupPt.lat),
      math.max(driver.lon, pickupPt.lon),
    );
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
        .catchError((_) {});
  }

  void fitToFullRoute() {
    if (_map == null) return;
    final sw = GeoPoint(
      math.min(pickupPt.lat, dropoffPt.lat),
      math.min(pickupPt.lon, dropoffPt.lon),
    );
    final ne = GeoPoint(
      math.max(pickupPt.lat, dropoffPt.lat),
      math.max(pickupPt.lon, dropoffPt.lon),
    );
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
        .catchError((_) {});
  }

  void animateToDriver(GeoPoint pos, {double bearing = 0}) {
    _map?.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(pos.lon, pos.lat)),
        zoom: 16.0,
        bearing: bearing,
        pitch: 45.0,
      ),
      MapAnimationOptions(duration: 800),
    );
  }

  void stopAnimations() {}

  // ── GeoJSON helpers ───────────────────────────────────────────────────────

  String _ptsToGeoJson(List<GeoPoint> pts) => jsonEncode({
    'type': 'FeatureCollection',
    'features': [
      {
        'type': 'Feature',
        'geometry': {
          'type': 'LineString',
          'coordinates': pts.map((p) => [p.lon, p.lat]).toList(),
        },
        'properties': {},
      },
    ],
  });

  /// Convert flattened geometry array [lon, lat, lon, lat, ...] to GeoJSON LineString
  String _geometryToGeoJson(List<double> geometry) {
    if (geometry.length < 4) return _emptyGeoJson();

    final coordinates = <List<double>>[];
    for (int i = 0; i < geometry.length; i += 2) {
      coordinates.add([geometry[i], geometry[i + 1]]);
    }

    return jsonEncode({
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'geometry': {'type': 'LineString', 'coordinates': coordinates},
          'properties': {},
        },
      ],
    });
  }

  String _emptyGeoJson() =>
      jsonEncode({'type': 'FeatureCollection', 'features': []});

  // ── Dispose ───────────────────────────────────────────────────────────────

  void dispose() {}
}
