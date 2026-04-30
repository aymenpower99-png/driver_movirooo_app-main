import 'dart:math' as math;
import 'package:moviroo_driver_app/core/models/geo_point.dart';

abstract final class GeoMath {
  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;

  static double degToRad(double d) => d * math.pi / 180;
  static double radToDeg(double r) => r * 180 / math.pi;

  static double calculateBearing(GeoPoint from, GeoPoint to) {
    final dLon = degToRad(to.lon - from.lon);
    final lat1 = degToRad(from.lat);
    final lat2 = degToRad(to.lat);
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return (radToDeg(math.atan2(y, x)) + 360) % 360;
  }

  static double distanceMeters(GeoPoint a, GeoPoint b) {
    const R = 6371000.0;
    final dLat = degToRad(b.lat - a.lat);
    final dLon = degToRad(b.lon - a.lon);
    final s2Lat = math.sin(dLat / 2) * math.sin(dLat / 2);
    final s2Lon = math.sin(dLon / 2) * math.sin(dLon / 2);
    final aVal =
        s2Lat + math.cos(degToRad(a.lat)) * math.cos(degToRad(b.lat)) * s2Lon;
    return R * 2 * math.atan2(math.sqrt(aVal), math.sqrt(1 - aVal));
  }
}
