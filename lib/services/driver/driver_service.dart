import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/models/driver_model.dart';

/// HTTP calls related to the driver's own profile and availability.
class DriverService {
  final Dio _dio = ApiClient.instance.dio;

  Future<DriverModel> getMe() async {
    final res = await _dio.get(Endpoints.driverMe);
    return DriverModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> setAvailability(String status) async {
    await _dio.patch(Endpoints.driverAvailability, data: {'status': status});
  }

  /// Parse a dynamic value to bool safely
  static bool _parseBool(dynamic value, {bool defaultValue = true}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    if (value is num) return value != 0;
    return defaultValue;
  }

  /// Fetch current notification preferences from backend.
  Future<Map<String, bool>> getNotificationPrefs() async {
    final res = await _dio.get(Endpoints.notificationPrefs);
    final data = res.data as Map<String, dynamic>;
    return {
      'pushEnabled': _parseBool(data['pushEnabled'], defaultValue: true),
      'emailEnabled': _parseBool(data['emailEnabled'], defaultValue: true),
    };
  }

  /// Persist notification preferences to backend.
  /// Returns the committed values `{pushEnabled, emailEnabled}`.
  Future<Map<String, bool>> updateNotificationPrefs({
    bool? pushEnabled,
    bool? emailEnabled,
  }) async {
    final res = await _dio.patch(
      Endpoints.notificationPrefs,
      data: {
        if (pushEnabled != null) 'pushEnabled': pushEnabled,
        if (emailEnabled != null) 'emailEnabled': emailEnabled,
      },
    );
    final data = res.data as Map<String, dynamic>;
    return {
      'pushEnabled': _parseBool(
        data['pushEnabled'],
        defaultValue: pushEnabled ?? true,
      ),
      'emailEnabled': _parseBool(
        data['emailEnabled'],
        defaultValue: emailEnabled ?? true,
      ),
    };
  }

  /// One-time migration: push legacy SharedPreferences monthly time to backend.
  /// Idempotent — backend only writes if its counter is currently 0.
  Future<void> seedMonthlyOnlineTime(int ms, String month) async {
    // Validate: max 31 days in milliseconds (~2.68 billion)
    const maxMonthlyMs = 31 * 24 * 60 * 60 * 1000;
    if (ms < 0 || ms > maxMonthlyMs) {
      print(
        '[DriverService] Invalid monthlyOnlineMs: $ms (max: $maxMonthlyMs) - skipping migration',
      );
      return;
    }
    await _dio.post(
      Endpoints.driverSeedMonthlyTime,
      data: {'monthlyOnlineMs': ms, 'month': month},
    );
  }

  /// Update monthly online time by adding session duration to backend.
  /// Backend adds the received duration to the existing monthly total.
  Future<void> updateMonthlyOnlineTime(int sessionMs) async {
    // Validate: max 24 hours in milliseconds for a single session
    const maxSessionMs = 24 * 60 * 60 * 1000;
    if (sessionMs < 0 || sessionMs > maxSessionMs) {
      print(
        '[DriverService] Invalid sessionMs: $sessionMs (max: $maxSessionMs) - skipping update',
      );
      return;
    }
    await _dio.patch(
      Endpoints.driverUpdateMonthlyTime,
      data: {'sessionMs': sessionMs},
    );
  }
}
