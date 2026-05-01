import 'dart:math' as math;
import 'package:moviroo_driver_app/core/models/geo_point.dart';

/// Detects when a driver deviates from a planned route and triggers re-routing.
///
/// Calculates the perpendicular distance from the driver's position to each
/// segment of the route geometry. If the minimum distance exceeds the threshold,
/// the driver is considered off-route.
class RouteDeviationDetector {
  /// Minimum distance from route (in meters) to trigger re-routing.
  static const double deviationThreshold = 30.0;

  /// Minimum time between re-routes to prevent API spam.
  static const Duration rerouteCooldown = Duration(seconds: 10);

  DateTime? _lastRerouteAt;
  List<double>? _currentRouteGeometry;
  GeoPoint? _routeDestination;

  /// Store the current route geometry for deviation detection.
  ///
  /// [geometry] is a flattened array of [lon, lat, lon, lat, ...] from Mapbox.
  /// [destination] is the target point (pickup or dropoff).
  void setCurrentRoute(List<double> geometry, GeoPoint destination) {
    _currentRouteGeometry = geometry;
    _routeDestination = destination;
    _lastRerouteAt = null;
  }

  /// Clear the stored route information.
  void clearRoute() {
    _currentRouteGeometry = null;
    _routeDestination = null;
    _lastRerouteAt = null;
  }

  /// Check if the driver has deviated from the route.
  ///
  /// Returns true if the driver is off-route and the cooldown has passed.
  bool shouldReroute(GeoPoint driverPos) {
    if (_currentRouteGeometry == null || _currentRouteGeometry!.isEmpty) {
      return false;
    }

    // Check cooldown
    final now = DateTime.now();
    if (_lastRerouteAt != null &&
        now.difference(_lastRerouteAt!) < rerouteCooldown) {
      return false;
    }

    // Calculate distance to route
    final distance = _distanceToRoute(driverPos, _currentRouteGeometry!);

    if (distance > deviationThreshold) {
      _lastRerouteAt = now;
      return true;
    }

    return false;
  }

  /// Get the current route destination (pickup or dropoff).
  GeoPoint? get routeDestination => _routeDestination;

  /// Calculate the minimum distance from a point to the route line segments.
  ///
  /// Iterates through all route segments and returns the minimum perpendicular
  /// distance from the driver position to any segment.
  double _distanceToRoute(GeoPoint point, List<double> geometry) {
    if (geometry.length < 4) return double.infinity;

    double minDistance = double.infinity;

    for (int i = 0; i < geometry.length - 2; i += 2) {
      final lineStart = GeoPoint(geometry[i + 1], geometry[i]);
      final lineEnd = GeoPoint(geometry[i + 3], geometry[i + 2]);
      final dist = _pointToLineSegmentDistance(point, lineStart, lineEnd);
      minDistance = math.min(minDistance, dist);
    }

    return minDistance;
  }

  /// Calculate the perpendicular distance from a point to a line segment.
  ///
  /// Uses the Haversine formula for great-circle distance and projects the
  /// point onto the line segment to find the closest point.
  double _pointToLineSegmentDistance(
    GeoPoint point,
    GeoPoint lineStart,
    GeoPoint lineEnd,
  ) {
    // Convert to radians for Haversine
    final lat1 = _degToRad(lineStart.lat);
    final lon1 = _degToRad(lineStart.lon);
    final lat2 = _degToRad(lineEnd.lat);
    final lon2 = _degToRad(lineEnd.lon);
    final lat3 = _degToRad(point.lat);
    final lon3 = _degToRad(point.lon);

    // Earth's radius in meters
    const earthRadius = 6371000.0;

    // Calculate distances
    final d13 = _haversine(lat1, lon1, lat3, lon3, earthRadius);
    final d23 = _haversine(lat2, lon2, lat3, lon3, earthRadius);
    final d12 = _haversine(lat1, lon1, lat2, lon2, earthRadius);

    if (d12 == 0) return d13;

    // Check if projection falls on the segment
    // Using the law of cosines to find the projection ratio
    final ratio = ((d13 * d13) - (d23 * d23) + (d12 * d12)) / (2 * d12 * d12);

    if (ratio < 0) {
      // Closest to lineStart
      return d13;
    } else if (ratio > 1) {
      // Closest to lineEnd
      return d23;
    } else {
      // Projection falls on the segment - calculate perpendicular distance
      // Using the formula: distance = d13 * sin(angle between segment and point)
      final angle = math.acos(
        ((d13 * d13) + (d12 * d12) - (d23 * d23)) / (2 * d13 * d12),
      );
      return d13 * math.sin(angle);
    }
  }

  /// Haversine formula for great-circle distance between two points.
  double _haversine(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
    double radius,
  ) {
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2));
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return radius * c;
  }

  double _degToRad(double degrees) {
    return degrees * (math.pi / 180.0);
  }
}
