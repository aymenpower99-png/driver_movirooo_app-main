import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../services/driver/driver_service.dart';
import '../../../services/dispatch/dispatch_service.dart';
import '../../../services/background/background_tracking_service.dart';
import '../../../services/background/permission_state_storage.dart';
import '../../../core/notifications/notification_service.dart';
import '../online_state.dart';
import '../online_time_tracking.dart';
import '../online_persistence.dart';
import '../online_gps.dart';
import '../online_heartbeat.dart';

/// Handles online/offline toggle logic.
/// Manages going online and going offline with all associated checks and state updates.
class OnlineToggleHandler {
  final DispatchService _dispatch;
  final DriverService _driver;
  final OnlineState _state;
  final OnlineTimeTracking _timeTracking;
  final OnlineHeartbeat _heartbeat;
  final OnlinePersistence _persistence;
  final OnlineGps _gps;
  final Function() onNotifyListeners;

  OnlineToggleHandler({
    required DispatchService dispatch,
    required DriverService driver,
    required OnlineState state,
    required OnlineTimeTracking timeTracking,
    required OnlineHeartbeat heartbeat,
    required OnlinePersistence persistence,
    required OnlineGps gps,
    required this.onNotifyListeners,
  }) : _dispatch = dispatch,
       _driver = driver,
       _state = state,
       _timeTracking = timeTracking,
       _heartbeat = heartbeat,
       _persistence = persistence,
       _gps = gps;

  /// Toggle online/offline status
  Future<void> toggleOnline({
    required void Function() startMonthlyRefreshTimer,
    required void Function() stopMonthlyRefreshTimer,
  }) async {
    if (_state.loading) return;
    _state.loading = true;
    _state.error = null;
    _state.gpsRequired = false;
    _state.permissionRequired = false;
    onNotifyListeners();

    try {
      if (_state.isOnline) {
        // ── Going OFFLINE ──────────────────────────────────────────────────
        // Check backend as single source of truth for active ride status
        debugPrint(
          '🚗 [OnlineToggle] 🔍 Checking backend for active ride before going offline...',
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
            debugPrint(
              '🚗 [OnlineToggle] ⛔ Active ride found: ${activeRides.first.id} - blocking offline',
            );
            NotificationService.instance.showLocalNotification(
              title: 'Cannot Go Offline',
              body: 'You are currently in a trip and cannot go offline.',
            );
            _state.loading = false;
            onNotifyListeners();
            return;
          } else {
            debugPrint(
              '🚗 [OnlineToggle] ✅ No active ride found - allowing offline',
            );
          }
        } catch (e) {
          debugPrint('🚗 [OnlineToggle] ⚠️ Failed to fetch rides: $e');
          // If backend check fails, fall back to local state check
          if (_state.activeRideId != null) {
            NotificationService.instance.showLocalNotification(
              title: 'Cannot Go Offline',
              body: 'You are currently in a trip and cannot go offline.',
            );
            _state.loading = false;
            onNotifyListeners();
            return;
          }
        }
        try {
          await _dispatch.goOffline();
        } catch (e) {
          // Check for DioError with 403 status (Forbidden)
          if (e is DioError && e.response?.statusCode == 403) {
            NotificationService.instance.showLocalNotification(
              title: 'Cannot Go Offline',
              body: 'You are currently in a trip and cannot go offline.',
            );
            _state.loading = false;
            onNotifyListeners();
            return;
          }
          // Also check for string-based fallback
          if (e.toString().contains('403') ||
              e.toString().contains('Forbidden') ||
              e.toString().contains('trip')) {
            NotificationService.instance.showLocalNotification(
              title: 'Cannot Go Offline',
              body: 'You are currently in a trip and cannot go offline.',
            );
            _state.loading = false;
            onNotifyListeners();
            return;
          }
          rethrow;
        }
        if (_timeTracking.lastOnlineAt != null) {
          final sessionMs = _timeTracking.getSessionMs(_state.isOnline);
          _timeTracking.addSessionTime(sessionMs);
          await _persistence.persistTime();
          // Note: session time accumulation is handled by backend goOffline endpoint
          // which calls setMyAvailability(OFFLINE) and accumulates to driver_online_history.
        }
        _timeTracking.stopUiTimer();
        _state.isOnline = false;

        // Stop periodic monthly time refresh
        stopMonthlyRefreshTimer();

        if (_state.activeRideId == null) {
          BackgroundTrackingService.stopTracking();
          await BackgroundTrackingService.stop();
        }
        try {
          final updated = await _dispatch.getDriverRides();
          final activeRides = updated
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
              '🚗 [OnlineToggle] ✅ Found active ride from backend: ${_state.activeRideId}',
            );
          } else {
            debugPrint('🚗 [OnlineToggle] ℹ️ No active ride found on backend');
          }
        } catch (e) {
          debugPrint('🚗 [OnlineToggle] ⚠️ Failed to fetch rides: $e');
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
          onNotifyListeners();
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
            onNotifyListeners();
            return;
          }
        }

        _state.forcedOffline = false;
        final pos = await _gps.getLocation();
        if (pos == null) {
          _state.error =
              'Unable to get your location. Please enable GPS and try again.';
          _state.loading = false;
          onNotifyListeners();
          return;
        }
        await _dispatch.goOnline(lat: pos.latitude, lng: pos.longitude);
        _timeTracking.lastOnlineAt = DateTime.now();
        _heartbeat.resetFailCount();
        _timeTracking.startUiTimer();
        _state.isOnline = true;

        // Start periodic monthly time refresh to keep Earnings page in sync
        startMonthlyRefreshTimer();

        await BackgroundTrackingService.start();

        // Check if driver has an active ride from backend
        debugPrint(
          '🚗 [OnlineToggle] 🔍 Checking for active ride from backend...',
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
              '🚗 [OnlineToggle] ✅ Found active ride from backend: ${_state.activeRideId}',
            );
          } else {
            debugPrint('🚗 [OnlineToggle] ℹ️ No active ride found on backend');
          }
        } catch (e) {
          debugPrint('🚗 [OnlineToggle] ⚠️ Failed to fetch rides: $e');
        }

        if (_state.activeRideId != null) {
          debugPrint(
            '🚗 [OnlineToggle] 📍 Active ride detected: ${_state.activeRideId} - starting GPS tracking immediately',
          );
          BackgroundTrackingService.startTracking(_state.activeRideId!);
        } else {
          debugPrint(
            '🚗 [OnlineToggle] ℹ️ No active ride - GPS tracking not started yet',
          );
        }
      }
    } catch (e) {
      debugPrint('OnlineLifecycle.toggleOnline: $e');
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
      onNotifyListeners();
    }
  }
}
