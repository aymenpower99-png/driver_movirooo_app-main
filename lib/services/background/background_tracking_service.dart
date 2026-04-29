import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'background_gps_handler.dart';

/// Background service for GPS tracking.
///
/// Architecture:
///   Main isolate  ──invoke('start_tracking')──▶  Background isolate
///                  ◀──invoke('gps_update')──────  (sends GPS back to UI)
///
/// The background isolate owns the GPS stream and the WebSocket connection.
/// GPS positions are both sent to the backend AND forwarded to the main
/// isolate so the map UI can update even after the user leaves the screen.
class BackgroundTrackingService {
  static final FlutterBackgroundService _service = FlutterBackgroundService();

  // ── Main-isolate API ──────────────────────────────────────────────────────

  /// Initialize the background service. Call once at app start.
  static Future<void> initialize() async {
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'moviroo_tracking',
        initialNotificationTitle: 'Moviroo Driver',
        initialNotificationContent: 'Tracking location...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
    );
  }

  /// Start the background service (does NOT start GPS — call [startTracking]).
  static Future<void> start() async {
    if (await _service.isRunning()) {
      debugPrint('🚗 [BgTrack] Service already running');
      return;
    }
    _service.startService();
    debugPrint('🚗 [BgTrack] Service started');
  }

  /// Stop the background service entirely.
  static Future<void> stop() async {
    _service.invoke('stop');
    debugPrint('🚗 [BgTrack] Sent stop command');
  }

  /// Tell the background isolate to start GPS + WebSocket for [rideId].
  static void startTracking(String rideId) {
    _service.invoke('start_tracking', {'rideId': rideId});
    debugPrint('🚗 [BgTrack] Sent start_tracking for ride=$rideId');
  }

  /// Tell the background isolate to stop GPS + WebSocket.
  static void stopTracking() {
    _service.invoke('stop_tracking');
    debugPrint('🚗 [BgTrack] Sent stop_tracking');
  }

  /// Stream of GPS updates forwarded from the background isolate.
  /// Listen to this in the main isolate to update the map UI.
  static Stream<Map<String, dynamic>?> get onGpsUpdate =>
      _service.on('gps_update');

  // ── Background isolate entry point ────────────────────────────────────────

  @pragma('vm:entry-point')
  static Future<void> _onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    GpsSessionHandle? session;
    String? currentRideId;

    debugPrint('🚗 [BgTrack:isolate] Background isolate started');

    // ── start_tracking command ──────────────────────────────────────────────
    service.on('start_tracking').listen((event) async {
      final rideId = event?['rideId'] as String?;
      if (rideId == null) return;

      debugPrint('🚗 [BgTrack:isolate] start_tracking ride=$rideId');

      // Stop previous session if any
      await BackgroundGpsHandler.stopSession(session);
      session = null;
      currentRideId = rideId;

      session = await BackgroundGpsHandler.startGpsAndSocket(
        rideId,
        onGpsPosition: (pos) {
          // Bridge GPS to main isolate so the map UI receives it
          service.invoke('gps_update', {
            'latitude': pos.latitude,
            'longitude': pos.longitude,
            'speed': pos.speed,
            'heading': pos.heading,
            'timestamp': pos.timestamp.millisecondsSinceEpoch,
          });
        },
      );

      if (session == null) {
        debugPrint('🚗 [BgTrack:isolate] Failed to start GPS session');
      }
    });

    // ── stop_tracking command ───────────────────────────────────────────────
    service.on('stop_tracking').listen((_) async {
      debugPrint('🚗 [BgTrack:isolate] stop_tracking');
      await BackgroundGpsHandler.stopSession(session);
      session = null;
      currentRideId = null;
    });

    // ── stop command (kill service) ─────────────────────────────────────────
    service.on('stop').listen((_) async {
      debugPrint('🚗 [BgTrack:isolate] stop — shutting down');
      await BackgroundGpsHandler.stopSession(session);
      session = null;
      currentRideId = null;
      await service.stopSelf();
    });

    // ── Keep-alive heartbeat (updates notification text) ────────────────────
    Timer.periodic(const Duration(seconds: 30), (_) {
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'Moviroo Driver',
          content: currentRideId != null
              ? 'Tracking active ride'
              : 'Online — waiting for ride',
        );
      }
    });
  }

  /// iOS background callback
  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();
    return true;
  }
}
