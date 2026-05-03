import 'dart:async';
import 'package:flutter/widgets.dart';
import '../services/dispatch/dispatch_service.dart';
import '../services/driver/driver_service.dart';
import '../services/background/permission_state_storage.dart';
import '../core/models/driver_model.dart';
import 'online/online_state.dart';
import 'online/online_time_tracking.dart';
import 'online/online_persistence.dart';
import 'online/online_heartbeat.dart';
import 'online/online_gps.dart';
import 'online/online_lifecycle.dart';

/// Main OnlineProvider that orchestrates all child modules.
/// Handles driver online/offline status, GPS tracking, and time tracking.
class OnlineProvider extends ChangeNotifier with WidgetsBindingObserver {
  // Services
  final DispatchService _dispatch = DispatchService();
  final DriverService _driver = DriverService();

  // Child modules
  final OnlineState _state = OnlineState();
  late final OnlineTimeTracking _timeTracking;
  late final OnlinePersistence _persistence;
  late final OnlineHeartbeat _heartbeat;
  late final OnlineGps _gps;
  late final OnlineLifecycle _lifecycle;

  // Getters - delegate to child modules
  bool get isOnline => _state.isOnline;
  bool get loading => _state.loading;
  String? get error => _state.error;
  DriverModel? get driverProfile => _state.driverProfile;
  bool get gpsRequired => _state.gpsRequired;
  bool get permissionRequired => _state.permissionRequired;

  /// Alias for backward compatibility
  String get onlineTimeFormatted => _timeTracking.getTodayFormatted(
    _timeTracking.getSessionMs(_state.isOnline),
  );

  String get todayOnlineFormatted => _timeTracking.getTodayFormatted(
    _timeTracking.getSessionMs(_state.isOnline),
  );

  String get monthOnlineFormatted => _timeTracking.getMonthFormatted(
    _timeTracking.getSessionMs(_state.isOnline),
  );

  String get allTimeOnlineFormatted => _timeTracking.getAllTimeFormatted(
    _timeTracking.getSessionMs(_state.isOnline),
  );

  /// Check if background location permission is granted
  Future<bool> get hasBackgroundPermission async {
    return await _state.hasBackgroundPermission;
  }

  /// Get current permission state
  Future<PermissionState> get permissionState async {
    return await _state.permissionState;
  }

  /// Refresh monthly online time from backend to keep Earnings page in sync
  Future<void> refreshMonthlyTime() async {
    await _lifecycle.refreshMonthlyTime();
  }

  /// Start periodic monthly time refresh during online sessions
  void _startMonthlyRefreshTimer() {
    _timeTracking.startMonthlyRefreshTimer(refreshMonthlyTime);
  }

  /// Stop periodic monthly time refresh timer
  void _stopMonthlyRefreshTimer() {
    _timeTracking.stopMonthlyRefreshTimer();
  }

  OnlineProvider() {
    _timeTracking = OnlineTimeTracking(onTickCallback: notifyListeners);
    _persistence = OnlinePersistence(_timeTracking);
    _heartbeat = OnlineHeartbeat(
      dispatch: _dispatch,
      state: _state,
      onConnectionLost: () => notifyListeners(),
    );
    _gps = OnlineGps();
    _lifecycle = OnlineLifecycle(
      driver: _driver,
      dispatch: _dispatch,
      state: _state,
      timeTracking: _timeTracking,
      heartbeat: _heartbeat,
      persistence: _persistence,
      gps: _gps,
      onForcedOfflineCallback: () {
        notifyListeners();
      },
      onNotifyListeners: notifyListeners,
    );
  }

  // ── Load initial driver state (runs once) ─────────────────────────────────
  Future<void> loadDriverProfile() async {
    await _lifecycle.loadDriverProfile(
      registerLifecycleObserver: () =>
          WidgetsBinding.instance.addObserver(this),
      onForcedOfflineCallback: () => notifyListeners(),
    );
  }

  /// Called by Flutter when the app moves between foreground/background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycle.onAppLifecycleStateChange(state);
  }

  /// Set the active ride ID for tracking. Delegates to lifecycle module.
  Future<void> setActiveRide(String? rideId) async {
    await _lifecycle.setActiveRide(rideId);
  }

  // ── Toggle ────────────────────────────────────────────────────────────────
  Future<void> toggleOnline() async {
    await _lifecycle.toggleOnline(
      startMonthlyRefreshTimer: _startMonthlyRefreshTimer,
      stopMonthlyRefreshTimer: _stopMonthlyRefreshTimer,
    );
  }

  void clearGpsRequired() {
    _state.clearGpsRequired();
    notifyListeners();
  }

  void clearPermissionRequired() {
    _state.clearPermissionRequired();
    notifyListeners();
  }

  void clearError() {
    _state.clearError();
    notifyListeners();
  }

  /// Refreshes driver profile stats from the backend. Delegates to lifecycle module.
  Future<void> refreshDriverProfile() async {
    await _lifecycle.refreshDriverProfile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lifecycle.dispose(stopMonthlyRefreshTimer: _stopMonthlyRefreshTimer);
    super.dispose();
  }
}
