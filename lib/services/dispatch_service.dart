import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';
import '../core/models/offer_model.dart';
import '../core/models/ride_model.dart';

/// HTTP calls for dispatch: heartbeat, online/offline, offers, rides.
class DispatchService {
  final Dio _dio = ApiClient.instance.dio;

  // ── Location + status ─────────────────────────────────────────────────────
  Future<void> heartbeat({double? lat, double? lng}) async {
    await _dio.patch(
      Endpoints.heartbeat,
      data: (lat != null && lng != null) ? {'lat': lat, 'lng': lng} : null,
    );
  }

  Future<void> goOnline({double? lat, double? lng}) async {
    await _dio.patch(
      Endpoints.goOnline,
      data: (lat != null && lng != null) ? {'lat': lat, 'lng': lng} : null,
    );
  }

  Future<void> goOffline() async {
    await _dio.patch(Endpoints.goOffline);
  }

  // ── Offers ────────────────────────────────────────────────────────────────
  Future<List<OfferModel>> getPendingOffers() async {
    final res  = await _dio.get(Endpoints.pendingOffers);
    final list = res.data as List<dynamic>;
    return list
        .map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> acceptOffer(String offerId) async {
    await _dio.post(Endpoints.acceptOffer(offerId));
  }

  Future<void> rejectOffer(String offerId, {String? reason}) async {
    await _dio.post(
      Endpoints.rejectOffer(offerId),
      data: reason != null ? {'reason': reason} : null,
    );
  }

  // ── Driver Rides ──────────────────────────────────────────────────────
  Future<List<RideModel>> getDriverRides() async {
    final res = await _dio.get(Endpoints.rides);
    final list = res.data as List<dynamic>;
    return list
        .map((e) => RideModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
