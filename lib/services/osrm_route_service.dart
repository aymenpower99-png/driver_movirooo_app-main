import 'package:dio/dio.dart';
import 'package:moviroo_driver_app/core/models/geo_point.dart';

/// Fetches real road routes from the free OSRM demo server.
class OsrmRouteService {
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  static Future<OsrmRouteResult?> fetchRoute(GeoPoint from, GeoPoint to) async {
    final url =
        'https://router.project-osrm.org/route/v1/driving/'
        '${from.lon},${from.lat};'
        '${to.lon},${to.lat}'
        '?geometries=geojson&overview=full';

    try {
      final res = await _dio.get(url);
      if (res.statusCode != 200) return null;

      final data = res.data;
      if (data['code'] != 'Ok' ||
          data['routes'] == null ||
          (data['routes'] as List).isEmpty) {
        return null;
      }

      final route = data['routes'][0];
      final coords = route['geometry']['coordinates'] as List;
      final duration = (route['duration'] as num).toDouble();
      final distance = (route['distance'] as num).toDouble();

      // OSRM returns [lon, lat] — flip to GeoPoint(lat, lon)
      final points = coords
          .map<GeoPoint>((c) => GeoPoint(
                (c[1] as num).toDouble(),
                (c[0] as num).toDouble(),
              ))
          .toList();

      return OsrmRouteResult(
        points: points,
        durationSeconds: duration,
        distanceMeters: distance,
      );
    } catch (_) {
      return null;
    }
  }
}

class OsrmRouteResult {
  final List<GeoPoint> points;
  final double durationSeconds;
  final double distanceMeters;

  const OsrmRouteResult({
    required this.points,
    required this.durationSeconds,
    required this.distanceMeters,
  });

  String get etaText {
    final mins = (durationSeconds / 60).ceil();
    if (mins >= 60) {
      final h = mins ~/ 60;
      final m = mins % 60;
      return '${h}h ${m}min';
    }
    return '$mins min';
  }

  String get distanceText {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '${distanceMeters.toInt()} m';
  }
}

