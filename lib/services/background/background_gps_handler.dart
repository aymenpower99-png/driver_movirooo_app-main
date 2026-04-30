import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/config/app_config.dart';
import '../../core/storage/token_storage.dart';

/// Result of [startGpsAndSocket] — holds the live references so the caller
/// can later stop them.  This avoids the Dart pass-by-value pitfall that
/// previously caused the socket / subscription to be silently lost.
class GpsSessionHandle {
  io.Socket socket;
  StreamSubscription<Position> gpsSubscription;
  Timer? gpsTimeoutTimer;
  GpsSessionHandle({
    required this.socket,
    required this.gpsSubscription,
    this.gpsTimeoutTimer,
  });
}

/// Handles GPS start/stop logic for background tracking.
class BackgroundGpsHandler {
  /// Start GPS streaming and WebSocket connection.
  ///
  /// Returns a [GpsSessionHandle] that the caller MUST keep alive.
  /// [onGpsPosition] fires on every GPS tick so the caller can forward
  /// the position (e.g. to the main isolate via `service.invoke`).
  static Future<GpsSessionHandle?> startGpsAndSocket(
    String rideId, {
    void Function(Position)? onGpsPosition,
  }) async {
    debugPrint('🚗 [BackgroundGps] === START GPS AND SOCKET ===');
    debugPrint('🚗 [BackgroundGps] Ride ID: $rideId');

    // Note: Permissions are checked in the main isolate before starting background service
    // Background isolate cannot reliably check permissions, so we assume granted here

    // Connect to WebSocket
    debugPrint('🚗 [BackgroundGps] Getting access token...');
    final token = await TokenStorage.getAccess();
    debugPrint(
      '🚗 [BackgroundGps] Token obtained: ${token != null ? "YES" : "NO"}',
    );
    if (token == null) {
      debugPrint('🚗 [BackgroundGps] ❌ No access token available - ABORTING');
      return null;
    }

    debugPrint(
      '🚗 [BackgroundGps] Creating WebSocket connection to ${AppConfig.wsBaseUrl}...',
    );
    final socket = io.io(
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

    debugPrint('🚗 [BackgroundGps] Calling socket.connect()...');
    socket.connect();
    debugPrint(
      '🚗 [BackgroundGps] socket.connect() called, waiting for connection...',
    );

    socket.onConnect((_) {
      debugPrint('🚗 [BackgroundGps] ✅ WebSocket CONNECTED');
      debugPrint('🚗 [BackgroundGps] Socket ID: ${socket.id}');
      debugPrint('🚗 [BackgroundGps] Emitting join room for ride=$rideId');
      socket.emit('join', {'ride_id': rideId});
      debugPrint('🚗 [BackgroundGps] ✅ Joined room ride=$rideId');
    });

    socket.onDisconnect((_) {
      debugPrint('🚗 [BackgroundGps] ⚠️ WebSocket DISCONNECTED');
    });

    socket.onConnectError((e) {
      debugPrint('🚗 [BackgroundGps] ❌ WebSocket CONNECT ERROR: $e');
    });

    // ── GPS stream ──────────────────────────────────────────────────────────
    // On Android we MUST use AndroidSettings with a foreground notification
    // so the OS keeps delivering GPS while the activity is invisible.
    debugPrint('🚗 [BackgroundGps] Setting up GPS stream...');
    final LocationSettings locationSettings;
    if (Platform.isAndroid) {
      debugPrint(
        '🚗 [BackgroundGps] Platform: Android - using AndroidSettings',
      );
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        // Keep GPS alive when the Activity is no longer in the foreground.
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Moviroo Driver',
          notificationText: 'Tracking your location...',
          notificationChannelName: 'Background Location',
          enableWakeLock: true,
        ),
      );
    } else {
      debugPrint('🚗 [BackgroundGps] Platform: iOS - using AppleSettings');
      // iOS — use AppleSettings for background delivery
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        activityType: ActivityType.automotiveNavigation,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    }

    debugPrint('🚗 [BackgroundGps] Starting Geolocator.getPositionStream...');

    // GPS timeout detection - 30s without GPS position
    Timer? gpsTimeoutTimer;

    final gpsSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (pos) {
            debugPrint(
              '🚗 [BackgroundGps] 📍 GPS POSITION RECEIVED: lat=${pos.latitude}, lng=${pos.longitude}, speed=${pos.speed}',
            );

            // Reset GPS timeout timer on each position
            gpsTimeoutTimer?.cancel();
            gpsTimeoutTimer = Timer(const Duration(seconds: 30), () {
              debugPrint(
                '🚗 [BackgroundGps] ⚠️ GPS TIMEOUT - No position for 30s',
              );
              if (socket.connected) {
                debugPrint(
                  '🚗 [BackgroundGps] Emitting gps_unavailable to backend...',
                );
                socket.emit('gps_unavailable', {'ride_id': rideId});
                debugPrint(
                  '🚗 [BackgroundGps] ✅ gps_unavailable EMITTED to backend',
                );
              }
            });

            // Send to backend via WebSocket
            debugPrint(
              '🚗 [BackgroundGps] Socket connected: ${socket.connected}',
            );
            if (socket.connected) {
              debugPrint('🚗 [BackgroundGps] Emitting trip:gps to backend...');
              socket.emit('trip:gps', {
                'ride_id': rideId,
                'latitude': pos.latitude,
                'longitude': pos.longitude,
                'speed_kmh': pos.speed * 3.6,
                'recorded_at': DateTime.now().toIso8601String(),
              });
              debugPrint('🚗 [BackgroundGps] ✅ trip:gps EMITTED to backend');
            } else {
              debugPrint(
                '🚗 [BackgroundGps] ⚠️ trip:gps SKIPPED — socket not connected',
              );
            }

            // Notify caller (so it can bridge to UI isolate)
            debugPrint('🚗 [BackgroundGps] Calling onGpsPosition callback...');
            onGpsPosition?.call(pos);
            debugPrint('🚗 [BackgroundGps] onGpsPosition callback completed');
          },
          onError: (e) {
            debugPrint('🚗 [BackgroundGps] ❌ GPS STREAM ERROR: $e');
          },
        );

    debugPrint('🚗 [BackgroundGps] ✅ GPS stream started successfully');
    debugPrint('🚗 [BackgroundGps] === GPS AND SOCKET START COMPLETE ===');

    return GpsSessionHandle(
      socket: socket,
      gpsSubscription: gpsSubscription,
      gpsTimeoutTimer: gpsTimeoutTimer,
    );
  }

  /// Stop GPS and WebSocket connection.
  static Future<void> stopSession(GpsSessionHandle? handle) async {
    if (handle == null) {
      debugPrint('🚗 [BackgroundGps] stopSession — nothing to stop');
      return;
    }
    debugPrint('🚗 [BackgroundGps] Stopping GPS tracking');

    // Cancel GPS timeout timer
    handle.gpsTimeoutTimer?.cancel();

    await handle.gpsSubscription.cancel();

    try {
      handle.socket.emit('leave', {'ride_id': 'current'});
      handle.socket.disconnect();
      handle.socket.dispose();
    } catch (e) {
      debugPrint('🚗 [BackgroundGps] Socket cleanup error: $e');
    }

    debugPrint('🚗 [BackgroundGps] GPS tracking stopped ✓');
  }
}
