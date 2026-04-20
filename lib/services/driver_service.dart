import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';
import '../core/models/driver_model.dart';

/// HTTP calls related to the driver's own profile and availability.
class DriverService {
  final Dio _dio = ApiClient.instance.dio;

  Future<DriverModel> getMe() async {
    final res = await _dio.get(Endpoints.driverMe);
    return DriverModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> setAvailability(String status) async {
    await _dio.patch(
      Endpoints.driverAvailability,
      data: {'status': status},
    );
  }

  /// Fetch current notification preferences from backend.
  Future<Map<String, bool>> getNotificationPrefs() async {
    final res = await _dio.get(Endpoints.notificationPrefs);
    final data = res.data as Map<String, dynamic>;
    return {
      'pushEnabled':  (data['pushEnabled']  as bool?) ?? true,
      'emailEnabled': (data['emailEnabled'] as bool?) ?? true,
    };
  }

  /// Persist notification preferences to backend.
  Future<void> updateNotificationPrefs({
    bool? pushEnabled,
    bool? emailEnabled,
  }) async {
    await _dio.patch(Endpoints.notificationPrefs, data: {
      ?'pushEnabled':  pushEnabled,
      ?'emailEnabled': emailEnabled,
    });
  }
}
