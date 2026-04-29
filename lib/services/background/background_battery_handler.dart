import 'package:geolocator/geolocator.dart';

/// Handles battery optimization settings for GPS tracking.
class BackgroundBatteryHandler {
  /// Determine adaptive GPS settings based on ride status
  static LocationSettings getAdaptiveLocationSettings() {
    // For now, use medium accuracy with 10m filter for battery efficiency
    // In a production system, this would be based on ride status:
    // - High accuracy during active trip (startRide)
    // - Medium accuracy when on the way to pickup (onTheWay)
    // - Low accuracy when waiting for ride (assigned)
    return const LocationSettings(
      accuracy: LocationAccuracy.medium,
      distanceFilter: 10, // 10 meters
    );
  }
}
