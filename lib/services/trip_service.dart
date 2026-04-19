import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';

/// HTTP calls for ride lifecycle transitions (driver controls).
class TripService {
  final Dio _dio = ApiClient.instance.dio;

  /// ASSIGNED → EN_ROUTE_TO_PICKUP
  Future<void> startEnroute(String rideId) async {
    await _dio.patch(Endpoints.tripEnroute(rideId));
  }

  /// EN_ROUTE_TO_PICKUP → ARRIVED
  Future<void> arrived(String rideId) async {
    await _dio.patch(Endpoints.tripArrived(rideId));
  }

  /// ARRIVED → IN_TRIP
  Future<void> startTrip(String rideId) async {
    await _dio.patch(Endpoints.tripStart(rideId));
  }

  /// IN_TRIP → COMPLETED
  Future<void> endTrip(String rideId) async {
    await _dio.patch(Endpoints.tripEnd(rideId));
  }

  /// Cancel active ride with an optional reason
  Future<void> cancelTrip(String rideId, {String? reason}) async {
    await _dio.patch(
      Endpoints.tripCancel(rideId),
      data: reason != null ? {'reason': reason} : null,
    );
  }

  /// Submit a support ticket linked to a ride
  Future<void> submitTicket({
    required String rideId,
    required String issueType,
    required String description,
    String? pickupAddress,
    String? dropOffAddress,
    String? passengerName,
  }) async {
    await _dio.post(Endpoints.tickets, data: {
      'rideId': rideId,
      'issueType': issueType,
      'description': description,
      if (pickupAddress  != null) 'pickupAddress':  pickupAddress,
      if (dropOffAddress != null) 'dropOffAddress': dropOffAddress,
      if (passengerName  != null) 'passengerName':  passengerName,
    });
  }

  /// Poll trip status (coordinates + lifecycle fields)
  Future<Map<String, dynamic>> getStatus(String rideId) async {
    final res = await _dio.get(Endpoints.tripStatus(rideId));
    return res.data as Map<String, dynamic>;
  }
}
