import 'package:flutter/widgets.dart';
import '../../services/driver/driver_service.dart';
import '../../services/background/background_tracking_service.dart';
import '../../services/background/background_permission_handler.dart';
import '../../core/notifications/notification_service.dart';
import 'online_state.dart';
import 'online_time_tracking.dart';
import 'online_heartbeat.dart';

/// Lifecycle logic for OnlineProvider.
/// Handles app lifecycle events, ride tracking, and backend sync.
class OnlineLifecycle {
  final DriverService _driver;
  final OnlineState _state;
  final OnlineTimeTracking _timeTracking;
  final OnlineHeartbeat _heartbeat;
  final Function() onForcedOfflineCallback;
  final Function() onNotifyListeners;

  OnlineLifecycle({
    required DriverService driver,
    required OnlineState state,
    required OnlineTimeTracking timeTracking,
    required OnlineHeartbeat heartbeat,
    required this.onForcedOfflineCallback,
    required this.onNotifyListeners,
  }) : _driver = driver,
       _state = state,
       _timeTracking = timeTracking,
       _heartbeat = heartbeat;

  /// Set the active ride ID for tracking. Call this when a ride is assigned or status changes.
  /// Tracking starts/stops based on ride ID, independent of online status.
  Future<void> setActiveRide(String? rideId) async {
    _state.activeRideId = rideId;

    if (rideId != null) {
      // Check REAL OS permission before starting tracking
      final hasPermission =
          await BackgroundPermissionHandler.checkPermissionsOnly();
      if (hasPermission) {
        debugPrint(
          '🚗 [OnlineLifecycle] Starting background tracking for ride: $rideId',
        );
        BackgroundTrackingService.startTracking(rideId);
      } else {
        debugPrint(
          '🚗 [OnlineLifecycle] Permission denied, not starting tracking for ride: $rideId',
        );
        _state.error =
            'Location permission required for tracking. Enable in settings to track ride.';
        onNotifyListeners();
      }
    } else {
      // Stop tracking when ride is completed/cancelled
      debugPrint(
        '🚗 [OnlineLifecycle] Stopping background tracking (no active ride)',
      );
      BackgroundTrackingService.stopTracking();
    }
  }

  /// Refreshes driver profile stats from the backend without the init guard.
  Future<void> refreshDriverProfile() async {
    try {
      _state.driverProfile = await _driver.getMe();
      onNotifyListeners();
    } catch (_) {
      // Non-fatal — stale data until next natural refresh
    }
  }

  /// Called by Flutter when the app moves between foreground/background.
  Future<void> onAppLifecycleStateChange(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // Start heartbeat when app comes to foreground (device is alive)
      _heartbeat.start();
      // Re-sync status from backend on resume.
      await _syncOnResume();
    } else if (state == AppLifecycleState.paused) {
      // Stop heartbeat when app goes to background
      _heartbeat.stop();
    }
    // Note: detached state is handled by parent dispose() to avoid duplication
  }

  /// Re-fetches driver status from backend on app resume.
  /// If backend says offline but we think we're online → treat as forced offline.
  /// If still online → send an immediate heartbeat to prevent stale sweep.
  Future<void> _syncOnResume() async {
    if (_state.forcedOffline) return; // already handled locally
    try {
      final profile = await _driver.getMe();
      final backendOnline = profile.isOnline;

      if (_state.isOnline && !backendOnline) {
        // Backend marked us offline while we were backgrounded.
        // However, if we have an active ride, the backend sweep may have
        // marked us offline due to heartbeat stopping in background (normal).
        // Only force offline if we truly have no active ride.
        if (_state.activeRideId == null) {
          // No active ride — driver was genuinely inactive
          _state.forcedOffline = true;
          _state.isOnline = false;
          _timeTracking.lastOnlineAt = null;
          _heartbeat.stop();

          // Re-fetch to get the updated monthlyOnlineMs from backend.
          try {
            final updated = await _driver.getMe();
            _timeTracking.backendMonthlyMs = updated.monthlyOnlineMs;
            _state.driverProfile = updated;
          } catch (_) {
            // keep last known value
          }

          _state.error =
              'You went offline due to inactivity. Toggle online to reconnect.';
          NotificationService.instance.showLocalNotification(
            title: '⚠️ You went offline',
            body:
                'Your status was changed to offline due to inactivity. Tap to go back online.',
            payload: 'DRIVER_WENT_OFFLINE',
          );
        } else {
          // Has active ride — backend marked us offline due to heartbeat stopping
          // in background (normal). Don't force offline, just send heartbeat.
          _heartbeat.sendImmediate();
        }
      } else if (_state.isOnline && backendOnline) {
        // Still online — send immediate heartbeat to prevent stale sweep
        _heartbeat.sendImmediate();
      }
    } catch (_) {
      // Non-fatal — sync will retry on next resume
    }
  }

  /// Called when backend FCM arrives telling us we were forced offline.
  void handleForcedOffline() {
    if (!_state.isOnline) return; // already offline locally
    // Ignore forced offline if driver has an active ride
    if (_state.activeRideId != null) {
      debugPrint(
        '🚗 [OnlineLifecycle] Ignoring forced offline — active ride ${_state.activeRideId}',
      );
      _heartbeat.sendImmediate();
      return;
    }
    _state.forcedOffline = true;
    _state.isOnline = false;
    _timeTracking.lastOnlineAt = null;
    _heartbeat.stop();
    _state.error =
        'You went offline due to inactivity. Toggle online to reconnect.';
    onForcedOfflineCallback();
  }
}
