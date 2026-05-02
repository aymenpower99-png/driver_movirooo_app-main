import 'dart:convert';
import 'package:moviroo_driver_app/core/models/geo_point.dart';

/// Helper class for GeoJSON operations.
class GeoJsonHelper {
  /// Convert list of GeoPoints to GeoJSON LineString.
  static String ptsToGeoJson(List<GeoPoint> pts) => jsonEncode({
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'geometry': {
              'type': 'LineString',
              'coordinates': pts.map((p) => [p.lon, p.lat]).toList(),
            },
            'properties': {},
          },
        ],
      });

  /// Convert flattened geometry array [lon, lat, lon, lat, ...] to GeoJSON LineString.
  static String geometryToGeoJson(List<double> geometry) {
    if (geometry.length < 4) return emptyGeoJson();

    final coordinates = <List<double>>[];
    for (int i = 0; i < geometry.length; i += 2) {
      coordinates.add([geometry[i], geometry[i + 1]]);
    }

    return jsonEncode({
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'geometry': {'type': 'LineString', 'coordinates': coordinates},
          'properties': {},
        },
      ],
    });
  }

  /// Empty GeoJSON FeatureCollection.
  static String emptyGeoJson() =>
      jsonEncode({'type': 'FeatureCollection', 'features': []});
}
