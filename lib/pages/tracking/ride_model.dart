// lib/pages/tracking/ride_model.dart

enum RideStatus { assigned, onTheWay, arrived, startRide, completed }

extension RideStatusX on RideStatus {
  String get stepLabel {
    switch (this) {
      case RideStatus.assigned:
        return 'Assigned';
      case RideStatus.onTheWay:
        return 'On the Way';
      case RideStatus.arrived:
        return 'Arrived';
      case RideStatus.startRide:
        return 'Start Ride';
      case RideStatus.completed:
        return 'Complete';
    }
  }

  String get primaryButtonLabel {
    switch (this) {
      case RideStatus.assigned:
        return 'Go to Pickup';
      case RideStatus.onTheWay:
        return "I've Arrived";
      case RideStatus.arrived:
        return 'Start Ride';
      case RideStatus.startRide:
        return 'Complete Ride';
      case RideStatus.completed:
        return 'Done';
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
  });
}
