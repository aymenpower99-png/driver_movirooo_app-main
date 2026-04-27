/// Simple lat/lng value type — SDK-independent.
class GeoPoint {
  final double lat;
  final double lon;
  const GeoPoint(this.lat, this.lon);

  /// Returns true only if this point has valid (non-zero, in-range) coordinates
  bool get hasValidCoordinates {
    if (lat == 0.0 && lon == 0.0) return false;
    if (lat.isNaN || lon.isNaN) return false;
    if (lat < -90 || lat > 90) return false;
    if (lon < -180 || lon > 180) return false;
    return true;
  }
}
