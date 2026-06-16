import 'dart:async';
import 'package:flutter/material.dart';
  import '../core/models/user_model.dart';
import '../core/api/api_client.dart';
import '../core/storage/token_storage.dart';
import '../services/auth/auth_service.dart';
import '../core/notifications/notification_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Manages authentication state across the entire app.
/// Exposed via Provider — screens call methods here, never talk to AuthService directly.
class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String? _error;
  bool _loading = false;
  String? _preAuthToken; // held between login step 1 & OTP step 2
  Timer? _statusTimer;

  /// Called by [main.dart] to wire up provider clearing on logout / login.
  void Function()? onClear;

  // ── Getters ───────────────────────────────────────────────────────────────
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get loading => _loading;
  bool get isAuth => _status == AuthStatus.authenticated;
  String? get preAuthToken => _preAuthToken;

  // ── Init — check persisted session on app start ───────────────────────────
  Future<void> init() async {
    try {
      if (await TokenStorage.hasSession()) {
        // Instant auth from cached user — no network wait, no splash delay
        final cached = await TokenStorage.getUser();
        if (cached != null) {
          _user = UserModel.fromJsonString(cached);
          _status = AuthStatus.authenticated;
          notifyListeners(); // splash disappears immediately
          startAccountStatusCheck();

          // Refresh user from backend silently in background
          _auth
              .getMe()
              .then((freshUser) {
                _user = freshUser;
                TokenStorage.saveUser(freshUser.toJsonString());
                notifyListeners();
              })
              .catchError((_) {}); // ignore — cached user is good enough
          return;
        }

        // No cached user — must wait for network (first launch after login)
        try {
          _user = await _auth.getMe();
          await TokenStorage.saveUser(_user!.toJsonString());
          _status = AuthStatus.authenticated;
          startAccountStatusCheck();
        } catch (_) {
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  /// Returns true  → logged in directly (no OTP).
  /// Returns false → OTP required — caller should navigate to OTP screen.
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final data = await _auth.login(email, password);

      if (data.containsKey('accessToken')) {
        await _finalize(data);
        return true;
      } else if (data.containsKey('preAuthToken')) {
        _preAuthToken = data['preAuthToken'] as String;
        _setLoading(false);
        return false;
      }
      _setError('Unexpected response from server.');
      return false;
    } on Exception catch (e) {
      _setError(_friendlyError(e));
      return false;
    }
  }

  // ── OTP verification ──────────────────────────────────────────────────────
  Future<bool> verifyOtp(String code) async {
    if (_preAuthToken == null) return false;
    _setLoading(true);
    try {
      final data = await _auth.verifyLoginOtp(_preAuthToken!, code);
      await _finalize(data);
      return true;
    } on Exception catch (e) {
      _setError(_friendlyError(e));
      return false;
    }
  }

  // ── Forgot password ───────────────────────────────────────────────────────
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    try {
      await _auth.forgotPassword(email);
      _setLoading(false);
      return true;
    } on Exception catch (e) {
      _setError(_friendlyError(e));
      return false;
    }
  }

  // ── Update profile ────────────────────────────────────────────────────────
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) async {
    _setLoading(true);
    try {
      _user = await _auth.updateMe(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
      );
      await TokenStorage.saveUser(_user!.toJsonString());
      _setLoading(false);
      return true;
    } on Exception catch (e) {
      _setError(_friendlyError(e));
      return false;
    }
  }

  // ── Update password ───────────────────────────────────────────────────────
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    try {
      await _auth.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _setLoading(false);
      return true;
    } on Exception catch (e) {
      _setError(_friendlyError(e));
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    stopAccountStatusCheck();
    await _auth.logout();
    _user = null;
    _preAuthToken = null;
    _status = AuthStatus.unauthenticated;
    onClear?.call();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Future<void> _finalize(Map<String, dynamic> data) async {
    final access = data['accessToken'] as String;
    final refresh = data['refreshToken'] as String;
    await TokenStorage.saveTokens(access: access, refresh: refresh);

    if (data['user'] != null) {
      _user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    } else {
      _user = await _auth.getMe();
    }
    await TokenStorage.saveUser(_user!.toJsonString());

    _preAuthToken = null;
    _status = AuthStatus.authenticated;
    _loading = false;
    _error = null;
    onClear?.call();
    notifyListeners();
    startAccountStatusCheck();

    // Register FCM token after every successful login (no await — fire-and-forget)
    NotificationService.instance.registerFcmTokenAfterLogin().catchError((_) {});
  }

  void startAccountStatusCheck() {
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      try {
        final status = await _auth.getAccountStatus();
        if (status != null && status['status'] == 'blocked') {
          await _forceLogoutBlocked();
          stopAccountStatusCheck();
        }
      } catch (_) {
        // Ignore network errors
      }
    });
  }

  void stopAccountStatusCheck() {
    _statusTimer?.cancel();
    _statusTimer = null;
  }

  Future<void> _forceLogoutBlocked() async {
    await TokenStorage.clear();
    final ctx = navigatorKey.currentContext;
    if (ctx != null && ctx.mounted) {
      await showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Account Blocked'),
          content: const Text(
            'Your account has been blocked by an administrator. Please contact support for assistance.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/driver/login',
      (_) => false,
    );
  }

  void _setLoading(bool v) {
    _loading = v;
    _error = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    _loading = false;
    notifyListeners();
  }

  String _friendlyError(Exception e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('403') || msg.contains('forbidden')) {
      return 'This application is restricted to drivers approved and verified by the agency.';
    }
    if (msg.contains('401') ||
        msg.contains('unauthorized') ||
        msg.contains('invalid')) {
      return 'Invalid email or password. Please try again.';
    }
    if (msg.contains('socketexception') || msg.contains('connection')) {
      return 'Cannot connect to server. Check your network.';
    }
    if (msg.contains('timeout')) {
      return 'Request timed out. Try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
