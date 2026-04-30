import 'package:shared_preferences/shared_preferences.dart';

enum PermissionState {
  neverRequested,
  granted,
  denied,
  permanentlyDenied,
}

/// Storage for background location permission state.
/// Persists whether permission was granted/denied so we don't spam the user.
class PermissionStateStorage {
  static const String _key = 'background_location_permission_state';

  /// Get the current permission state
  static Future<PermissionState> getState() async {
    final prefs = await SharedPreferences.getInstance();
    final stateString = prefs.getString(_key);
    if (stateString == null) return PermissionState.neverRequested;
    return PermissionState.values.firstWhere(
      (e) => e.name == stateString,
      orElse: () => PermissionState.neverRequested,
    );
  }

  /// Set the permission state
  static Future<void> setState(PermissionState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, state.name);
  }

  /// Reset permission state (for testing/debugging)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Check if permission is granted
  static Future<bool> isGranted() async {
    final state = await getState();
    return state == PermissionState.granted;
  }

  /// Check if permission was denied (either temporarily or permanently)
  static Future<bool> isDenied() async {
    final state = await getState();
    return state == PermissionState.denied || state == PermissionState.permanentlyDenied;
  }

  /// Check if we should request permission (only if never requested)
  static Future<bool> shouldRequest() async {
    final state = await getState();
    return state == PermissionState.neverRequested;
  }
}
