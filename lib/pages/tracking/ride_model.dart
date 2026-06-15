// lib/pages/tracking/ride_model.dart

enum RideStatus { assigned, onTheWay, arrived, startRide, completed }

extension RideStatusX on RideStatus {
  String stepLabel(String Function(String) t) {
    switch (this) {
      case RideStatus.assigned:
        return t('tracking_step_assigned');
      case RideStatus.onTheWay:
        return t('tracking_step_on_way');
      case RideStatus.arrived:
        return t('tracking_step_arrived');
      case RideStatus.startRide:
        return t('tracking_step_start_ride');
      case RideStatus.completed:
        return t('tracking_step_complete');
    }
  }

  String primaryButtonLabel(String Function(String) t) {
    switch (this) {
      case RideStatus.assigned:
        return t('tracking_button_go_pickup');
      case RideStatus.onTheWay:
        return t('tracking_button_arrived');
      case RideStatus.arrived:
        return t('tracking_button_start_ride');
      case RideStatus.startRide:
        return t('tracking_button_complete_ride');
      case RideStatus.completed:
        return t('tracking_button_done');
    }
  }

  bool get showContactButtons => this != RideStatus.assigned;

  bool get showBadge => this != RideStatus.assigned;

  bool get showMeta =>
      this == RideStatus.assigned || this == RideStatus.onTheWay;

  bool get showDropoffMarker => true; // always visible alongside pickup

  bool get isTerminal => this == RideStatus.completed;

  RideStatus? get next {
    switch (this) {
      case RideStatus.assigned:
        return RideStatus.onTheWay;
      case RideStatus.onTheWay:
        return RideStatus.arrived;
      case RideStatus.arrived:
        return RideStatus.startRide;
      case RideStatus.startRide:
        return RideStatus.completed;
      case RideStatus.completed:
        return null;
    }
  }
}

class PassengerModel {
  final String name;
  final double rating;
  final String avatarInitial;
  final String? avatarUrl;
  final String? phone;

  const PassengerModel({
    required this.name,
    required this.rating,
    required this.avatarInitial,
    this.avatarUrl,
    this.phone,
  });
}

class RideModel {
  final String id;
  final PassengerModel passenger;
  final String pickupAddress;
  final String dropOffAddress;
  final double distanceKm;
  final int etaMinutes;
  final double earningsAmount;
  final String currency;
  final double? pickupLat;
  final double? pickupLon;
  final double? dropoffLat;
  final double? dropoffLon;
  final RideStatus status;
  final String? vehicleMaker;
  final String? vehicleModel;

  /// Real distance driven (km) — computed by backend from GPS waypoints.
  /// Only populated after the ride is completed.
  final double? distanceKmReal;

  /// Real trip duration (minutes) — computed by backend from timestamps.
  /// Only populated after the ride is completed.
  final double? durationMinReal;

  /// Final ride price (gross) — populated after completion.
  final double? priceFinal;

  /// Commission amount deducted — populated after completion.
  final double? commissionAmount;

  /// Net driver earnings — populated after completion.
  final double? driverEarnings;

  const RideModel({
    required this.id,
    required this.passenger,
    required this.pickupAddress,
    required this.dropOffAddress,
    required this.distanceKm,
    required this.etaMinutes,
    required this.earningsAmount,
    this.currency = 'TND',
    this.pickupLat,
    this.pickupLon,
    this.dropoffLat,
    this.dropoffLon,
    this.status = RideStatus.assigned,
    this.vehicleMaker,
    this.vehicleModel,
    this.distanceKmReal,
    this.durationMinReal,
    this.priceFinal,
    this.commissionAmount,
    this.driverEarnings,
  });
}
