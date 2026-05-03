import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../services/dispatch/dispatch_service.dart';
import '../../core/notifications/notification_service.dart';
import 'online_state.dart';

/// Heartbeat logic for OnlineProvider.
/// Handles sending periodic heartbeats to the backend.
class OnlineHeartbeat {
  final DispatchService _dispatch;
  final OnlineState _state;
  final Function() onConnectionLost;

  Timer? _heartbeatTimer;
  int _heartbeatFailCount = 0;
  static const _maxHeartbeatFails = 6; // 6 × 20 s = 120 s (sweep threshold)

  OnlineHeartbeat({
    required DispatchService dispatch,
    required OnlineState state,
    required this.onConnectionLost,
  }) : _dispatch = dispatch,
       _state = state;

  /// Start heartbeat - runs when app is alive (foreground), independent of online status
  void start() {
    _heartbeatTimer?.cancel();
    _heartbeatFailCount = 0;
    // Send heartbeat every 20s. Backend stale threshold is 120s, so this gives
    // 6x redundancy against network hiccups, GPS delays, and background throttling.
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      // Skip heartbeat if driver is offline with no active ride - no need to sync
      if (!_state.isOnline && _state.activeRideId == null) {
        return;
      }
      bool success = false;
      try {
        // Use last-known position only — instant, never blocks the timer.
        final pos = await Geolocator.getLastKnownPosition();
        final driverState = _state.isOnline ? 'online' : 'offline';
        if (pos != null) {
          await _dispatch.heartbeat(
            alive: true,
            driverState: driverState,
            rideId: _state.activeRideId,
            lat: pos.latitude,
            lng: pos.longitude,
          );
        } else {
          await _dispatch.heartbeat(
            alive: true,
            driverState: driverState,
            rideId: _state.activeRideId,
          );
        }
        success = true;
      } catch (_) {
        // Last-resort: bare heartbeat without coords
        try {
          final driverState = _state.isOnline ? 'online' : 'offline';
          await _dispatch.heartbeat(
            alive: true,
            driverState: driverState,
            rideId: _state.activeRideId,
          );
          success = true;
        } catch (_) {}
      }

      if (success) {
        if (_heartbeatFailCount > 0) {
          _heartbeatFailCount = 0;
          // Clear connection error when heartbeat succeeds
          if (_state.error == 'Connection lost. Reconnecting...') {
            _state.error = null;
          }
        }
      } else {
        _heartbeatFailCount++;
        if (_heartbeatFailCount >= _maxHeartbeatFails) {
          // 120s without a successful heartbeat — connection lost
          // Don't change _isOnline (driver's choice), just show connection error
          _heartbeatFailCount = 0; // Reset to allow retry
          _state.error = 'Connection lost. Reconnecting...';

          // Show connection lost notification (not "went offline")
          NotificationService.instance.showLocalNotification(
            title: '⚠️ Connection Lost',
            body: 'Reconnecting to server...',
            payload: 'CONNECTION_LOST',
          );
          onConnectionLost();
        }
      }
    });
  }

  /// Stop heartbeat - called when app goes to background
  void stop() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Send an immediate heartbeat (e.g., on app resume)
  Future<void> sendImmediate() async {
    // Skip heartbeat if driver is offline with no active ride - no need to sync
    if (!_state.isOnline && _state.activeRideId == null) {
      return;
    }
    try {
      final pos = await Geolocator.getLastKnownPosition();
      final driverState = _state.isOnline ? 'online' : 'offline';
      if (pos != null) {
        await _dispatch.heartbeat(
          alive: true,
          driverState: driverState,
          rideId: _state.activeRideId,
          lat: pos.latitude,
          lng: pos.longitude,
        );
      } else {
        await _dispatch.heartbeat(
          alive: true,
          driverState: driverState,
          rideId: _state.activeRideId,
        );
      }
    } catch (_) {
      try {
        final driverState = _state.isOnline ? 'online' : 'offline';
        await _dispatch.heartbeat(
          alive: true,
          driverState: driverState,
          rideId: _state.activeRideId,
        );
      } catch (_) {}
    }
  }

  /// Reset heartbeat fail count (call when going online)
  void resetFailCount() {
    _heartbeatFailCount = 0;
  }
}
