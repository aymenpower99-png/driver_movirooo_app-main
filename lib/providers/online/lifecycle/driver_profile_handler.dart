import 'package:flutter/foundation.dart';
import '../../../services/driver/driver_service.dart';
import '../../../services/dispatch/dispatch_service.dart';
import '../../../services/background/background_tracking_service.dart';
import '../../../core/notifications/notification_service.dart';
import '../online_state.dart';
import '../online_time_tracking.dart';
import '../online_persistence.dart';
import '../online_heartbeat.dart';
import '../online_gps.dart';

/// Handles driver profile loading and refreshing.
/// Manages initial state loading, migration, and profile refresh from backend.
class DriverProfileHandler {
  final DriverService _driver;
  final DispatchService _dispatch;
  final OnlineState _state;
  final OnlineTimeTracking _timeTracking;
  final OnlinePersistence _persistence;
  final OnlineHeartbeat _heartbeat;
  final OnlineGps _gps;
  final Function() onNotifyListeners;

  DriverProfileHandler({
    required DriverService driver,
    required DispatchService dispatch,
    required OnlineState state,
    required OnlineTimeTracking timeTracking,
    required OnlinePersistence persistence,
    required OnlineHeartbeat heartbeat,
    required OnlineGps gps,
    required this.onNotifyListeners,
  }) : _driver = driver,
       _dispatch = dispatch,
       _state = state,
       _timeTracking = timeTracking,
       _persistence = persistence,
       _heartbeat = heartbeat,
       _gps = gps;

  /// Load initial driver state (runs once)
  Future<void> loadDriverProfile({
    required void Function() registerLifecycleObserver,
    required void Function() onForcedOfflineCallback,
  }) async {
    if (_state.initialized) return;
    _state.initialized = true;
    await _persistence.loadPersistedTime();
    // Register lifecycle observer
    registerLifecycleObserver();
    // Listen for backend-forced offline via FCM
    NotificationService.instance.onDriverForcedOffline =
        onForcedOfflineCallback;
    try {
      _state.driverProfile = await _driver.getMe();
      // Sync online status with backend
      _state.isOnline = _state.driverProfile!.isOnline;

      // Seed monthly time from backend
      _timeTracking.backendMonthlyMs = _state.driverProfile!.monthlyOnlineMs;

      // ── One-time migration from legacy SharedPreferences ─────────────────
      if (_timeTracking.backendMonthlyMs == 0 &&
          _timeTracking.legacyMonthMs > 0) {
        final currentMonth = _timeTracking.monthStr;
        if (_timeTracking.legacyMonth == currentMonth) {
          _timeTracking.backendMonthlyMs = _timeTracking.legacyMonthMs;
          _driver
              .seedMonthlyOnlineTime(_timeTracking.legacyMonthMs, currentMonth)
              .then((_) async {
                await _persistence.clearLegacyKeys();
              })
              .catchError((_) {});
        }
      }

      if (_state.isOnline) {
        _timeTracking.lastOnlineAt =
            _state.driverProfile!.onlineSince ?? DateTime.now();
        _timeTracking.startUiTimer();
        // Start heartbeat and background services if driver is online
        _heartbeat.start();
        await BackgroundTrackingService.start();
        // Check for active ride and start GPS tracking if needed
        try {
          final rides = await _dispatch.getDriverRides();
          final activeRides = rides
              .where(
                (r) =>
                    r.status == 'ASSIGNED' ||
                    r.status == 'EN_ROUTE_TO_PICKUP' ||
                    r.status == 'ARRIVED' ||
                    r.status == 'IN_TRIP',
              )
              .toList();
          if (activeRides.isNotEmpty) {
            _state.activeRideId = activeRides.first.id;
            BackgroundTrackingService.startTracking(_state.activeRideId!);
          }
        } catch (e) {
          debugPrint('🚗 [DriverProfile] Failed to check for active ride: $e');
        }
      }
      onNotifyListeners();
    } catch (_) {
      // Non-fatal — keep UI working
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

  /// Refresh monthly online time from backend to keep Earnings page in sync
  Future<void> refreshMonthlyTime() async {
    try {
      final updated = await _driver.getMe();
      _timeTracking.backendMonthlyMs = updated.monthlyOnlineMs;
      _state.driverProfile = updated;
      onNotifyListeners();
      debugPrint('🚗 [DriverProfile] Monthly time refreshed from backend');
    } catch (e) {
      debugPrint('🚗 [DriverProfile] Failed to refresh monthly time: $e');
    }
  }
}
