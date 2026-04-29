import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'background_gps_handler.dart';
import 'background_socket_handler.dart';

/// Background service handler for GPS tracking.
/// Runs in a separate isolate to keep tracking alive when app is backgrounded.
/// This is the main coordinator that orchestrates the specialized handlers.
class BackgroundTrackingService {
  static const String _channel = 'moviroo.tracking';
  static final FlutterBackgroundService _service = FlutterBackgroundService();
  static const _maxReconnectAttempts = 10;

  /// Initialize the background service
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

  /// Start the background service
  static Future<void> start() async {
    if (await _service.isRunning()) {
      debugPrint('🚗 [BackgroundTracking] Service already running');
      return;
    }
    _service.startService();
    debugPrint('🚗 [BackgroundTracking] Service started');
  }

  /// Stop the background service
  static Future<void> stop() async {
    _service.invoke('stop');
    debugPrint('🚗 [BackgroundTracking] Sent stop command');
  }

  /// Send a command to start tracking for a specific ride
  static Future<void> startTracking(String rideId) async {
    _service.invoke('start_tracking', {'rideId': rideId});
    debugPrint(
      '🚗 [BackgroundTracking] Sent start_tracking command for ride: $rideId',
    );
  }

  /// Send a command to stop tracking
  static Future<void> stopTracking() async {
    _service.invoke('stop_tracking');
    debugPrint('🚗 [BackgroundTracking] Sent stop_tracking command');
  }

  /// Called when the background service starts (Android and iOS foreground)
  @pragma('vm:entry-point')
  static Future<void> _onStart(ServiceInstance service) async {
    if (kDebugMode) {
      DartPluginRegistrant.ensureInitialized();
    }

    io.Socket? _socket;
    StreamSubscription<Position>? _gpsSubscription;
    String? _currentRideId;
    Timer? _reconnectTimer;
    int _reconnectAttempts = 0;

    // Handle incoming commands from the UI
    service.on(_channel).listen((event) {
      if (event == null) return;
      final command = event['command'];
      debugPrint('🚗 [BackgroundTracking] Received command: $command');

      switch (command) {
        case 'start_tracking':
          final rideId = event['rideId'];
          if (rideId != null) {
            _currentRideId = rideId;
            _reconnectAttempts = 0; // Reset reconnect attempts on new ride
            BackgroundGpsHandler.startGpsAndSocket(
              rideId,
              _socket,
              _gpsSubscription,
              (socket) {
                _socket = socket;
                BackgroundSocketHandler.setupSocketReconnect(
                  socket,
                  rideId,
                  _reconnectTimer,
                  _reconnectAttempts,
                  (timer, newAttempts) {
                    _reconnectAttempts = newAttempts;
                    if (_reconnectAttempts <= _maxReconnectAttempts) {
                      final delay = Duration(
                        seconds: BackgroundSocketHandler.calculateBackoff(
                          _reconnectAttempts,
                        ),
                      );
                      debugPrint(
                        '🚗 [BackgroundTracking] Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)',
                      );
                      timer?.cancel();
                      _reconnectTimer = Timer(delay, () {
                        BackgroundSocketHandler.reconnectSocket(rideId, (
                          newSocket,
                        ) {
                          _socket = newSocket;
                          // Reset reconnect attempts on successful reconnection
                          _reconnectAttempts = 0;
                        });
                      });
                    } else {
                      debugPrint(
                        '🚗 [BackgroundTracking] Max reconnect attempts reached, giving up',
                      );
                    }
                  },
                );
              },
            );
          }
          break;
        case 'stop_tracking':
          _reconnectTimer?.cancel();
          _reconnectAttempts = 0;
          BackgroundGpsHandler.stopGpsAndSocket(_gpsSubscription, _socket);
          _currentRideId = null;
          break;
        case 'stop':
          _reconnectTimer?.cancel();
          BackgroundGpsHandler.stopGpsAndSocket(_gpsSubscription, _socket);
          _service.invoke('stop_service');
          break;
      }
    });

    // Set up periodic heartbeat to keep service alive
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      service.invoke('set_notification', {
        'title': 'Moviroo Driver',
        'content': _currentRideId != null
            ? 'Tracking active ride'
            : 'Online - waiting for ride',
      });
    });
  }

  /// iOS background callback
  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    return true;
  }
}
