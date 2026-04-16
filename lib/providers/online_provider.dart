import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/dispatch_service.dart';
import '../services/driver_service.dart';
import '../core/models/driver_model.dart';

/// Manages driver online/offline status, GPS heartbeat, and persistent time tracking.
///
/// Time model:
///   • todayOnlineMs  — accumulated this calendar day, resets at midnight
///   • allTimeOnlineMs — never resets, accumulates across all days
///
/// Both are persisted in SharedPreferences and survive app restarts.
class OnlineProvider extends ChangeNotifier {
  final DispatchService _dispatch = DispatchService();
  final DriverService   _driver   = DriverService();

  bool         _isOnline    = false;
  bool         _loading     = false;
  String?      _error;
  DriverModel? _driverProfile;
  bool         _initialized = false; // guard: loadDriverProfile runs only once

  /// Set to true when the user tried to go online but GPS is disabled.
  /// Dashboard should show a persistent "Enable GPS" dialog.
  bool _gpsRequired = false;

  // ── Session tracking ──────────────────────────────────────────────────────
  DateTime? _lastOnlineAt; // when current online session started

  // ── Persisted time counters (milliseconds) ────────────────────────────────
  int    _todayOnlineMs   = 0;
  int    _allTimeOnlineMs = 0;
  String _storedDate      = ''; // 'YYYY-MM-DD'

  static const _kTodayMs   = 'online_today_ms';
  static const _kAllTimeMs = 'online_alltime_ms';
  static const _kDate      = 'online_date';

  // ── Timers ────────────────────────────────────────────────────────────────
  Timer? _heartbeatTimer;
  Timer? _uiTimer;

  // ── Getters ───────────────────────────────────────────────────────────────
  bool         get isOnline      => _isOnline;
  bool         get loading       => _loading;
  String?      get error         => _error;
  DriverModel? get driverProfile => _driverProfile;
  bool         get gpsRequired   => _gpsRequired;

  /// Milliseconds elapsed in the current online session (0 if offline).
  int get _sessionMs {
    if (!_isOnline || _lastOnlineAt == null) return 0;
    return DateTime.now().difference(_lastOnlineAt!).inMilliseconds;
  }

  /// Today's total online time including current live session.
  String get todayOnlineFormatted  => _fmtMs(_todayOnlineMs  + _sessionMs);

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

  // ── Persistence ───────────────────────────────────────────────────────────
  Future<void> _loadPersistedTime() async {
    final prefs = await SharedPreferences.getInstance();
    _allTimeOnlineMs = prefs.getInt(_kAllTimeMs) ?? 0;
    _storedDate      = prefs.getString(_kDate)   ?? '';

    final today = _todayStr();
    if (_storedDate != today) {
      _todayOnlineMs = 0;
      await prefs.setInt(_kTodayMs, 0);
      await prefs.setString(_kDate, today);
      _storedDate = today;
    } else {
      _todayOnlineMs = prefs.getInt(_kTodayMs) ?? 0;
    }
  }

  Future<void> _persistTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTodayMs,   _todayOnlineMs);
    await prefs.setInt(_kAllTimeMs, _allTimeOnlineMs);
    await prefs.setString(_kDate,   _todayStr());
  }

  String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}';
  }

  // ── Load initial driver state (runs once) ─────────────────────────────────
  Future<void> loadDriverProfile() async {
    if (_initialized) return;
    _initialized = true;
    await _loadPersistedTime();
    try {
      _driverProfile = await _driver.getMe();
      _isOnline = _driverProfile!.isOnline;
      if (_isOnline) {
        _lastOnlineAt = DateTime.now(); // approximate
        _startTimers();
      }
      notifyListeners();
    } catch (_) {
      // Non-fatal — keep UI working
    }
  }

  // ── GPS ───────────────────────────────────────────────────────────────────

  /// Check if device GPS service is enabled.
  Future<bool> isGpsEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get location with medium accuracy + 3-second timeout.
  /// Returns null on any failure — never blocks going online.
  Future<Position?> _getLocation() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return null; // proceed without coords — don't block
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      ).timeout(const Duration(seconds: 3), onTimeout: () {
        throw TimeoutException('GPS timeout');
      });
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
    _error   = null;
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

        final pos = await _getLocation();
        await _dispatch.goOnline(lat: pos?.latitude, lng: pos?.longitude);
        _lastOnlineAt = DateTime.now();
        _startTimers(initialPosition: pos);
        _isOnline = true;
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
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
        ).timeout(const Duration(seconds: 5));
        await _dispatch.heartbeat(lat: pos.latitude, lng: pos.longitude);
      } catch (_) {
        try { await _dispatch.heartbeat(); } catch (_) {}
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
    _stopTimers();
    super.dispose();
  }
}
