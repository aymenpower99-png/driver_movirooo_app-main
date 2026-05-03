import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import '../../../services/driver/driver_service.dart';
import '../../../services/dispatch/dispatch_service.dart';
import '../../../services/background/background_tracking_service.dart';
import '../../../core/notifications/notification_service.dart';
import '../online_state.dart';
import '../online_time_tracking.dart';
import '../online_persistence.dart';
import '../online_heartbeat.dart';

/// Handles app lifecycle events.
/// Manages app foreground/background transitions, resume sync, and forced offline.
class AppLifecycleHandler {
  final DriverService _driver;
  final DispatchService _dispatch;
  final OnlineState _state;
  final OnlineTimeTracking _timeTracking;
  final OnlineHeartbeat _heartbeat;
  final OnlinePersistence _persistence;
  final Function() onForcedOfflineCallback;
  final Function() onNotifyListeners;

  AppLifecycleHandler({
    required DriverService driver,
    required DispatchService dispatch,
    required OnlineState state,
    required OnlineTimeTracking timeTracking,
    required OnlineHeartbeat heartbeat,
    required OnlinePersistence persistence,
    required this.onForcedOfflineCallback,
    required this.onNotifyListeners,
  }) : _driver = driver,
       _dispatch = dispatch,
       _state = state,
       _timeTracking = timeTracking,
       _heartbeat = heartbeat,
       _persistence = persistence;

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
    } else if (state == AppLifecycleState.detached) {
      // App is being killed
      if (_state.activeRideId != null) {
        // Driver is in an active ride → keep tracking alive
        debugPrint(
          '🚗 [AppLifecycle] App detached but active ride ${_state.activeRideId} - keeping service running',
        );
        return;
      }

      // No active ride → safe to go offline
      debugPrint(
        '🚗 [AppLifecycle] App detached - stopping background service and going offline',
      );

      BackgroundTrackingService.stopTracking();
      await BackgroundTrackingService.stop();

      if (_state.isOnline) {
        // Persist session time before going offline
        if (_timeTracking.lastOnlineAt != null) {
          final sessionMs = _timeTracking.getSessionMs(_state.isOnline);
          _timeTracking.addSessionTime(sessionMs);
          await _persistence.persistTime();
          // Note: backend session time accumulation happens when goOffline is called below.
        }
        try {
          await _dispatch.goOffline();
          debugPrint('🚗 [AppLifecycle] Successfully went offline on detach');
        } catch (e) {
          debugPrint('🚗 [AppLifecycle] Failed to go offline on detach: $e');
        }

        _state.isOnline = false;
        _timeTracking.lastOnlineAt = null;
      }
    }
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
        '🚗 [AppLifecycle] Ignoring forced offline — active ride ${_state.activeRideId}',
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

  /// Dispose of all resources
  void dispose({required void Function() stopMonthlyRefreshTimer}) {
    debugPrint(
      '🚗 [AppLifecycle] Disposing - stopping all services and going offline',
    );
    // Persist current session time if online, so it doesn't reset on app reopen
    if (_state.isOnline && _timeTracking.lastOnlineAt != null) {
      final sessionMs = _timeTracking.getSessionMs(_state.isOnline);
      _timeTracking.addSessionTime(sessionMs);
      _persistence.persistTime().catchError((e) {
        debugPrint('🚗 [AppLifecycle] Failed to persist time on dispose: $e');
      });
      // Note: backend session time accumulation happens when goOffline is called below.
    }
    _heartbeat.stop();
    _timeTracking.dispose();
    stopMonthlyRefreshTimer();
    // Stop background tracking service when provider is disposed (app closed)
    BackgroundTrackingService.stopTracking();
    BackgroundTrackingService.stop();

    // Call backend goOffline to ensure driver goes offline in database
    if (_state.isOnline) {
      _dispatch.goOffline().catchError((e) {
        debugPrint('🚗 [AppLifecycle] Failed to call goOffline on dispose: $e');
      });
    }

    _state.isOnline = false;
    _timeTracking.lastOnlineAt = null;
  }
}
