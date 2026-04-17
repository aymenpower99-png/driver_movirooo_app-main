import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';
import '../core/models/earnings_model.dart';

class EarningsService {
  final _dio = ApiClient.instance.dio;

  Future<EarningsModel> getMyEarnings({String? month}) async {
    final params = <String, dynamic>{};
    if (month != null) params['month'] = month;
    final res = await _dio.get(Endpoints.earningsMe, queryParameters: params);
    return EarningsModel.fromJson(res.data as Map<String, dynamic>);
  }
}
