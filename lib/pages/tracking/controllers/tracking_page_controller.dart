// lib/pages/tracking/controllers/tracking_page_controller.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/core/models/geo_point.dart';
import 'package:moviroo_driver_app/services/background/background_tracking_service.dart';
import '../utils/geo_math.dart';

/// Controller for tracking page GPS streams, status, and animation.
/// Manages GPS subscriptions, position updates, and GPS status tracking.
class TrackingPageController {
  final String rideId;
  final GeoPoint pickupPt;
  final GeoPoint dropoffPt;
  final void Function(GeoPoint position, double bearing) onPositionUpdate;
  final void Function(GeoPoint position, double bearing) onAnimationTick;

  // GPS stream (single source from BackgroundTrackingService)
  StreamSubscription<Map<String, dynamic>?>? _bgGpsSubscription;

  // Animation
  AnimationController? _moveAnim;
  GeoPoint? _animStart;
  GeoPoint? _animEnd;

  // Driver position state
  GeoPoint? _driverPosition;
  double _driverBearing = 0;
  double _prevBearing = 0;
  GeoPoint? _prevPosition;

  TrackingPageController({
    required this.rideId,
    required this.pickupPt,
    required this.dropoffPt,
    required this.onPositionUpdate,
    required this.onAnimationTick,
  });

  // Getters for UI
  GeoPoint? get driverPosition => _driverPosition;
  double get driverBearing => _driverBearing;

  /// Initialize the controller with TickerProvider for animation.
  void initialize(TickerProvider vsync) {
    _moveAnim = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1000),
    )..addListener(_onMoveAnimTick);
  }

  /// Subscribe to GPS stream from BackgroundTrackingService (single source).
  void subscribeToGpsStreams() {
    debugPrint('🚗 [TrackingController] === Subscribing to GPS stream ===');
    debugPrint('🚗 [TrackingController] Ride ID: $rideId');

    _bgGpsSubscription = BackgroundTrackingService.onGpsUpdate.listen(
      (data) {
        if (data == null) return;
        final lat = data['latitude'] as double?;
        final lng = data['longitude'] as double?;
        if (lat != null && lng != null) {
          _processNewPosition(GeoPoint(lat, lng));
        }
      },
      onError: (e) {
        debugPrint('🚗 [TrackingController] GPS stream error: $e');
      },
    );
    debugPrint('🚗 [TrackingController] Subscribed to GPS stream ✓');
  }

  /// Process a new GPS position — sets up smooth animation.
  void _processNewPosition(GeoPoint newPt) {
    _prevBearing = _driverBearing;
    if (_driverPosition != null) {
      // Only update bearing if moved enough to avoid jitter when stationary
      final dist = GeoMath.distanceMeters(_driverPosition!, newPt);
      if (dist > 1.5) {
        _driverBearing = GeoMath.calculateBearing(_driverPosition!, newPt);
      }
    }
    _prevPosition = _driverPosition ?? newPt;
    _driverPosition = newPt;

    _animStart = _prevPosition;
    _animEnd = newPt;
    _moveAnim?.forward(from: 0.0);

    onPositionUpdate(newPt, _driverBearing);
  }

  /// Animation tick callback - smoothly interpolates position and bearing.
  void _onMoveAnimTick() {
    if (_animStart == null || _animEnd == null) return;
    final t = Curves.easeInOut.transform(_moveAnim!.value);
    final lat = GeoMath.lerpDouble(_animStart!.lat, _animEnd!.lat, t);
    final lon = GeoMath.lerpDouble(_animStart!.lon, _animEnd!.lon, t);
    // Interpolate bearing using shortest angular path
    final bearing = _lerpBearing(_prevBearing, _driverBearing, t);
    onAnimationTick(GeoPoint(lat, lon), bearing);
  }

  /// Linear interpolation for bearings (handles 0/360 wrap-around).
  double _lerpBearing(double a, double b, double t) {
    double diff = ((b - a + 540) % 360) - 180;
    return (a + diff * t + 360) % 360;
  }

  /// Dispose of all resources.
  void dispose() {
    debugPrint('🚗 [TrackingController] Disposing controller');
    _moveAnim?.dispose();
    _bgGpsSubscription?.cancel();
    debugPrint('🚗 [TrackingController] Controller disposed');
  }
}
