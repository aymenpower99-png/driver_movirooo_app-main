import 'package:flutter/widgets.dart';
import '../../services/driver/driver_service.dart';
import '../../services/dispatch/dispatch_service.dart';
import 'online_state.dart';
import 'online_time_tracking.dart';
import 'online_persistence.dart';
import 'online_gps.dart';
import 'online_heartbeat.dart';
import 'lifecycle/lifecycle_exports.dart';

/// Lifecycle logic for OnlineProvider.
/// Coordinates lifecycle handlers for ride tracking, driver profile, online toggle, and app lifecycle.
class OnlineLifecycle {
  final DriverService _driver;
  final DispatchService _dispatch;
  final OnlineState _state;
  final OnlineTimeTracking _timeTracking;
  final OnlineHeartbeat _heartbeat;
  final OnlinePersistence _persistence;
  final OnlineGps _gps;
  final Function() onForcedOfflineCallback;
  final Function() onNotifyListeners;

  late final RideTrackingHandler _rideTracking;
  late final DriverProfileHandler _driverProfile;
  late final OnlineToggleHandler _onlineToggle;
  late final AppLifecycleHandler _appLifecycle;

  OnlineLifecycle({
    required DriverService driver,
    required DispatchService dispatch,
    required OnlineState state,
    required OnlineTimeTracking timeTracking,
    required OnlineHeartbeat heartbeat,
    required OnlinePersistence persistence,
    required OnlineGps gps,
    required this.onForcedOfflineCallback,
    required this.onNotifyListeners,
  }) : _driver = driver,
       _dispatch = dispatch,
       _state = state,
       _timeTracking = timeTracking,
       _heartbeat = heartbeat,
       _persistence = persistence,
       _gps = gps {
    _rideTracking = RideTrackingHandler(
      state: _state,
      onNotifyListeners: onNotifyListeners,
    );
    _driverProfile = DriverProfileHandler(
      driver: _driver,
      state: _state,
      timeTracking: _timeTracking,
      persistence: _persistence,
      onNotifyListeners: onNotifyListeners,
    );
    _onlineToggle = OnlineToggleHandler(
      dispatch: _dispatch,
      driver: _driver,
      state: _state,
      timeTracking: _timeTracking,
      heartbeat: _heartbeat,
      persistence: _persistence,
      gps: _gps,
      onNotifyListeners: onNotifyListeners,
    );
    _appLifecycle = AppLifecycleHandler(
      driver: _driver,
      dispatch: _dispatch,
      state: _state,
      timeTracking: _timeTracking,
      heartbeat: _heartbeat,
      persistence: _persistence,
      onForcedOfflineCallback: onForcedOfflineCallback,
      onNotifyListeners: onNotifyListeners,
    );
  }

  /// Set the active ride ID for tracking. Delegates to ride tracking handler.
  Future<void> setActiveRide(String? rideId) async {
    await _rideTracking.setActiveRide(rideId);
  }

  /// Load initial driver state. Delegates to driver profile handler.
  Future<void> loadDriverProfile({
    required void Function() registerLifecycleObserver,
    required void Function() onForcedOfflineCallback,
  }) async {
    await _driverProfile.loadDriverProfile(
      registerLifecycleObserver: registerLifecycleObserver,
      onForcedOfflineCallback: onForcedOfflineCallback,
    );
  }

  /// Refreshes driver profile stats from backend. Delegates to driver profile handler.
  Future<void> refreshDriverProfile() async {
    await _driverProfile.refreshDriverProfile();
  }

  /// Refresh monthly online time from backend. Delegates to driver profile handler.
  Future<void> refreshMonthlyTime() async {
    await _driverProfile.refreshMonthlyTime();
  }

  /// Toggle online/offline status. Delegates to online toggle handler.
  Future<void> toggleOnline({
    required void Function() startMonthlyRefreshTimer,
    required void Function() stopMonthlyRefreshTimer,
  }) async {
    await _onlineToggle.toggleOnline(
      startMonthlyRefreshTimer: startMonthlyRefreshTimer,
      stopMonthlyRefreshTimer: stopMonthlyRefreshTimer,
    );
  }

  /// Called by Flutter when app moves between foreground/background. Delegates to app lifecycle handler.
  Future<void> onAppLifecycleStateChange(AppLifecycleState state) async {
    await _appLifecycle.onAppLifecycleStateChange(state);
  }

  /// Called when backend FCM arrives telling us we were forced offline. Delegates to app lifecycle handler.
  void handleForcedOffline() {
    _appLifecycle.handleForcedOffline();
  }

  /// Dispose of all resources. Delegates to app lifecycle handler.
  void dispose({required void Function() stopMonthlyRefreshTimer}) {
    _appLifecycle.dispose(stopMonthlyRefreshTimer: stopMonthlyRefreshTimer);
  }
}
