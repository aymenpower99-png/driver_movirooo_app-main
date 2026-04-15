import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';
import '../core/models/offer_model.dart';

/// HTTP calls for dispatch: heartbeat, online/offline, offers.
class DispatchService {
  final Dio _dio = ApiClient.instance.dio;

  // ── Location + status ─────────────────────────────────────────────────────
  Future<void> heartbeat() async {
    await _dio.patch(Endpoints.heartbeat);
  }

  Future<void> goOnline() async {
    await _dio.patch(Endpoints.goOnline);
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
}
