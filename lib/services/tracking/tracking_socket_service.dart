import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/config/app_config.dart';
import '../../core/storage/token_storage.dart';

/// Manages WebSocket connection to backend /trips namespace.
/// Driver joins ride room, streams GPS, and receives location_update events.
class TrackingSocketService {
  io.Socket? _socket;
  String? _currentRideId;

  // External listener for incoming location updates (e.g. for passenger app)
  void Function(double lat, double lng)? onLocationUpdate;

  // External listener for reroute events
  void Function(List<double> routeGeometry, int sequence)? onReroute;

  Future<void> connect(String rideId) async {
    if (_socket != null && _currentRideId == rideId) return;
    await disconnect();

    _currentRideId = rideId;
    final token = await TokenStorage.getAccess();

    _socket = io.io(
      AppConfig.wsBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({
            'Authorization': 'Bearer $token',
            'ngrok-skip-browser-warning': 'true',
          })
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

    _socket!.on('trip:reroute', (data) {
      if (data is Map && onReroute != null) {
        final routeGeometry = data['routeGeometry'] as List?;
        final sequence = data['sequence'] as int?;
        if (routeGeometry != null && sequence != null) {
          // Convert List<dynamic> to List<double>
          final coordinates = routeGeometry
              .map((e) => (e as num).toDouble())
              .toList();
          debugPrint(
            '🔌 [Driver] Received trip:reroute event - sequence=$sequence, points=${coordinates.length ~/ 2}',
          );
          onReroute!(coordinates, sequence);
        }
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
    if (_socket == null || !(_socket!.connected)) {
      debugPrint(
        '🔌 [Driver] sendGps SKIPPED — socket null=${_socket == null}, connected=${_socket?.connected}',
      );
      return;
    }
    debugPrint(
      '🔌 [Driver] Emitting trip:gps → ride=$rideId, lat=$latitude, lng=$longitude',
    );
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
