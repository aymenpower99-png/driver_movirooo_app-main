import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/dispatch_service.dart';
import '../services/driver_service.dart';
import '../core/models/driver_model.dart';

/// Manages the driver's online/offline status, heartbeat loop, and online timer.
///
/// When driver goes ONLINE:
///   • Calls PATCH /dispatch/locations/online
///   • Starts a 30-second heartbeat timer → PATCH /dispatch/locations/heartbeat
///   • Starts a Stopwatch to count online time
///
/// When driver goes OFFLINE:
///   • Calls PATCH /dispatch/locations/offline
///   • Cancels heartbeat timer
///   • Stops Stopwatch
class OnlineProvider extends ChangeNotifier {
  final DispatchService _dispatch = DispatchService();
  final DriverService   _driver   = DriverService();

  bool        _isOnline    = false;
  bool        _loading     = false;
  String?     _error;
  DriverModel? _driverProfile;

  // ── Online-time stopwatch ─────────────────────────────────────────────────
  final Stopwatch _stopwatch = Stopwatch();
  Timer?          _heartbeatTimer;
  Timer?          _uiTimer; // ticks every second to refresh displayed time

  // ── Getters ───────────────────────────────────────────────────────────────
  bool        get isOnline      => _isOnline;
  bool        get loading       => _loading;
  String?     get error         => _error;
  DriverModel? get driverProfile => _driverProfile;

  /// Formatted online time — e.g. "1h 23m" or "45m"
  String get onlineTimeFormatted {
    final d = _stopwatch.elapsed;
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  Duration get onlineDuration => _stopwatch.elapsed;

  // ── Load initial driver state ─────────────────────────────────────────────
  Future<void> loadDriverProfile() async {
    try {
      _driverProfile = await _driver.getMe();
      _isOnline      = _driverProfile!.isOnline;
      if (_isOnline) _startTimers();
      notifyListeners();
    } catch (_) {
      // Non-fatal — UI can still show toggle
    }
  }

  // ── Toggle ────────────────────────────────────────────────────────────────
  Future<void> toggleOnline() async {
    if (_loading) return;
    _loading = true;
    _error   = null;
    notifyListeners();

    try {
      if (_isOnline) {
        await _dispatch.goOffline();
        _stopTimers();
        _isOnline = false;
      } else {
        await _dispatch.goOnline();
        _startTimers();
        _isOnline = true;
      }
    } on Exception catch (e) {
      _error = 'Failed to update status. Try again.';
      debugPrint('OnlineProvider error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Timers ────────────────────────────────────────────────────────────────
  void _startTimers() {
    _stopwatch.start();

    // Heartbeat: every 30 seconds
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      try {
        await _dispatch.heartbeat();
      } catch (_) {
        // Silent — heartbeat failure should not affect UX
      }
    });

    // UI refresh: every second so online-time counter updates smoothly
    _uiTimer?.cancel();
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  void _stopTimers() {
    _stopwatch.stop();
    _stopwatch.reset();
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
