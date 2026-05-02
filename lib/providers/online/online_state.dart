import '../../services/background/permission_state_storage.dart';
import '../../core/models/driver_model.dart';

/// State management for OnlineProvider.
/// Contains all state variables and getters.
class OnlineState {
  // Online status
  bool _isOnline = false;
  bool _loading = false;
  String? _error;
  DriverModel? _driverProfile;
  bool _initialized = false;

  // Active ride tracking
  String? _activeRideId;

  // GPS and permission requirements
  bool _gpsRequired = false;
  bool _permissionRequired = false;

  // Forced offline flag
  bool _forcedOffline = false;

  // Getters
  bool get isOnline => _isOnline;
  bool get loading => _loading;
  String? get error => _error;
  DriverModel? get driverProfile => _driverProfile;
  bool get initialized => _initialized;
  String? get activeRideId => _activeRideId;
  bool get gpsRequired => _gpsRequired;
  bool get permissionRequired => _permissionRequired;
  bool get forcedOffline => _forcedOffline;

  // Setters
  set isOnline(bool value) => _isOnline = value;
  set loading(bool value) => _loading = value;
  set error(String? value) => _error = value;
  set driverProfile(DriverModel? value) => _driverProfile = value;
  set initialized(bool value) => _initialized = true;
  set activeRideId(String? value) => _activeRideId = value;
  set gpsRequired(bool value) => _gpsRequired = value;
  set permissionRequired(bool value) => _permissionRequired = value;
  set forcedOffline(bool value) => _forcedOffline = value;

  /// Check if background location permission is granted
  Future<bool> get hasBackgroundPermission async {
    return await PermissionStateStorage.isGranted();
  }

  /// Get current permission state
  Future<PermissionState> get permissionState async {
    return await PermissionStateStorage.getState();
  }

  void clearGpsRequired() {
    _gpsRequired = false;
  }

  void clearPermissionRequired() {
    _permissionRequired = false;
  }

  void clearError() {
    _error = null;
  }
}
