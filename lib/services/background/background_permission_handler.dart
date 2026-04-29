import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// Handles permission checking and requesting for background tracking.
class BackgroundPermissionHandler {
  /// Check and request necessary permissions for background tracking
  static Future<bool> checkAndRequestPermissions() async {
    // Check location service
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('🚗 [BackgroundPermission] Location service NOT enabled');
      return false;
    }

    // Check and request location permissions
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      debugPrint(
        '🚗 [BackgroundPermission] Location permission denied, requesting...',
      );
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.denied) {
      debugPrint(
        '🚗 [BackgroundPermission] Location permission denied after request',
      );
      return false;
    }

    if (perm == LocationPermission.deniedForever) {
      debugPrint(
        '🚗 [BackgroundPermission] Location permission denied forever',
      );
      return false;
    }

    // Check background location permission (Android only)
    if (defaultTargetPlatform == TargetPlatform.android) {
      final backgroundStatus = await ph.Permission.locationAlways.status;
      if (!backgroundStatus.isGranted) {
        debugPrint(
          '🚗 [BackgroundPermission] Background location permission not granted, requesting...',
        );
        final result = await ph.Permission.locationAlways.request();
        if (!result.isGranted) {
          debugPrint(
            '🚗 [BackgroundPermission] Background location permission denied',
          );
          return false;
        }
      }
    }

    debugPrint('🚗 [BackgroundPermission] All permissions granted ✓');
    return true;
  }
}
