import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:moviroo_driver_app/services/tracking/tracking_socket_service.dart';

/// Manages GPS streaming + WebSocket broadcasting for a single ride.
class TrackingGpsController {
  final String rideId;

  final TrackingSocketService _socket = TrackingSocketService();
  StreamSubscription<Position>? _sub;

  TrackingGpsController(this.rideId);

  Future<void> start(void Function(Position) onPosition) async {
    debugPrint('🚗 [DriverGPS] Starting GPS tracking for ride: $rideId');

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('🚗 [DriverGPS] Location service NOT enabled');
      return;
    }
    debugPrint('🚗 [DriverGPS] Location service enabled ✓');

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      debugPrint('🚗 [DriverGPS] Location permission denied, requesting...');
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        debugPrint('🚗 [DriverGPS] Location permission denied after request');
        return;
      }
    }
    debugPrint('🚗 [DriverGPS] Location permission granted ✓');

    debugPrint('🚗 [DriverGPS] Connecting to WebSocket...');
    await _socket.connect(rideId);
    debugPrint('🚗 [DriverGPS] WebSocket connected ✓');

    debugPrint(
      '🚗 [DriverGPS] Starting GPS stream (accuracy: high, distanceFilter: 0)...',
    );
    _sub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
          ),
        ).listen(
          (pos) {
            debugPrint(
              '🚗 [DriverGPS] GPS update: lat=${pos.latitude}, lng=${pos.longitude}, speed=${pos.speed}',
            );
            debugPrint('🚗 [DriverGPS] Sending to WebSocket via sendGps...');
            _socket.sendGps(
              rideId: rideId,
              latitude: pos.latitude,
              longitude: pos.longitude,
              speedKmh: pos.speed * 3.6,
            );
            debugPrint('🚗 [DriverGPS] sendGps called ✓');
            onPosition(pos);
          },
          onError: (e) {
            debugPrint('🚗 [DriverGPS] ERROR in GPS stream: $e');
          },
        );
    debugPrint('🚗 [DriverGPS] GPS stream started ✓');
  }

  void dispose() {
    debugPrint('🚗 [DriverGPS] Disposing GPS controller');
    _sub?.cancel();
    _socket.disconnect();
  }
}
