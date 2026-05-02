import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import '../services/dispatch/dispatch_service.dart';
import '../services/driver/driver_service.dart';
import '../services/background/background_tracking_service.dart';
import '../services/background/background_permission_handler.dart';
import '../services/background/permission_state_storage.dart';
import '../core/models/driver_model.dart';
import '../core/notifications/notification_service.dart';
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
  final OnlineTimeTracking _timeTracking = OnlineTimeTracking();
  late final OnlinePersistence _persistence;
  late final OnlineHeartbeat _heartbeat;
  late final OnlineGps _gps;
  late final OnlineLifecycle _lifecycle;

  // UI Timer
  Timer? _uiTimer;

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

  OnlineProvider() {
    _persistence = OnlinePersistence(_timeTracking);
    _heartbeat = OnlineHeartbeat(
      dispatch: _dispatch,
      state: _state,
      onConnectionLost: () => notifyListeners(),
    );
    _gps = OnlineGps();
    _lifecycle = OnlineLifecycle(
      driver: _driver,
      state: _state,
      timeTracking: _timeTracking,
      heartbeat: _heartbeat,
      onForcedOfflineCallback: () {
        notifyListeners();
      },
    );
  }

  // ── Load initial driver state (runs once) ─────────────────────────────────
  Future<void> loadDriverProfile() async {
    if (_state.initialized) return;
    _state.initialized = true;
    await _persistence.loadPersistedTime();
    // Register lifecycle observer
    WidgetsBinding.instance.addObserver(this);
    // Listen for backend-forced offline via FCM
    NotificationService.instance.onDriverForcedOffline =
        _lifecycle.handleForcedOffline;
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
        _startUiTimer();
      }
      notifyListeners();
    } catch (_) {
      // Non-fatal — keep UI working
    }
  }

  /// Called by Flutter when the app moves between foreground/background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycle.onAppLifecycleStateChange(state);
  }

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
          '🚗 [OnlineProvider] Starting background tracking for ride: $rideId',
        );
        BackgroundTrackingService.startTracking(rideId);
      } else {
        debugPrint(
          '🚗 [OnlineProvider] Permission denied, not starting tracking for ride: $rideId',
        );
        _state.error =
            'Location permission required for tracking. Enable in settings to track ride.';
        notifyListeners();
      }
    } else {
      // Stop tracking when ride is completed/cancelled
      debugPrint(
        '🚗 [OnlineProvider] Stopping background tracking (no active ride)',
      );
      BackgroundTrackingService.stopTracking();
    }
  }

  // ── Toggle ────────────────────────────────────────────────────────────────
  Future<void> toggleOnline() async {
    if (_state.loading) return;
    _state.loading = true;
    _state.error = null;
    _state.gpsRequired = false;
    _state.permissionRequired = false;
    notifyListeners();

    try {
      if (_state.isOnline) {
        // ── Going OFFLINE ──────────────────────────────────────────────────
        if (_state.activeRideId != null) {
          NotificationService.instance.showLocalNotification(
            title: 'Cannot Go Offline',
            body: 'You are currently in a trip and cannot go offline.',
          );
          _state.loading = false;
          notifyListeners();
          return;
        }
        try {
          await _dispatch.goOffline();
        } catch (e) {
          if (e.toString().contains('403') ||
              e.toString().contains('Forbidden') ||
              e.toString().contains('trip')) {
            NotificationService.instance.showLocalNotification(
              title: 'Cannot Go Offline',
              body: 'You are currently in a trip and cannot go offline.',
            );
            _state.loading = false;
            notifyListeners();
            return;
          }
          rethrow;
        }
        if (_timeTracking.lastOnlineAt != null) {
          final sessionMs = _timeTracking.getSessionMs(_state.isOnline);
          _timeTracking.addSessionTime(sessionMs);
          await _persistence.persistTime();
        }
        _stopUiTimer();
        _state.isOnline = false;

        if (_state.activeRideId == null) {
          BackgroundTrackingService.stopTracking();
          await BackgroundTrackingService.stop();
        }
        try {
          final updated = await _driver.getMe();
          _timeTracking.backendMonthlyMs = updated.monthlyOnlineMs;
          _state.driverProfile = updated;
        } catch (_) {}
      } else {
        // ── Going ONLINE ───────────────────────────────────────────────────
        final gpsOn = await _gps.isEnabled();
        if (!gpsOn) {
          _state.gpsRequired = true;
          _state.loading = false;
          notifyListeners();
          return;
        }

        final hasPermission = await _gps.checkPermission();
        if (!hasPermission) {
          final granted = await _gps.requestPermission();
          await PermissionStateStorage.setState(
            granted ? PermissionState.granted : PermissionState.denied,
          );
          if (!granted) {
            _state.permissionRequired = true;
            _state.loading = false;
            notifyListeners();
            return;
          }
        }

        _state.forcedOffline = false;
        final pos = await _gps.getLocation();
        await _dispatch.goOnline(lat: pos?.latitude, lng: pos?.longitude);
        _timeTracking.lastOnlineAt = DateTime.now();
        _heartbeat.resetFailCount();
        _startUiTimer();
        _state.isOnline = true;

        await BackgroundTrackingService.start();

        // Check if driver has an active ride from backend
        debugPrint(
          '🚗 [OnlineProvider] 🔍 Checking for active ride from backend...',
        );
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
            debugPrint(
              '🚗 [OnlineProvider] ✅ Found active ride from backend: ${_state.activeRideId}',
            );
          } else {
            debugPrint(
              '🚗 [OnlineProvider] ℹ️ No active ride found on backend',
            );
          }
        } catch (e) {
          debugPrint('🚗 [OnlineProvider] ⚠️ Failed to fetch rides: $e');
        }

        if (_state.activeRideId != null) {
          debugPrint(
            '🚗 [OnlineProvider] 📍 Active ride detected: ${_state.activeRideId} - starting GPS tracking immediately',
          );
          BackgroundTrackingService.startTracking(_state.activeRideId!);
        } else {
          debugPrint(
            '🚗 [OnlineProvider] ℹ️ No active ride - GPS tracking not started yet',
          );
        }
      }
    } catch (e) {
      debugPrint('OnlineProvider.toggleOnline: $e');
      final msg = e.toString().toLowerCase();
      if (msg.contains('cannot go offline') ||
          msg.contains('trip') ||
          msg.contains('forbidden')) {
        NotificationService.instance.showLocalNotification(
          title: 'Cannot Go Offline',
          body: 'You are currently in a trip and cannot go offline.',
        );
      } else {
        _state.error = 'Failed to change online status: ${e.toString()}';
      }
    } finally {
      _state.loading = false;
      notifyListeners();
    }
  }

  // ── Timers ────────────────────────────────────────────────────────────────
  void _startUiTimer() {
    _uiTimer?.cancel();
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  void _stopUiTimer() {
    _uiTimer?.cancel();
    _uiTimer = null;
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

  /// Refreshes driver profile stats from the backend without the init guard.
  Future<void> refreshDriverProfile() async {
    try {
      _state.driverProfile = await _driver.getMe();
      notifyListeners();
    } catch (_) {
      // Non-fatal — stale data until next natural refresh
    }
  }

  @override
  void dispose() {
    debugPrint(
      '🚗 [OnlineProvider] Disposing - stopping all services and going offline',
    );
    WidgetsBinding.instance.removeObserver(this);
    _heartbeat.stop();
    _stopUiTimer();
    // Stop background tracking service when provider is disposed (app closed)
    BackgroundTrackingService.stopTracking();
    BackgroundTrackingService.stop();
    _state.isOnline = false;
    _timeTracking.lastOnlineAt = null;
    super.dispose();
  }
}
