import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:moviroo_driver_app/services/tracking_socket_service.dart';

/// Manages GPS streaming + WebSocket broadcasting for a single ride.
class TrackingGpsController {
  final String rideId;

  final TrackingSocketService _socket = TrackingSocketService();
  StreamSubscription<Position>? _sub;

  TrackingGpsController(this.rideId);

  Future<void> start(void Function(Position) onPosition) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return;
    }

    await _socket.connect(rideId);

    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((pos) {
      _socket.sendGps(
        rideId: rideId,
        latitude: pos.latitude,
        longitude: pos.longitude,
        speedKmh: pos.speed * 3.6,
      );
      onPosition(pos);
    });
  }

  void dispose() {
    _sub?.cancel();
    _socket.disconnect();
  }
}
