import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
    // Create notification channel for Android
    final FlutterLocalNotificationsPlugin notifications =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );
    await notifications.initialize(initializationSettings);

    // Create the notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'moviroo_tracking',
      'Moviroo Driver Tracking',
      description: 'Shows driver location tracking status',
      importance: Importance.low,
    );
    await notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: backgroundServiceOnStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'moviroo_tracking',
        initialNotificationTitle: 'Moviroo Driver',
        initialNotificationContent: 'Tracking location...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: backgroundServiceOnStart,
        onBackground: backgroundServiceIosBackground,
      ),
    );
  }

  /// Start the background service (does NOT start GPS — call [startTracking]).
  static Future<void> start() async {
    debugPrint('🚗 [BgTrack] Attempting to start background service...');
    final isRunning = await _service.isRunning();
    debugPrint('🚗 [BgTrack] Service isRunning: $isRunning');
    if (isRunning) {
      debugPrint('🚗 [BgTrack] Service already running - skipping start');
      return;
    }
    _service.startService();
    debugPrint('🚗 [BgTrack] Service startService() called');
    // Wait a moment and verify it started
    await Future.delayed(const Duration(milliseconds: 500));
    final nowRunning = await _service.isRunning();
    debugPrint('🚗 [BgTrack] Service isRunning after start: $nowRunning');
  }

  /// Stop the background service entirely.
  static Future<void> stop() async {
    debugPrint('🚗 [BgTrack] Sending stop command to isolate');
    _service.invoke('stop');
    debugPrint('🚗 [BgTrack] Sent stop command');
  }

  /// Tell the background isolate to start GPS + WebSocket for [rideId].
  static void startTracking(String rideId) async {
    debugPrint('🚗 [BgTrack] === START TRACKING REQUEST ===');
    debugPrint('🚗 [BgTrack] Ride ID: $rideId');
    final isRunning = await _service.isRunning();
    debugPrint('🚗 [BgTrack] Service isRunning before invoke: $isRunning');
    if (!isRunning) {
      debugPrint(
        '🚗 [BgTrack] ⚠️ WARNING: Service is NOT running! Command will be ignored.',
      );
      debugPrint('🚗 [BgTrack] Attempting to start service now...');
      await start();
    }
    _service.invoke('start_tracking', {'rideId': rideId});
    debugPrint('🚗 [BgTrack] Sent start_tracking command to isolate');
    debugPrint('🚗 [BgTrack] === END START TRACKING REQUEST ===');
  }

  /// Tell the background isolate to stop GPS + WebSocket.
  static void stopTracking() {
    debugPrint('🚗 [BgTrack] Sending stop_tracking command to isolate');
    _service.invoke('stop_tracking');
    debugPrint('🚗 [BgTrack] Sent stop_tracking command');
  }

  /// Stream of GPS updates forwarded from the background isolate.
  /// Listen to this in the main isolate to update the map UI.
  static Stream<Map<String, dynamic>?> get onGpsUpdate =>
      _service.on('gps_update');

  /// Whether the background service is currently running (debug/UI use).
  static Future<bool> isRunning() => _service.isRunning();
}

// ── Background isolate entry point (must be top-level function) ────────────────

@pragma('vm:entry-point')
Future<void> backgroundServiceOnStart(ServiceInstance service) async {
  debugPrint('🚗 [BgTrack:isolate] === ISOLATE ENTRY POINT CALLED ===');
  DartPluginRegistrant.ensureInitialized();
  debugPrint('🚗 [BgTrack:isolate] DartPluginRegistrant initialized');

  GpsSessionHandle? session;
  String? currentRideId;

  debugPrint('🚗 [BgTrack:isolate] Setting up command listeners...');

  // ── start_tracking command ──────────────────────────────────────────────
  service.on('start_tracking').listen((event) async {
    debugPrint('🚗 [BgTrack:isolate] === START_TRACKING COMMAND RECEIVED ===');
    debugPrint('🚗 [BgTrack:isolate] Event data: $event');
    final rideId = event?['rideId'] as String?;
    if (rideId == null) {
      debugPrint('🚗 [BgTrack:isolate] ⚠️ rideId is null, ignoring command');
      return;
    }

    debugPrint('🚗 [BgTrack:isolate] Starting GPS session for ride=$rideId');

    // Stop previous session if any
    if (session != null) {
      debugPrint('🚗 [BgTrack:isolate] Stopping previous session...');
      await BackgroundGpsHandler.stopSession(session);
      session = null;
    }
    currentRideId = rideId;

    debugPrint(
      '🚗 [BgTrack:isolate] Calling BackgroundGpsHandler.startGpsAndSocket...',
    );
    session = await BackgroundGpsHandler.startGpsAndSocket(
      rideId,
      onGpsPosition: (pos) {
        // Bridge GPS to main isolate so the map UI receives it
        debugPrint(
          '🚗 [BgTrack:isolate] GPS position received, bridging to main isolate',
        );
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
      debugPrint(
        '🚗 [BgTrack:isolate] ❌ FAILED to start GPS session (returned null)',
      );
    } else {
      debugPrint('🚗 [BgTrack:isolate] ✅ GPS session started successfully');
    }
    debugPrint('🚗 [BgTrack:isolate] === START_TRACKING COMMAND COMPLETE ===');
  });

  // ── stop_tracking command ───────────────────────────────────────────────
  service.on('stop_tracking').listen((_) async {
    debugPrint('🚗 [BgTrack:isolate] === STOP_TRACKING COMMAND RECEIVED ===');
    debugPrint('🚗 [BgTrack:isolate] Stopping GPS session...');
    await BackgroundGpsHandler.stopSession(session);
    session = null;
    currentRideId = null;
    debugPrint('🚗 [BgTrack:isolate] === STOP_TRACKING COMMAND COMPLETE ===');
  });

  // ── stop command (kill service) ─────────────────────────────────────────
  service.on('stop').listen((_) async {
    debugPrint(
      '🚗 [BgTrack:isolate] === STOP COMMAND RECEIVED (shutting down) ===',
    );
    await BackgroundGpsHandler.stopSession(session);
    session = null;
    currentRideId = null;
    await service.stopSelf();
    debugPrint('🚗 [BgTrack:isolate] Service stopped');
  });

  debugPrint('🚗 [BgTrack:isolate] Command listeners set up, isolate ready');
  debugPrint('🚗 [BgTrack:isolate] === ISOLATE INITIALIZED ===');

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
Future<bool> backgroundServiceIosBackground(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  return true;
}
