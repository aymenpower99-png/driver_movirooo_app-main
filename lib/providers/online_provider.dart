import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/dispatch_service.dart';
import '../services/driver_service.dart';
import '../core/models/driver_model.dart';
import '../core/notifications/notification_service.dart';

/// Manages driver online/offline status, GPS heartbeat, and persistent time tracking.
///
/// Time model:
///   • todayOnlineMs  — accumulated this calendar day, resets at midnight
///   • allTimeOnlineMs — never resets, accumulates across all days
///
/// Both are persisted in SharedPreferences and survive app restarts.
///
/// Also observes app lifecycle: when returning to foreground while online,
/// an immediate heartbeat is sent to prevent the backend stale-sweep from
/// marking the driver offline during background periods.
class OnlineProvider extends ChangeNotifier with WidgetsBindingObserver {
  final DispatchService _dispatch = DispatchService();
  final DriverService _driver = DriverService();

  bool _isOnline = false;
  bool _loading = false;
  String? _error;
  DriverModel? _driverProfile;
  bool _initialized = false; // guard: loadDriverProfile runs only once

  /// Set to true when the user tried to go online but GPS is disabled.
  /// Dashboard should show a persistent "Enable GPS" dialog.
  bool _gpsRequired = false;

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

  static const _kTodayMs   = 'online_today_ms';
  static const _kAllTimeMs = 'online_alltime_ms';
  static const _kDate      = 'online_date';
  // Legacy keys — read once for migration, then cleared
  static const _kLegacyMonthMs = 'online_month_ms';
  static const _kLegacyMonth   = 'online_month';

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
    _legacyMonth   = prefs.getString(_kLegacyMonth) ?? '';
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
      _isOnline = _driverProfile!.isOnline;

      // Seed monthly time from backend — this is the persistent source of truth.
      _backendMonthlyMs = _driverProfile!.monthlyOnlineMs;

