import 'package:flutter/foundation.dart';
import '../../../services/driver/driver_service.dart';
import '../../../core/notifications/notification_service.dart';
import '../online_state.dart';
import '../online_time_tracking.dart';
import '../online_persistence.dart';

/// Handles driver profile loading and refreshing.
/// Manages initial state loading, migration, and profile refresh from backend.
class DriverProfileHandler {
  final DriverService _driver;
  final OnlineState _state;
  final OnlineTimeTracking _timeTracking;
  final OnlinePersistence _persistence;
  final Function() onNotifyListeners;

  DriverProfileHandler({
    required DriverService driver,
    required OnlineState state,
    required OnlineTimeTracking timeTracking,
    required OnlinePersistence persistence,
    required this.onNotifyListeners,
  }) : _driver = driver,
       _state = state,
       _timeTracking = timeTracking,
       _persistence = persistence;

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
    NotificationService.instance.onDriverForcedOffline = onForcedOfflineCallback;
    try {
      _state.driverProfile = await _driver.getMe();
      // Keep driver offline by default on app restart
      _state.isOnline = false;

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
