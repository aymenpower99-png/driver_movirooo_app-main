import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure persistence for JWT access + refresh tokens and cached user JSON.
/// Uses OS keychain (Android Keystore / iOS Keychain) — never stored in plaintext.
class TokenStorage {
  static const _store    = FlutterSecureStorage();
  static const _kAccess  = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _kUser    = 'user_json';

  // ── Write ─────────────────────────────────────────────────────────────────
  static Future<void> saveTokens({
    required String access,
    required String refresh,
  }) =>
      Future.wait([
        _store.write(key: _kAccess,  value: access),
        _store.write(key: _kRefresh, value: refresh),
      ]);

  static Future<void> saveUser(String json) =>
      _store.write(key: _kUser, value: json);

  // ── Read ──────────────────────────────────────────────────────────────────
  static Future<String?> getAccess()  => _store.read(key: _kAccess);
  static Future<String?> getRefresh() => _store.read(key: _kRefresh);
  static Future<String?> getUser()    => _store.read(key: _kUser);

  static Future<bool> hasSession() async {
    final t = await getAccess();
    return t != null && t.isNotEmpty;
  }

  // ── Clear (logout) ────────────────────────────────────────────────────────
  static Future<void> clear() => _store.deleteAll();
}
