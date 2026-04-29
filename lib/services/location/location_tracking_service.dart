import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Singleton service that manages GPS streaming for UI updates only.
/// This service lives at the app level and is NOT tied to widget lifecycle.
/// It does NOT emit GPS to the backend - the background isolate handles that.
class LocationTrackingService {
  static final LocationTrackingService _instance =
      LocationTrackingService._internal();
  factory LocationTrackingService() => _instance;
  LocationTrackingService._internal();

  String? _currentRideId;
  StreamSubscription<Position>? _gpsSubscription;

  // Broadcast stream for position updates that UI can listen to
  final _positionController = StreamController<Position>.broadcast();
  Stream<Position> get positionStream => _positionController.stream;

  // External listener for incoming location updates (e.g. for passenger app)
  void Function(double lat, double lng)? onLocationUpdate;

  /// Start GPS tracking for a specific ride (UI only - no backend emission).
  Future<void> startTracking(String rideId) async {
    debugPrint(
      '🚗 [LocationTrackingService] Starting GPS stream for ride: $rideId',
    );

    if (_gpsSubscription != null && _currentRideId == rideId) {
      debugPrint('🚗 [LocationTrackingService] Already tracking this ride');
      return;
    }

    // Stop any existing tracking
    await stopTracking();

    _currentRideId = rideId;

    // Check location service
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('🚗 [LocationTrackingService] Location service NOT enabled');
      return;
    }
    debugPrint('🚗 [LocationTrackingService] Location service enabled ✓');

    // Check permissions
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      debugPrint(
        '🚗 [LocationTrackingService] Location permission denied, requesting...',
      );
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        debugPrint(
          '🚗 [LocationTrackingService] Location permission denied after request',
        );
        return;
      }
    }
    debugPrint('🚗 [LocationTrackingService] Location permission granted ✓');

    // Start GPS stream (UI only - background isolate emits to backend)
    debugPrint(
      '🚗 [LocationTrackingService] Starting GPS stream (accuracy: high, distanceFilter: 0)...',
    );
    _gpsSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
          ),
        ).listen(
          (pos) {
            debugPrint(
              '🚗 [LocationTrackingService] GPS update: lat=${pos.latitude}, lng=${pos.longitude}',
            );
            _positionController.add(pos);
          },
          onError: (e) {
            debugPrint('🚗 [LocationTrackingService] ERROR in GPS stream: $e');
          },
        );
    debugPrint('🚗 [LocationTrackingService] GPS stream started ✓');
  }

  /// Stop GPS tracking
  Future<void> stopTracking() async {
    debugPrint('🚗 [LocationTrackingService] Stopping GPS tracking');

    await _gpsSubscription?.cancel();
    _gpsSubscription = null;

    _currentRideId = null;
    debugPrint('🚗 [LocationTrackingService] Tracking stopped ✓');
  }

  /// Cleanup resources
  Future<void> dispose() async {
    await stopTracking();
    await _positionController.close();
  }
}
