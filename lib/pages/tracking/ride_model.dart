// lib/pages/tabs/[driver]/Rides/tracking/ride_model.dart

enum RideStatus {
  assigned,
  onTheWay,
  arrived,
  inTrip,
}

extension RideStatusX on RideStatus {
  // Step indicator label (short)
  String get stepLabel {
    switch (this) {
      case RideStatus.assigned:  return 'ASSIGNED';
      case RideStatus.onTheWay:  return 'ON THE WAY';
      case RideStatus.arrived:   return 'ARRIVED';
      case RideStatus.inTrip:    return 'START RIDE';
    }
  }

  // Primary CTA button label
  String get primaryButtonLabel {
    switch (this) {
      case RideStatus.assigned:  return 'Go to Pickup';
      case RideStatus.onTheWay:  return "I've Arrived";
      case RideStatus.arrived:   return 'Start Ride';
      case RideStatus.inTrip:    return 'Complete Ride';
    }
  }

  bool get showContactButtons => this != RideStatus.assigned;
  bool get showBadge          => this != RideStatus.assigned;
  bool get showMeta           => this == RideStatus.assigned || this == RideStatus.onTheWay;
  bool get showDropoffMarker  => this == RideStatus.inTrip;

  RideStatus? get next {
    switch (this) {
      case RideStatus.assigned:  return RideStatus.onTheWay;
      case RideStatus.onTheWay:  return RideStatus.arrived;
      case RideStatus.arrived:   return RideStatus.inTrip;
      case RideStatus.inTrip:    return null;
    }
  }
}

class PassengerModel {
  final String name;
  final double rating;
  final String avatarInitial;
  final String? avatarUrl;

  const PassengerModel({
    required this.name,
    required this.rating,
    required this.avatarInitial,
    this.avatarUrl,
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

  const RideModel({
    required this.id,
    required this.passenger,
    required this.pickupAddress,
    required this.dropOffAddress,
    required this.distanceKm,
    required this.etaMinutes,
    required this.earningsAmount,
    this.currency = 'TND',
  });
}

const kSampleRide = RideModel(
  id: 'ride_001',
  passenger: PassengerModel(
    name: 'Amira Ben Salah',
    rating: 4.8,
    avatarInitial: 'A',
  ),
  pickupAddress: '42 Avenue Habib Bourguiba, Tunis 1000',
  dropOffAddress: 'Carthage Byrsa, Tunis',
  distanceKm: 2.3,
  etaMinutes: 5,
  earningsAmount: 8.50,
  currency: 'TND',
);