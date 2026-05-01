import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/dispatch/dispatch_service.dart';
import '../services/driver/driver_service.dart';
import '../services/background/background_tracking_service.dart';
import '../services/background/background_permission_handler.dart';
import '../services/background/permission_state_storage.dart';
import '../core/models/driver_model.dart';
import '../core/notifications/notification_service.dart';

class OnlineProvider extends ChangeNotifier with WidgetsBindingObserver {
  final DispatchService _dispatch = DispatchService();
  final DriverService _driver = DriverService();

  bool _isOnline = false;
  bool _loading = false;
  String? _error;
  DriverModel? _driverProfile;
  bool _initialized = false; // guard: loadDriverProfile runs only once
  String? _activeRideId; // current ride being tracked

  /// Set to true when the user tried to go online but GPS is disabled.
  /// Dashboard should show a persistent "Enable GPS" dialog.
  bool _gpsRequired = false;

  /// Set to true when the user tried to go online but location permission
  /// is missing. Dashboard should show a "Permission Required" dialog.
  bool _permissionRequired = false;

  /// True when the backend forced the driver offline (stale heartbeat).
  /// Prevents heartbeat from auto-reconnecting; only explicit toggleOnline clears this.
  bool _forcedOffline = false;

  // ── Session tracking ──────────────────────────────────────────────────────
  DateTime? _lastOnlineAt; // when current online session started

  // ── Monthly time: SOURCE OF TRUTH is the backend DB ──────────────────────
  /// Accumulated ms from past sessions this month (loaded from backend).
  int _backendMonthlyMs = 0;

  // ── Persisted time counters (today + all-time only, milliseconds) ─────────
  int _todayOnlineMs = 0;
  int _allTimeOnlineMs = 0;
  String _storedDate = ''; // 'YYYY-MM-DD'

  // ── Legacy migration (old SharedPreferences monthly data) ─────────────────
  int _legacyMonthMs = 0;
  String _legacyMonth = '';

  static const _kTodayMs = 'online_today_ms';
  static const _kAllTimeMs = 'online_alltime_ms';
  static const _kDate = 'online_date';
  // Legacy keys — read once for migration, then cleared
  static const _kLegacyMonthMs = 'online_month_ms';
  static const _kLegacyMonth = 'online_month';

  // ── Timers ────────────────────────────────────────────────────────────────
  Timer? _heartbeatTimer;
  Timer? _uiTimer;

  /// Consecutive heartbeat failures. Reset on any success.
  /// After [_maxHeartbeatFails] failures the DB sweep will have expired us —
  /// mark offline locally so the UI matches what the backend sees.
  int _heartbeatFailCount = 0;
  static const _maxHeartbeatFails = 6; // 6 × 20 s = 120 s (sweep threshold)

  // ── Getters ───────────────────────────────────────────────────────────────
  bool get isOnline => _isOnline;
  bool get loading => _loading;
  String? get error => _error;
  DriverModel? get driverProfile => _driverProfile;
  bool get gpsRequired => _gpsRequired;
  bool get permissionRequired => _permissionRequired;

  /// Check if background location permission is granted
  Future<bool> get hasBackgroundPermission async {
    return await PermissionStateStorage.isGranted();
  }

  /// Get current permission state
  Future<PermissionState> get permissionState async {
    return await PermissionStateStorage.getState();
  }

  /// Milliseconds elapsed in the current online session (0 if offline).
  int get _sessionMs {
    if (!_isOnline || _lastOnlineAt == null) return 0;
    return DateTime.now().difference(_lastOnlineAt!).inMilliseconds;
  }

  /// Today's total online time including current live session.
  String get todayOnlineFormatted => _fmtMs(_todayOnlineMs + _sessionMs);

  /// Monthly total online time including current live session.
  /// Uses backend-persisted value as the base — survives reinstalls/cache clears.
  String get monthOnlineFormatted => _fmtMs(_backendMonthlyMs + _sessionMs);

  /// All-time total online time including current live session.
  String get allTimeOnlineFormatted => _fmtMs(_allTimeOnlineMs + _sessionMs);

