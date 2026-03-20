// ════════════════════════════════════════════════════════════════════
//  ride_model.dart
// ════════════════════════════════════════════════════════════════════

enum RideStatus { available, upcoming, completed, cancelled }

class RideModel {
  final String id;
  final String passengerName;
  final String passengerAvatar;
  final int passengerCount;
  final String from;
  final String to;
  final DateTime dateTime;
  final double price;
  final RideStatus status;

  const RideModel({
    required this.id,
    required this.passengerName,
    required this.passengerAvatar,
    required this.passengerCount,
    required this.from,
    required this.to,
    required this.dateTime,
    required this.price,
    required this.status,
  });
}