      // ── One-time migration from legacy SharedPreferences ─────────────────
      // If the backend has 0 for this month AND we have old prefs data, migrate it.
      if (_backendMonthlyMs == 0 && _legacyMonthMs > 0) {
        final currentMonth = _monthStr();
        if (_legacyMonth == currentMonth) {
          _backendMonthlyMs = _legacyMonthMs; // show immediately while we seed
          _driver.seedMonthlyOnlineTime(_legacyMonthMs, currentMonth).then((_) async {
            // Clear legacy keys so migration never runs again
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove(_kLegacyMonthMs);
            await prefs.remove(_kLegacyMonth);
            _legacyMonthMs = 0;
            _legacyMonth   = '';
          }).catchError((_) {
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
      // Always re-sync status from backend on resume.
      // This catches the case where the backend sweep forced us offline while
      // we were backgrounded and the FCM background handler couldn't update state.
      _syncOnResume();
    }
  }

  /// Re-fetches driver status from backend on app resume.
  /// If backend says offline but we think we're online → treat as forced offline.
  /// If still online → send an immediate heartbeat to keep alive.
  Future<void> _syncOnResume() async {
    if (_forcedOffline) return; // already handled locally
    try {
      final profile = await _driver.getMe();
      final backendOnline = profile.isOnline;

      if (_isOnline && !backendOnline) {
        // Backend marked us offline while we were backgrounded.
        // The backend sweep already accumulated the session time — just clear local state.
        _forcedOffline = true;
        _isOnline = false;
        _lastOnlineAt = null;
        _stopTimers();

        // Re-fetch to get the updated monthlyOnlineMs from backend.
        try {
          final updated = await _driver.getMe();
          _backendMonthlyMs = updated.monthlyOnlineMs;
          _driverProfile    = updated;
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
    _driver.getMe().then((profile) {
      _backendMonthlyMs = profile.monthlyOnlineMs;
      _driverProfile    = profile;
      notifyListeners();
    }).catchError((_) {});
  }

  Future<void> _sendImmediateHeartbeat() async {
    try {
      final pos = await Geolocator.getLastKnownPosition();
      if (pos != null) {
        await _dispatch.heartbeat(lat: pos.latitude, lng: pos.longitude);
      } else {
        await _dispatch.heartbeat();
      }
    } catch (_) {
      try {
        await _dispatch.heartbeat();
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

  // ── Toggle ────────────────────────────────────────────────────────────────
  Future<void> toggleOnline() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    _gpsRequired = false;
    notifyListeners();

    try {
      if (_isOnline) {
        // ── Going OFFLINE ──────────────────────────────────────────────────
        await _dispatch.goOffline();
        if (_lastOnlineAt != null) {
          final ms = DateTime.now().difference(_lastOnlineAt!).inMilliseconds;
          _todayOnlineMs   += ms;
          _allTimeOnlineMs += ms;
          _lastOnlineAt = null;
          await _persistTime();
        }
        _stopTimers();
        _isOnline = false;
        // Backend accumulated the session into monthlyOnlineMs — re-fetch.
        try {
          final updated = await _driver.getMe();
          _backendMonthlyMs = updated.monthlyOnlineMs;
          _driverProfile    = updated;
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

        _forcedOffline =
            false; // clear forced-offline flag on explicit go-online
        final pos = await _getLocation();
        await _dispatch.goOnline(lat: pos?.latitude, lng: pos?.longitude);
        _lastOnlineAt = DateTime.now();
        _heartbeatFailCount = 0;
        _startTimers(initialPosition: pos);
        _isOnline = true;
        // Refresh profile so _backendMonthlyMs is up to date for the new session
        try {
          final updated = await _driver.getMe();
          _backendMonthlyMs = updated.monthlyOnlineMs;
          _driverProfile    = updated;
        } catch (_) {}
      }
    } on Exception catch (e) {
      _error = 'Failed to update status. Try again.';
      debugPrint('OnlineProvider.toggleOnline: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Timers ────────────────────────────────────────────────────────────────
  void _startTimers({Position? initialPosition}) {
    _heartbeatTimer?.cancel();
    _heartbeatFailCount = 0;
    // Send heartbeat every 20s. Backend stale threshold is 120s, so this gives
    // 6x redundancy against network hiccups, GPS delays, and background throttling.
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      bool success = false;
      try {
        // Use last-known position only — instant, never blocks the timer.
        final pos = await Geolocator.getLastKnownPosition();
        if (pos != null) {
          await _dispatch.heartbeat(lat: pos.latitude, lng: pos.longitude);
        } else {
          await _dispatch.heartbeat();
        }
        success = true;
      } catch (_) {
        // Last-resort: bare heartbeat without coords
        try {
          await _dispatch.heartbeat();
          success = true;
        } catch (_) {}
      }

      if (success) {
        if (_heartbeatFailCount > 0) {
          _heartbeatFailCount = 0;
        }
      } else {
        _heartbeatFailCount++;
        if (_heartbeatFailCount >= _maxHeartbeatFails) {
          // 120s without a successful heartbeat — backend sweep has marked us
          // offline. Sync local state so the UI matches the DB.
          _isOnline = false;
          _heartbeatFailCount = 0;
          if (_lastOnlineAt != null) {
            final ms = DateTime.now().difference(_lastOnlineAt!).inMilliseconds;
            _todayOnlineMs   += ms;
            _allTimeOnlineMs += ms;
            _lastOnlineAt = null;
            await _persistTime();
          }
          _stopTimers();
          _error = 'Connection lost. Toggle online to reconnect.';
          // Re-fetch backend monthly time (sweep already committed it).
          _driver.getMe().then((p) {
            _backendMonthlyMs = p.monthlyOnlineMs;
            _driverProfile    = p;
            notifyListeners();
          }).catchError((_) {});
          // Show a local notification so the driver knows they went offline
          // even when the screen is off.
          NotificationService.instance.showLocalNotification(
            title: '⚠️ You went offline',
            body:
                'Your screen turned off and you disconnected. Tap to go back online.',
            payload: 'DRIVER_WENT_OFFLINE',
          );
          notifyListeners();
        }
      }
    });

    _uiTimer?.cancel();
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  void _stopTimers() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _uiTimer?.cancel();
    _uiTimer = null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimers();
    super.dispose();
  }
}