  /// Alias kept for backward-compat with dashboard_page.
  String get onlineTimeFormatted => todayOnlineFormatted;

  /// Set the active ride ID for tracking. Call this when a ride is assigned or status changes.
  /// Tracking starts/stops based on ride ID, independent of online status.
  Future<void> setActiveRide(String? rideId) async {
    _activeRideId = rideId;

    if (rideId != null) {
      // Check REAL OS permission before starting tracking (not stored state)
      final hasPermission =
          await BackgroundPermissionHandler.checkPermissionsOnly();
      if (hasPermission) {
        debugPrint(
          '🚗 [OnlineProvider] Starting background tracking for ride: $rideId',
        );
        BackgroundTrackingService.startTracking(rideId);
      } else {
        // Show warning but keep ride active
        debugPrint(
          '🚗 [OnlineProvider] Permission denied, not starting tracking for ride: $rideId',
        );
        _error =
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

  String _fmtMs(int ms) {
    final d = Duration(milliseconds: ms);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  // ── Persistence (today + all-time only; monthly lives in backend DB) ─────
  Future<void> _loadPersistedTime() async {
    final prefs = await SharedPreferences.getInstance();
    _allTimeOnlineMs = prefs.getInt(_kAllTimeMs) ?? 0;
    _storedDate = prefs.getString(_kDate) ?? '';

    final today = _todayStr();
    if (_storedDate != today) {
      _todayOnlineMs = 0;
      await prefs.setInt(_kTodayMs, 0);
      await prefs.setString(_kDate, today);
      _storedDate = today;
    } else {
      _todayOnlineMs = prefs.getInt(_kTodayMs) ?? 0;
    }

    // Read legacy monthly keys for one-time migration
    _legacyMonthMs = prefs.getInt(_kLegacyMonthMs) ?? 0;
    _legacyMonth = prefs.getString(_kLegacyMonth) ?? '';
  }

  Future<void> _persistTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTodayMs, _todayOnlineMs);
    await prefs.setInt(_kAllTimeMs, _allTimeOnlineMs);
    await prefs.setString(_kDate, _todayStr());
  }

  String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  String _monthStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}';
  }

  // ── Load initial driver state (runs once) ─────────────────────────────────
  Future<void> loadDriverProfile() async {
    if (_initialized) return;
    _initialized = true;
    await _loadPersistedTime();
    // Register lifecycle observer so we can send an immediate heartbeat
    // when the driver brings the app back to the foreground.
    WidgetsBinding.instance.addObserver(this);
    // Listen for backend-forced offline via FCM
    NotificationService.instance.onDriverForcedOffline = _onForcedOffline;
    try {
      _driverProfile = await _driver.getMe();
      // Keep driver offline by default on app restart - do not auto-enable from backend
      _isOnline = false;

      // Seed monthly time from backend — this is the persistent source of truth.
      _backendMonthlyMs = _driverProfile!.monthlyOnlineMs;

      // ── One-time migration from legacy SharedPreferences ─────────────────
      // If the backend has 0 for this month AND we have old prefs data, migrate it.
      if (_backendMonthlyMs == 0 && _legacyMonthMs > 0) {
        final currentMonth = _monthStr();
        if (_legacyMonth == currentMonth) {
          _backendMonthlyMs = _legacyMonthMs; // show immediately while we seed
          _driver
              .seedMonthlyOnlineTime(_legacyMonthMs, currentMonth)
              .then((_) async {
                // Clear legacy keys so migration never runs again
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove(_kLegacyMonthMs);
                await prefs.remove(_kLegacyMonth);
                _legacyMonthMs = 0;
                _legacyMonth = '';
              })
              .catchError((_) {
                // Non-fatal — legacy value still displayed locally
              });
        }
      }

      if (_isOnline) {
        // Use the backend's recorded session start so we don't under-count
        // if the app was backgrounded for a while before this load.
        _lastOnlineAt = _driverProfile!.onlineSince ?? DateTime.now();
        _startTimers();
      }
      notifyListeners();
    } catch (_) {
      // Non-fatal — keep UI working
    }
  }

