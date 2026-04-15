import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../storage/token_storage.dart';
import 'endpoints.dart';

/// Global navigator key — used by the auth interceptor to redirect to /driver/login
/// when the refresh token is expired (hard logout). Register in MaterialApp.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Singleton Dio client with rotation-token auth interceptor.
///
/// Flow on 401:
///   1. Call POST /auth/refresh with current refresh token as Bearer.
///   2. Store new access + refresh tokens (rotation).
///   3. Retry the original request with the new access token.
///   4. If refresh also fails → clear tokens → navigate to login.
///   Driver stays logged in forever unless they log out manually.
class ApiClient {
  ApiClient._();
  static final ApiClient _i = ApiClient._();
  static ApiClient get instance => _i;

  late final Dio _dio = _build();
  Dio get dio => _dio;

  Dio _build() {
    final dio = Dio(
      BaseOptions(
        baseUrl:        Endpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers:        {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );
    dio.interceptors.add(_AuthInterceptor(dio));
    return dio;
  }
}

// ── Auth interceptor ──────────────────────────────────────────────────────────
class _AuthInterceptor extends QueuedInterceptorsWrapper {
  _AuthInterceptor(this._dio);
  final Dio _dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await TokenStorage.getAccess();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Don't retry the refresh call itself — would loop
    if (err.requestOptions.path.contains(Endpoints.refresh)) {
      await _forceLogout();
      handler.next(err);
      return;
    }

    final refreshToken = await TokenStorage.getRefresh();
    if (refreshToken == null) {
      await _forceLogout();
      handler.next(err);
      return;
    }

    try {
      // Use a clean Dio instance (no interceptors) to avoid recursion
      final res = await Dio(
        BaseOptions(
          baseUrl: Endpoints.baseUrl,
          headers: {
            'Authorization':              'Bearer $refreshToken',
            'Content-Type':               'application/json',
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      ).post(Endpoints.refresh);

      final newAccess  = res.data['accessToken']  as String;
      final newRefresh = res.data['refreshToken'] as String;
      await TokenStorage.saveTokens(access: newAccess, refresh: newRefresh);

      // Retry original request with new access token
      final opts = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newAccess';
      final retried = await _dio.fetch(opts);
      handler.resolve(retried);
    } catch (_) {
      await _forceLogout();
      handler.next(err);
    }
  }

  Future<void> _forceLogout() async {
    await TokenStorage.clear();
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/driver/login',
      (_) => false,
    );
  }
}
