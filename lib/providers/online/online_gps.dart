import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/background/background_permission_handler.dart';
import '../../services/background/permission_state_storage.dart';

/// GPS and location logic for OnlineProvider.
/// Handles GPS service checks and location retrieval.
class OnlineGps {
  /// Check if device GPS service is enabled.
  Future<bool> isEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get location using a fast strategy:
  ///   1. Try last-known position first (instant, no wait)
  ///   2. Fall back to low-accuracy getCurrentPosition (faster fix, ~1-3s)
  ///   3. Fall back to medium-accuracy with 15s timeout
  /// Returns null on any failure — never blocks going online.
  Future<Position?> getLocation() async {
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

  /// Check OS-level location permission before going online
  Future<bool> checkPermission() async {
    debugPrint('🚗 [OnlineGps] Checking OS-level permission...');
    final hasPermission =
        await BackgroundPermissionHandler.checkPermissionsOnly();
    debugPrint('🚗 [OnlineGps] OS permission granted: $hasPermission');
    return hasPermission;
  }

  /// Request location permission if not granted
  Future<bool> requestPermission() async {
    debugPrint('🚗 [OnlineGps] Permission not granted - requesting now...');
    final granted =
        await BackgroundPermissionHandler.checkAndRequestPermissions();
    await PermissionStateStorage.setState(
      granted ? PermissionState.granted : PermissionState.denied,
    );
    return granted;
  }
}
