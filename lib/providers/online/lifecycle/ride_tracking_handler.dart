import 'package:flutter/foundation.dart';
import '../../../services/background/background_permission_handler.dart';
import '../../../services/background/background_tracking_service.dart';
import '../online_state.dart';

/// Handles ride tracking logic.
/// Manages setting the active ride ID and starting/stopping background tracking.
class RideTrackingHandler {
  final OnlineState _state;
  final Function() onNotifyListeners;

  RideTrackingHandler({
    required OnlineState state,
    required this.onNotifyListeners,
  }) : _state = state;

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
          '🚗 [RideTracking] Starting background tracking for ride: $rideId',
        );
        BackgroundTrackingService.startTracking(rideId);
      } else {
        debugPrint(
          '🚗 [RideTracking] Permission denied, not starting tracking for ride: $rideId',
        );
        _state.error =
            'Location permission required for tracking. Enable in settings to track ride.';
        onNotifyListeners();
      }
    } else {
      // Stop tracking when ride is completed/cancelled
      debugPrint(
        '🚗 [RideTracking] Stopping background tracking (no active ride)',
      );
      BackgroundTrackingService.stopTracking();
    }
  }
}