  /// Called by Flutter when the app moves between foreground/background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Start heartbeat when app comes to foreground (device is alive)
      _startHeartbeat();
      // Re-sync status from backend on resume.
      // This catches the case where the backend sweep forced us offline while
      // we were backgrounded and the FCM background handler couldn't update state.
      _syncOnResume();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Stop heartbeat when app goes to background
      _stopHeartbeat();
    } else if (state == AppLifecycleState.detached) {
      // App is being terminated (force-killed / swiped away)
      // Stop heartbeat AND stop background tracking service entirely
      // so the persistent notification disappears and GPS streaming stops.
      _stopHeartbeat();
      debugPrint(
        '🚗 [OnlineProvider] App detached — stopping background tracking service',
      );
      BackgroundTrackingService.stopTracking();
      BackgroundTrackingService.stop();
    }
  }

  /// Re-fetches driver status from backend on app resume.
  /// If backend says offline but we think we're online → treat as forced offline.
  /// If still online → send an immediate heartbeat to prevent stale sweep.
  Future<void> _syncOnResume() async {
    if (_forcedOffline) return; // already handled locally
    try {
      final profile = await _driver.getMe();
      final backendOnline = profile.isOnline;

      if (_isOnline && !backendOnline) {
        // Backend marked us offline while we were backgrounded.
        // However, if we have an active ride, the backend sweep may have
        // marked us offline due to heartbeat stopping in background (normal).
        // Only force offline if we truly have no active ride.
        if (_activeRideId == null) {
          // No active ride — driver was genuinely inactive
          _forcedOffline = true;
          _isOnline = false;
          _lastOnlineAt = null;
          _stopTimers();

          // Re-fetch to get the updated monthlyOnlineMs from backend.
          try {
            final updated = await _driver.getMe();
            _backendMonthlyMs = updated.monthlyOnlineMs;
            _driverProfile = updated;
          } catch (_) {
            // keep last known value
          }

          _error =
              'You went offline due to inactivity. Toggle online to reconnect.';
          NotificationService.instance.showLocalNotification(
            title: '⚠️ You went offline',
            body:
                'Your status was changed to offline due to inactivity. Tap to go back online.',
            payload: 'DRIVER_WENT_OFFLINE',
          );
          notifyListeners();
        } else {
          // Has active ride — backend marked us offline due to heartbeat stopping
          // in background (normal during long trips). Ignore and send heartbeat
          // to re-establish online status with backend.
          debugPrint(
            '🚗 [OnlineProvider] Backend says OFFLINE but we have active ride $_activeRideId — ignoring, sending heartbeat',
          );
          _sendImmediateHeartbeat();
        }
      } else if (_isOnline) {
        // Still online — send heartbeat to prevent stale sweep
        _sendImmediateHeartbeat();
      }
    } catch (_) {
      // Network error on resume — still try heartbeat if online
      if (_isOnline && !_forcedOffline) {
        _sendImmediateHeartbeat();
      }
    }
  }

  /// Called when backend FCM arrives telling us we were forced offline.
  void _onForcedOffline() {
    if (!_isOnline) return; // already offline locally
    _forcedOffline = true;
    _isOnline = false;
    _heartbeatFailCount = 0;
    // The backend sweep already committed the session time — clear local state.
    _lastOnlineAt = null;
    _stopTimers();
    _error = 'You went offline due to inactivity. Toggle online to reconnect.';
    notifyListeners();

    // Async re-fetch to update the monthly counter from backend.
    _driver
        .getMe()
        .then((profile) {
          _backendMonthlyMs = profile.monthlyOnlineMs;
          _driverProfile = profile;
          notifyListeners();
        })
        .catchError((_) {});
  }

  Future<void> _sendImmediateHeartbeat() async {
    try {
      final pos = await Geolocator.getLastKnownPosition();
      final driverState = _isOnline ? 'online' : 'offline';
      if (pos != null) {
        await _dispatch.heartbeat(
          alive: true,
          driverState: driverState,
          rideId: _activeRideId,
          lat: pos.latitude,
          lng: pos.longitude,
        );
      } else {
        await _dispatch.heartbeat(
          alive: true,
          driverState: driverState,
          rideId: _activeRideId,
        );
      }
    } catch (_) {
      try {
        final driverState = _isOnline ? 'online' : 'offline';
        await _dispatch.heartbeat(
          alive: true,
          driverState: driverState,
          rideId: _activeRideId,
        );
      } catch (_) {}
    }
  }

  // ── GPS ───────────────────────────────────────────────────────────────────

  /// Check if device GPS service is enabled.
  Future<bool> isGpsEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get location using a fast strategy:
  ///   1. Try last-known position first (instant, no wait)
  ///   2. Fall back to low-accuracy getCurrentPosition (faster fix, ~1-3s)
  ///   3. Fall back to medium-accuracy with 15s timeout
  /// Returns null on any failure — never blocks going online.
  Future<Position?> _getLocation() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return null;
      }

      // Step 1: last known position — instant, no GPS warm-up
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return last;

      // Step 2: low-accuracy fresh fix (faster satellite acquisition)
      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
          ),
        ).timeout(const Duration(seconds: 15));
      } catch (_) {}

      // Step 3: medium-accuracy with generous timeout
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(const Duration(seconds: 30));
    } catch (_) {
      return null; // GPS unavailable — still allow going online
    }
  }

  /// Called by dashboard after GPS dialog confirms GPS is now enabled.
  void clearGpsRequired() {
    _gpsRequired = false;
    notifyListeners();
  }

  /// Called by dashboard after permission dialog is dismissed.
  void clearPermissionRequired() {
    _permissionRequired = false;
    notifyListeners();
  }

  // ── Toggle ────────────────────────────────────────────────────────────────
  Future<void> toggleOnline() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    _gpsRequired = false;
    _permissionRequired = false;
    notifyListeners();

    try {
      if (_isOnline) {
        // ── Going OFFLINE ──────────────────────────────────────────────────
        await _dispatch.goOffline();
        if (_lastOnlineAt != null) {
          final ms = DateTime.now().difference(_lastOnlineAt!).inMilliseconds;
          _todayOnlineMs += ms;
          _allTimeOnlineMs += ms;
          _lastOnlineAt = null;
          await _persistTime();
        }
        _stopUiTimer(); // Only stop UI timer, heartbeat continues based on app lifecycle
        _isOnline = false;

        // Only stop tracking if no active ride - tracking continues during ride
        if (_activeRideId == null) {
          BackgroundTrackingService.stopTracking();
          await BackgroundTrackingService.stop();
        }
        // Backend accumulated the session into monthlyOnlineMs — re-fetch.
        try {
          final updated = await _driver.getMe();
          _backendMonthlyMs = updated.monthlyOnlineMs;
          _driverProfile = updated;
        } catch (_) {
          // Non-fatal — display will be slightly stale until next getMe
        }
      } else {
        // ── Going ONLINE ───────────────────────────────────────────────────
        // Check GPS service is on (UI should have shown modal already)
        final gpsOn = await Geolocator.isLocationServiceEnabled();
        if (!gpsOn) {
          _gpsRequired = true;
          _loading = false;
          notifyListeners();
          return;
        }

        // Check actual OS-level location permission BEFORE going online
        debugPrint('🚗 [OnlineProvider] Checking OS-level permission...');
        final hasPermission =
            await BackgroundPermissionHandler.checkPermissionsOnly();
        debugPrint('🚗 [OnlineProvider] OS permission granted: $hasPermission');

        if (!hasPermission) {
          // Try to request permission - shows OS dialog if not permanently denied
          debugPrint(
            '🚗 [OnlineProvider] Permission not granted - requesting now...',
          );
          final granted =
              await BackgroundPermissionHandler.checkAndRequestPermissions();
          await PermissionStateStorage.setState(
            granted ? PermissionState.granted : PermissionState.denied,
          );
          if (!granted) {
            debugPrint(
              '🚗 [OnlineProvider] ⚠️ Permission denied - showing permission required dialog',
            );
            _permissionRequired = true;
            _loading = false;
            notifyListeners();
            return;
          }
        }

        // Permission granted - proceed to go online
        _forcedOffline =
            false; // clear forced-offline flag on explicit go-online
        final pos = await _getLocation();
        await _dispatch.goOnline(lat: pos?.latitude, lng: pos?.longitude);
        _lastOnlineAt = DateTime.now();
        _heartbeatFailCount = 0;
        _startUiTimer(); // Only start UI timer, heartbeat managed by app lifecycle
        _isOnline = true;

        // Start background service since permission is granted
        debugPrint(
          '🚗 [OnlineProvider] ✅ Background permission available - starting background service',
        );
        await BackgroundTrackingService.start(); // Start background service

        // Start GPS tracking if there's an active ride
        if (_activeRideId != null) {
          BackgroundTrackingService.startTracking(_activeRideId!);
        }
      }
    } catch (e) {
      debugPrint('OnlineProvider.toggleOnline: $e');
      _error = 'Failed to change online status: ${e.toString()}';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Timers ────────────────────────────────────────────────────────────────

  /// Start heartbeat - runs when app is alive (foreground), independent of online status
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatFailCount = 0;
    // Send heartbeat every 20s. Backend stale threshold is 120s, so this gives
    // 6x redundancy against network hiccups, GPS delays, and background throttling.
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      bool success = false;
      try {
        // Use last-known position only — instant, never blocks the timer.
        final pos = await Geolocator.getLastKnownPosition();
        final driverState = _isOnline ? 'online' : 'offline';
        if (pos != null) {
          await _dispatch.heartbeat(
            alive: true,
            driverState: driverState,
            rideId: _activeRideId,
            lat: pos.latitude,
            lng: pos.longitude,
          );
        } else {
          await _dispatch.heartbeat(
            alive: true,
            driverState: driverState,
            rideId: _activeRideId,
          );
        }
        success = true;
      } catch (_) {
        // Last-resort: bare heartbeat without coords
        try {
          final driverState = _isOnline ? 'online' : 'offline';
          await _dispatch.heartbeat(
            alive: true,
            driverState: driverState,
            rideId: _activeRideId,
          );
          success = true;
        } catch (_) {}
      }

      if (success) {
        if (_heartbeatFailCount > 0) {
          _heartbeatFailCount = 0;
          // Clear connection error when heartbeat succeeds
          if (_error == 'Connection lost. Reconnecting...') {
            _error = null;
            notifyListeners();
          }
        }
      } else {
        _heartbeatFailCount++;
        if (_heartbeatFailCount >= _maxHeartbeatFails) {
          // 120s without a successful heartbeat — connection lost
          // Don't change _isOnline (driver's choice), just show connection error
          _heartbeatFailCount = 0; // Reset to allow retry
          _error = 'Connection lost. Reconnecting...';

          // Show connection lost notification (not "went offline")
          NotificationService.instance.showLocalNotification(
            title: '⚠️ Connection Lost',
            body: 'Reconnecting to server...',
            payload: 'CONNECTION_LOST',
          );
          notifyListeners();
        }
      }
    });
  }

  /// Stop heartbeat - called when app goes to background
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Start UI timer for updating online time display - only when online
  void _startUiTimer() {
    _uiTimer?.cancel();
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  /// Stop UI timer
  void _stopUiTimer() {
    _uiTimer?.cancel();
    _uiTimer = null;
  }

  /// Legacy method - starts both heartbeat and UI timer (used for backward compatibility)
  void _startTimers({Position? initialPosition}) {
    _startHeartbeat();
    _startUiTimer();
  }

  /// Legacy method - stops both heartbeat and UI timer (used for backward compatibility)
  void _stopTimers() {
    _stopHeartbeat();
    _stopUiTimer();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refreshes driver profile stats from the backend without the init guard.
  /// Call after trip events (cancel, complete) to update acceptanceRate/cancellationCount.
  Future<void> refreshDriverProfile() async {
    try {
      _driverProfile = await _driver.getMe();
      notifyListeners();
    } catch (_) {
      // Non-fatal — stale data until next natural refresh
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimers();
    super.dispose();
  }
}
