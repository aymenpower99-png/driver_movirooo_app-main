import 'ride_model.dart';

/// A dispatch offer sent to this driver — from GET /dispatch/offers/pending
class OfferModel {
  final String    id;
  final String    rideId;
  final String    status;   // PENDING | ACCEPTED | REJECTED | EXPIRED
  final String?   expiresAt;
  final RideModel ride;

  const OfferModel({
    required this.id,
    required this.rideId,
    required this.status,
    this.expiresAt,
    required this.ride,
  });

  bool get isPending => status == 'PENDING';

  factory OfferModel.fromJson(Map<String, dynamic> j) => OfferModel(
        id:        j['id']        as String,
        rideId:    j['rideId']    as String,
        status:    j['status']    as String? ?? 'PENDING',
        expiresAt: j['expiresAt'] as String?,
        ride:      RideModel.fromJson(j['ride'] as Map<String, dynamic>),
      );
}
