/// Driver profile returned from GET /drivers/me
class DriverModel {
  final String  id;
  final String  userId;
  final String  availabilityStatus; // PENDING | SETUP_REQUIRED | OFFLINE | ONLINE | ON_TRIP
  final double  ratingAverage;
  final int     totalTrips;
  final int     cancellationCount;
  final VehicleInfo? vehicle;
  final WorkAreaInfo? workArea;

  const DriverModel({
    required this.id,
    required this.userId,
    required this.availabilityStatus,
    required this.ratingAverage,
    required this.totalTrips,
    this.cancellationCount = 0,
    this.vehicle,
    this.workArea,
  });

  bool get isOnline {
    final s = availabilityStatus.toLowerCase();
    return s == 'online' || s == 'on_trip';
  }

  /// Acceptance rate as percentage (0–100).
  /// totalTrips = completed rides, cancellationCount = cancelled rides.
  /// Rate = completed / (completed + cancelled).
  int get acceptanceRate {
    final total = totalTrips + cancellationCount;
    if (total == 0) return 100;
    return ((totalTrips / total) * 100).round().clamp(0, 100);
  }

  factory DriverModel.fromJson(Map<String, dynamic> j) => DriverModel(
        id:                 j['id']                 as String,
        userId:             j['userId']             as String,
        availabilityStatus: j['availabilityStatus'] as String? ?? 'OFFLINE',
        ratingAverage:      _toDouble(j['ratingAverage']),
        totalTrips:         (j['totalTrips']        as num?)?.toInt() ?? 0,
        cancellationCount:  (j['cancellationCount'] as num?)?.toInt() ?? 0,
        vehicle: j['vehicle'] != null
            ? VehicleInfo.fromJson(j['vehicle'] as Map<String, dynamic>)
            : null,
        workArea: j['workArea'] != null
            ? WorkAreaInfo.fromJson(j['workArea'] as Map<String, dynamic>)
            : null,
      );

  static double _toDouble(dynamic v) {
    if (v == null) return 5.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 5.0;
  }

  DriverModel copyWith({String? availabilityStatus}) => DriverModel(
        id:                 id,
        userId:             userId,
        availabilityStatus: availabilityStatus ?? this.availabilityStatus,
        ratingAverage:      ratingAverage,
        totalTrips:         totalTrips,
        cancellationCount:  cancellationCount,
        vehicle:            vehicle,
        workArea:           workArea,
      );
}

class VehicleInfo {
  final String  id;
  final String  plateNumber;
  final String? make;
  final String? model;
  final String? color;
  final String? className; // from joined class relation

  const VehicleInfo({
    required this.id,
    required this.plateNumber,
    this.make,
    this.model,
    this.color,
    this.className,
  });

  String get displayName {
    final parts = [make, model].whereType<String>().join(' ');
    return parts.isNotEmpty ? parts : plateNumber;
  }

  factory VehicleInfo.fromJson(Map<String, dynamic> j) {
    final cls = j['vehicleClass'] as Map<String, dynamic>?;
    return VehicleInfo(
      id:          j['id']          as String,
      plateNumber: j['licensePlate'] as String? ?? j['plateNumber'] as String? ?? '',
      make:        j['make']        as String?,
      model:       j['model']       as String?,
      color:       j['color']       as String?,
      className:   cls?['name']     as String?,
    );
  }
}

class WorkAreaInfo {
  final String id;
  final String country;
  final String ville;

  const WorkAreaInfo({
    required this.id,
    required this.country,
    required this.ville,
  });

  String get displayName => '$ville, $country';

  factory WorkAreaInfo.fromJson(Map<String, dynamic> j) => WorkAreaInfo(
        id:      j['id']      as String,
        country: j['country'] as String? ?? '',
        ville:   j['ville']   as String? ?? '',
      );
}
