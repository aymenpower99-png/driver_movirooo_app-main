import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/config/app_config.dart';
import '../../core/storage/token_storage.dart';

/// Singleton service that manages GPS streaming and WebSocket broadcasting
/// for driver location tracking. This service lives at the app level and is
/// NOT tied to any specific widget lifecycle.
class LocationTrackingService {
  static final LocationTrackingService _instance =
      LocationTrackingService._internal();
  factory LocationTrackingService() => _instance;
  LocationTrackingService._internal();

  io.Socket? _socket;
  String? _currentRideId;
  StreamSubscription<Position>? _gpsSubscription;

  // Broadcast stream for position updates that UI can listen to
  final _positionController = StreamController<Position>.broadcast();
  Stream<Position> get positionStream => _positionController.stream;

  // External listener for incoming location updates (e.g. for passenger app)
  void Function(double lat, double lng)? onLocationUpdate;

  /// Start GPS tracking for a specific ride
  Future<void> startTracking(String rideId) async {
    debugPrint(
      '🚗 [LocationTrackingService] Starting GPS tracking for ride: $rideId',
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

    // Connect to WebSocket
    debugPrint('🚗 [LocationTrackingService] Connecting to WebSocket...');
    await _connectWebSocket(rideId);
    debugPrint('🚗 [LocationTrackingService] WebSocket connected ✓');

    // Start GPS stream
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
              '🚗 [LocationTrackingService] GPS update: lat=${pos.latitude}, lng=${pos.longitude}, speed=${pos.speed}',
            );
            _sendGpsToBackend(pos);
            _positionController.add(pos);
          },
          onError: (e) {
            debugPrint('🚗 [LocationTrackingService] ERROR in GPS stream: $e');
          },
        );
    debugPrint('🚗 [LocationTrackingService] GPS stream started ✓');
  }

  /// Stop GPS tracking and disconnect WebSocket
  Future<void> stopTracking() async {
    debugPrint('🚗 [LocationTrackingService] Stopping GPS tracking');

    await _gpsSubscription?.cancel();
    _gpsSubscription = null;

    await _disconnectWebSocket();

    _currentRideId = null;
    debugPrint('🚗 [LocationTrackingService] Tracking stopped ✓');
  }

  /// Connect to WebSocket for tracking
  Future<void> _connectWebSocket(String rideId) async {
    if (_socket != null && _currentRideId == rideId) return;
    await _disconnectWebSocket();

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
  }

  /// Send GPS data to backend
  void _sendGpsToBackend(Position pos) {
    if (_socket == null || !(_socket!.connected)) {
      debugPrint(
        '🚗 [LocationTrackingService] sendGps SKIPPED — socket null=${_socket == null}, connected=${_socket?.connected}',
      );
      return;
    }
    debugPrint(
      '🚗 [LocationTrackingService] Emitting trip:gps → ride=$_currentRideId, lat=${pos.latitude}, lng=${pos.longitude}',
    );
    _socket!.emit('trip:gps', {
      'ride_id': _currentRideId,
      'latitude': pos.latitude,
      'longitude': pos.longitude,
      'speed_kmh': pos.speed * 3.6,
      'recorded_at': DateTime.now().toIso8601String(),
    });
  }

  /// Disconnect WebSocket
  Future<void> _disconnectWebSocket() async {
    if (_currentRideId != null && _socket != null) {
      _socket!.emit('leave', {'ride_id': _currentRideId});
    }
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  /// Cleanup resources
  Future<void> dispose() async {
    await stopTracking();
    await _positionController.close();
  }
}
