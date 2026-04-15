import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';
import '../core/models/user_model.dart';
import '../core/storage/token_storage.dart';

/// All HTTP calls related to authentication.
class AuthService {
  final Dio _dio = ApiClient.instance.dio;

  // ── Login (step 1) ────────────────────────────────────────────────────────
  /// Returns either:
  ///   • { 'accessToken', 'refreshToken', 'user' } → direct login (no OTP)
  ///   • { 'preAuthToken' }                         → OTP required
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post(
      Endpoints.login,
      data: {'email': email, 'password': password},
    );
    return res.data as Map<String, dynamic>;
  }

  // ── Login (step 2 — OTP) ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> verifyLoginOtp(
    String preAuthToken,
    String code,
  ) async {
    final res = await _dio.post(
      Endpoints.verifyLoginOtp,
      data: {'preAuthToken': preAuthToken, 'code': code},
    );
    return res.data as Map<String, dynamic>;
  }

  // ── Forgot password ───────────────────────────────────────────────────────
  Future<void> forgotPassword(String email) async {
    await _dio.post(Endpoints.forgotPassword, data: {'email': email});
  }

  // ── Get current user ──────────────────────────────────────────────────────
  Future<UserModel> getMe() async {
    final res = await _dio.get(Endpoints.me);
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }

  // ── Update profile ────────────────────────────────────────────────────────
  Future<UserModel> updateMe({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) async {
    final data = <String, dynamic>{};
    if (firstName != null) data['firstName'] = firstName;
    if (lastName  != null) data['lastName']  = lastName;
    if (email     != null) data['email']     = email;
    if (phone     != null) data['phone']     = phone;

    final res = await _dio.patch(Endpoints.me, data: data);
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }

  // ── Update password ───────────────────────────────────────────────────────
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.patch(
      Endpoints.updatePassword,
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _dio.post(Endpoints.logout);
    } catch (_) {
      // Best-effort — always clear local tokens
    } finally {
      await TokenStorage.clear();
    }
  }
}
