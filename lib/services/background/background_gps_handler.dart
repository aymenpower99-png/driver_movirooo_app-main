import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/config/app_config.dart';
import '../../core/storage/token_storage.dart';
import 'background_permission_handler.dart';

/// Result of [startGpsAndSocket] — holds the live references so the caller
/// can later stop them.  This avoids the Dart pass-by-value pitfall that
/// previously caused the socket / subscription to be silently lost.
class GpsSessionHandle {
  io.Socket socket;
  StreamSubscription<Position> gpsSubscription;
  GpsSessionHandle({required this.socket, required this.gpsSubscription});
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
    debugPrint('🚗 [BackgroundGps] Starting GPS tracking for ride: $rideId');

    // Check and request permissions
    final hasPermissions =
        await BackgroundPermissionHandler.checkAndRequestPermissions();
    if (!hasPermissions) {
      debugPrint('🚗 [BackgroundGps] Required permissions not granted');
      return null;
    }

    // Connect to WebSocket
    final token = await TokenStorage.getAccess();
    if (token == null) {
      debugPrint('🚗 [BackgroundGps] No access token available');
      return null;
    }

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

    socket.connect();

    socket.onConnect((_) {
      socket.emit('join', {'ride_id': rideId});
      debugPrint(
        '🚗 [BackgroundGps] WebSocket connected & joined room ride=$rideId',
      );
    });

    socket.onDisconnect((_) {
      debugPrint('🚗 [BackgroundGps] WebSocket disconnected');
    });

    socket.onConnectError((e) {
      debugPrint('🚗 [BackgroundGps] WebSocket connect error: $e');
    });

    // ── GPS stream ──────────────────────────────────────────────────────────
    // On Android we MUST use AndroidSettings with a foreground notification
    // so the OS keeps delivering GPS while the activity is invisible.
    final LocationSettings locationSettings;
    if (Platform.isAndroid) {
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

    final gpsSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (pos) {
            debugPrint(
              '🚗 [BackgroundGps] GPS → lat=${pos.latitude}, lng=${pos.longitude}',
            );

            // Send to backend via WebSocket
            if (socket.connected) {
              socket.emit('trip:gps', {
                'ride_id': rideId,
                'latitude': pos.latitude,
                'longitude': pos.longitude,
                'speed_kmh': pos.speed * 3.6,
                'recorded_at': DateTime.now().toIso8601String(),
              });
              debugPrint('🚗 [BackgroundGps] trip:gps emitted ✓');
            } else {
              debugPrint(
                '🚗 [BackgroundGps] trip:gps SKIPPED — socket not connected',
              );
            }

            // Notify caller (so it can bridge to UI isolate)
            onGpsPosition?.call(pos);
          },
          onError: (e) {
            debugPrint('🚗 [BackgroundGps] GPS error: $e');
          },
        );

    debugPrint('🚗 [BackgroundGps] GPS stream started ✓');

    return GpsSessionHandle(socket: socket, gpsSubscription: gpsSubscription);
  }

  /// Stop GPS and WebSocket connection.
  static Future<void> stopSession(GpsSessionHandle? handle) async {
    if (handle == null) {
      debugPrint('🚗 [BackgroundGps] stopSession — nothing to stop');
      return;
    }
    debugPrint('🚗 [BackgroundGps] Stopping GPS tracking');

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
