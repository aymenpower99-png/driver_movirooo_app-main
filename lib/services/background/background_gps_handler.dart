import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/config/app_config.dart';
import '../../core/storage/token_storage.dart';
import 'background_battery_handler.dart';
import 'background_permission_handler.dart';

/// Handles GPS start/stop logic for background tracking.
class BackgroundGpsHandler {
  /// Start GPS and WebSocket connection
  static Future<void> startGpsAndSocket(
    String rideId,
    io.Socket? socket,
    StreamSubscription<Position>? subscription,
    void Function(io.Socket) onSocketConnected,
  ) async {
    debugPrint('🚗 [BackgroundGps] Starting GPS tracking for ride: $rideId');

    // Stop any existing tracking
    await stopGpsAndSocket(subscription, socket);

    // Check and request permissions
    final hasPermissions =
        await BackgroundPermissionHandler.checkAndRequestPermissions();
    if (!hasPermissions) {
      debugPrint('🚗 [BackgroundGps] Required permissions not granted');
      return;
    }

    // Connect to WebSocket
    final token = await TokenStorage.getAccess();
    if (token == null) {
      debugPrint('🚗 [BackgroundGps] No access token available');
      return;
    }

    String wsUrl = AppConfig.baseUrl;
    if (wsUrl.endsWith('/api')) {
      wsUrl = wsUrl.substring(0, wsUrl.length - 4);
    }

    socket = io.io(
      '$wsUrl/chat',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({
            'Authorization': 'Bearer $token',
            'ngrok-skip-browser-warning': 'true',
          })
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      socket?.emit('join', {'ride_id': rideId});
      debugPrint('🚗 [BackgroundGps] WebSocket connected and joined ride room');
      onSocketConnected(socket!);
    });

    // Start GPS stream with adaptive settings for battery efficiency
    subscription =
        Geolocator.getPositionStream(
          locationSettings:
              BackgroundBatteryHandler.getAdaptiveLocationSettings(),
        ).listen(
          (pos) {
            if (socket != null && socket.connected) {
              socket.emit('trip:gps', {
                'ride_id': rideId,
                'latitude': pos.latitude,
                'longitude': pos.longitude,
                'speed_kmh': pos.speed * 3.6,
                'recorded_at': DateTime.now().toIso8601String(),
              });
            }
          },
          onError: (e) {
            debugPrint('🚗 [BackgroundGps] GPS error: $e');
          },
        );

    debugPrint('🚗 [BackgroundGps] GPS stream started');
  }

  /// Stop GPS and WebSocket connection
  static Future<void> stopGpsAndSocket(
    StreamSubscription<Position>? subscription,
    io.Socket? socket,
  ) async {
    debugPrint('🚗 [BackgroundGps] Stopping GPS tracking');

    await subscription?.cancel();

    if (socket != null) {
      socket.emit('leave', {'ride_id': 'current'});
      socket.disconnect();
      socket.dispose();
    }

    debugPrint('🚗 [BackgroundGps] GPS tracking stopped');
  }
}
