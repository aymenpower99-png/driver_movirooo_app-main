/// Unified ride model — replaces the two conflicting ride_model.dart files.
class RideModel {
  final String  id;
  final String  pickupAddress;
  final String  dropoffAddress;
  final String  status;          // matches backend RideStatus enum
  final String? passengerName;
  final String? passengerPhone;
  final double? priceEstimate;
  final double? priceFinal;
  final String? scheduledAt;
  final String? className;       // vehicle class name
  final String? vehiclePlate;    // assigned vehicle plate
  final double? distanceKm;

  const RideModel({
    required this.id,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.status,
    this.passengerName,
    this.passengerPhone,
    this.priceEstimate,
    this.priceFinal,
    this.scheduledAt,
    this.className,
    this.vehiclePlate,
    this.distanceKm,
  });

  // ── Display helpers ───────────────────────────────────────────────
  double get displayPrice => priceFinal ?? priceEstimate ?? 0.0;
  double get price        => displayPrice;
  String get from         => pickupAddress;
  String get to           => dropoffAddress;
  String get vehicleClassName => className ?? '';
  String get rideTime     => scheduledAt ?? '';

  String get passengerInitials {
    final name = passengerName?.trim() ?? '';
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  bool get isCompleted  => status == 'COMPLETED';
  bool get isCancelled  => status == 'CANCELLED';
  bool get isAssigned   => status == 'ASSIGNED';
  bool get isInTrip     => status == 'IN_TRIP';

  factory RideModel.fromJson(Map<String, dynamic> j) {
    final passenger = j['passenger'] as Map<String, dynamic>?;
    final cls       = j['class']    as Map<String, dynamic>?;
    final vehicle   = j['vehicle']  as Map<String, dynamic>?;

    return RideModel(
      id:             j['id']              as String,
      pickupAddress:  j['pickup_address']  as String? ?? '',
      dropoffAddress: j['dropoff_address'] as String? ?? '',
      status:         j['status']          as String? ?? 'PENDING',
      passengerName:  passenger != null
          ? '${passenger['firstName']} ${passenger['lastName']}'
          : null,
      passengerPhone: passenger?['phone'] as String?,
      priceEstimate:  _toDouble(j['price_estimate']),
      priceFinal:     _toDouble(j['price_final']),
      scheduledAt:    j['scheduled_at'] as String?,
      className:      cls?['name']      as String?,
      vehiclePlate:   vehicle?['plateNumber'] as String?,
      distanceKm:     _toDouble(j['distance_km']),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
