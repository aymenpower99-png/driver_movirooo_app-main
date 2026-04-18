import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../core/config/app_config.dart';
import '../core/storage/token_storage.dart';

/// Manages WebSocket connection to backend /trips namespace.
/// Driver joins ride room, streams GPS, and receives location_update events.
class TrackingSocketService {
  io.Socket? _socket;
  String? _currentRideId;

  // External listener for incoming location updates (e.g. for passenger app)
  void Function(double lat, double lng)? onLocationUpdate;

  Future<void> connect(String rideId) async {
    if (_socket != null && _currentRideId == rideId) return;
    await disconnect();

    _currentRideId = rideId;
    final token = await TokenStorage.getAccess();

    _socket = io.io(
      '${AppConfig.baseUrl}/trips',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      _socket!.emit('join', {'ride_id': rideId});
    });

    _socket!.on('trip:location_update', (data) {
      if (data is Map && onLocationUpdate != null) {
        final lat = (data['latitude'] as num?)?.toDouble();
        final lng = (data['longitude'] as num?)?.toDouble();
        if (lat != null && lng != null) onLocationUpdate!(lat, lng);
      }
    });
  }

  /// Send a GPS point to the backend (driver → backend → passenger).
  void sendGps({
    required String rideId,
    required double latitude,
    required double longitude,
    double? speedKmh,
  }) {
    if (_socket == null || !(_socket!.connected)) return;
    _socket!.emit('trip:gps', {
      'ride_id': rideId,
      'latitude': latitude,
      'longitude': longitude,
      'speed_kmh': speedKmh ?? 0.0,
      'recorded_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> disconnect() async {
    if (_currentRideId != null && _socket != null) {
      _socket!.emit('leave', {'ride_id': _currentRideId});
    }
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _currentRideId = null;
  }
}
