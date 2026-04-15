import 'package:flutter/foundation.dart';
import '../core/models/user_model.dart';
import '../core/storage/token_storage.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Manages authentication state across the entire app.
/// Exposed via Provider — screens call methods here, never talk to AuthService directly.
class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();

  AuthStatus _status    = AuthStatus.unknown;
  UserModel? _user;
  String?    _error;
  bool       _loading   = false;
  String?    _preAuthToken; // held between login step 1 & OTP step 2

  // ── Getters ───────────────────────────────────────────────────────────────
  AuthStatus get status       => _status;
  UserModel? get user         => _user;
  String?    get error        => _error;
  bool       get loading      => _loading;
  bool       get isAuth       => _status == AuthStatus.authenticated;
  String?    get preAuthToken => _preAuthToken;

  // ── Init — check persisted session on app start ───────────────────────────
  Future<void> init() async {
    if (await TokenStorage.hasSession()) {
      try {
        final cached = await TokenStorage.getUser();
        if (cached != null) {
          _user = UserModel.fromJsonString(cached);
        }
        // Refresh user from backend (silently)
        _user = await _auth.getMe();
        await TokenStorage.saveUser(_user!.toJsonString());
        _status = AuthStatus.authenticated;
      } catch (_) {
        _status = AuthStatus.unauthenticated;
      }
    } else {
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
        lastName:  lastName,
        email:     email,
        phone:     phone,
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
        newPassword:     newPassword,
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
    await _auth.logout();
    _user         = null;
    _preAuthToken = null;
    _status       = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Future<void> _finalize(Map<String, dynamic> data) async {
    final access  = data['accessToken']  as String;
    final refresh = data['refreshToken'] as String;
    await TokenStorage.saveTokens(access: access, refresh: refresh);

    if (data['user'] != null) {
      _user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    } else {
      _user = await _auth.getMe();
    }
    await TokenStorage.saveUser(_user!.toJsonString());

    _preAuthToken = null;
    _status       = AuthStatus.authenticated;
    _loading      = false;
    _error        = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    _error   = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _error   = msg;
    _loading = false;
    notifyListeners();
  }

  String _friendlyError(Exception e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('401') || msg.contains('unauthorized') || msg.contains('invalid')) {
      return 'Email or password is incorrect.';
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
