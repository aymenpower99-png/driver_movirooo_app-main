/// Driver profile returned from GET /drivers/me
class DriverModel {
  final String  id;
  final String  userId;
  final String  availabilityStatus; // PENDING | SETUP_REQUIRED | OFFLINE | ONLINE | ON_TRIP
  final double  ratingAverage;
  final int     totalTrips;
  final VehicleInfo? vehicle;

  const DriverModel({
    required this.id,
    required this.userId,
    required this.availabilityStatus,
    required this.ratingAverage,
    required this.totalTrips,
    this.vehicle,
  });

  bool get isOnline => availabilityStatus == 'ONLINE' || availabilityStatus == 'ON_TRIP';

  factory DriverModel.fromJson(Map<String, dynamic> j) => DriverModel(
        id:                 j['id']                 as String,
        userId:             j['userId']             as String,
        availabilityStatus: j['availabilityStatus'] as String? ?? 'OFFLINE',
        ratingAverage:      _toDouble(j['ratingAverage']),
        totalTrips:         (j['totalTrips'] as num?)?.toInt() ?? 0,
        vehicle: j['vehicle'] != null
            ? VehicleInfo.fromJson(j['vehicle'] as Map<String, dynamic>)
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
        vehicle:            vehicle,
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
      plateNumber: j['plateNumber'] as String? ?? '',
      make:        j['make']        as String?,
      model:       j['model']       as String?,
      color:       j['color']       as String?,
      className:   cls?['name']     as String?,
    );
  }
}
