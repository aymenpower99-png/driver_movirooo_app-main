// lib/pages/tracking/tracking_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:moviroo_driver_app/core/models/geo_point.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/services/location/location_tracking_service.dart';
import 'package:moviroo_driver_app/services/background/background_tracking_service.dart';
import 'package:moviroo_driver_app/providers/online_provider.dart';
import 'package:moviroo_driver_app/services/background/permission_state_storage.dart';
import 'package:provider/provider.dart';
import 'ride_model.dart';
import 'tracking_bottom_sheet.dart';
import 'tracking_map_logic.dart';
import 'widgets/status/status_step_indicator.dart';
import 'widgets/map/tracking_map_btn.dart';
import 'helpers/geo_math.dart';

class TrackPassengerPage extends StatefulWidget {
  final RideModel ride;
  const TrackPassengerPage({super.key, required this.ride});

  static Route<void> route(RideModel ride) =>
      MaterialPageRoute(builder: (_) => TrackPassengerPage(ride: ride));

  @override
  State<TrackPassengerPage> createState() => _TrackPassengerPageState();
}

class _TrackPassengerPageState extends State<TrackPassengerPage>
    with TickerProviderStateMixin {
  RideStatus _status = RideStatus.assigned;

  GeoPoint? _driverPosition;
  double _driverBearing = 0;
  GeoPoint? _prevPosition;

  AnimationController? _moveAnim;
  GeoPoint? _animStart;
  GeoPoint? _animEnd;

  late TrackingMapLogic _mapLogic;
  final LocationTrackingService _locationService = LocationTrackingService();
  StreamSubscription<geo.Position>? _positionSubscription;
  StreamSubscription<Map<String, dynamic>?>? _bgGpsSubscription;

  // Tracking state
  bool _canTrack = false;
  String? _trackingBlockReason;

  static const _defaultPt = GeoPoint(36.8189, 10.1658);

  GeoPoint get _pickupPt => widget.ride.pickupLat != null
      ? GeoPoint(widget.ride.pickupLat!, widget.ride.pickupLon!)
      : _defaultPt;

  GeoPoint get _dropoffPt => widget.ride.dropoffLat != null
      ? GeoPoint(widget.ride.dropoffLat!, widget.ride.dropoffLon!)
      : _defaultPt;

  bool get _isPrePickup =>
      _status == RideStatus.assigned || _status == RideStatus.onTheWay;
  bool get _isInTrip =>
      _status == RideStatus.startRide || _status == RideStatus.completed;

  @override
  void initState() {
    super.initState();

    _mapLogic = TrackingMapLogic(
      pickupPt: _pickupPt,
      dropoffPt: _dropoffPt,
      onEtaUpdate: (_, __, ___) {},
    );

    _moveAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addListener(_onMoveAnimTick);

    // Check if driver can track (must be online + have background permission)
    _checkTrackingConditions();

    // Start foreground GPS stream for UI updates (no socket emission)
    _locationService.startTracking(widget.ride.id);

    // Start background service tracking (handles GPS + WebSocket in isolate)
    BackgroundTrackingService.startTracking(widget.ride.id);

    // Subscribe to foreground service's position stream
    _positionSubscription = _locationService.positionStream.listen(
      _onNewPosition,
    );

    // Subscribe to background service GPS bridge (works when app backgrounded)
    _bgGpsSubscription = BackgroundTrackingService.onGpsUpdate.listen((data) {
      if (data == null) return;
      final lat = data['latitude'] as double?;
      final lng = data['longitude'] as double?;
      if (lat != null && lng != null) {
        _onNewPositionFromCoords(lat, lng);
      }
    });
  }

  /// Check if driver is online and has background permission before allowing tracking
  Future<void> _checkTrackingConditions() async {
    final onlineProvider = context.read<OnlineProvider>();
    final isOnline = onlineProvider.isOnline;
    final hasPermission = await PermissionStateStorage.isGranted();

    if (!isOnline) {
      setState(() {
        _canTrack = false;
        _trackingBlockReason = 'You must go online to track this ride';
      });
      return;
    }

    if (!hasPermission) {
      setState(() {
        _canTrack = false;
        _trackingBlockReason =
            'Background location permission is required for tracking. Please grant permission in settings.';
      });
      return;
    }

    setState(() {
      _canTrack = true;
      _trackingBlockReason = null;
    });
  }

  /// Handle GPS position from background service bridge (lat/lng only).
  void _onNewPositionFromCoords(double lat, double lng) {
    final newPt = GeoPoint(lat, lng);
    if (_driverPosition != null) {
      _driverBearing = GeoMath.calculateBearing(_driverPosition!, newPt);
    }
    _prevPosition = _driverPosition ?? newPt;
    _driverPosition = newPt;

    _animStart = _prevPosition;
    _animEnd = newPt;
    _moveAnim?.forward(from: 0.0);

    if (_isPrePickup || _isInTrip) {
      _mapLogic.animateToDriver(newPt, bearing: _driverBearing);
    }
    if (_status == RideStatus.onTheWay && !_isInTrip) {
      _mapLogic.drawPhase1Route(newPt);
    }
    _mapLogic.maybeRefreshEta(newPt, _isPrePickup, _isInTrip);
  }

  void _onNewPosition(geo.Position pos) {
    final newPt = GeoPoint(pos.latitude, pos.longitude);
    if (_driverPosition != null) {
      _driverBearing = GeoMath.calculateBearing(_driverPosition!, newPt);
    }
    _prevPosition = _driverPosition ?? newPt;
    _driverPosition = newPt;

    _animStart = _prevPosition;
    _animEnd = newPt;
    _moveAnim?.forward(from: 0.0);

    if (_isPrePickup || _isInTrip) {
      _mapLogic.animateToDriver(newPt, bearing: _driverBearing);
    }
    if (_status == RideStatus.onTheWay && !_isInTrip) {
      _mapLogic.drawPhase1Route(_driverPosition!);
    }
    _mapLogic.maybeRefreshEta(newPt, _isPrePickup, _isInTrip);
  }

  void _onMoveAnimTick() {
    if (_animStart == null || _animEnd == null) return;
    final t = Curves.easeInOut.transform(_moveAnim!.value);
    final lat = GeoMath.lerpDouble(_animStart!.lat, _animEnd!.lat, t);
    final lon = GeoMath.lerpDouble(_animStart!.lon, _animEnd!.lon, t);
    _mapLogic.updateDriverSymbol(GeoPoint(lat, lon), _driverBearing);
  }

  void _onMapCreated(MapboxMap map) {
    _mapLogic.onMapCreated(map);
    map.compass.updateSettings(CompassSettings(enabled: false));
    map.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
  }

  Future<void> _onStyleLoaded() => _mapLogic.onStyleLoaded();

  Future<void> _onStatusChanged(RideStatus newStatus) async {
    setState(() => _status = newStatus);
    switch (newStatus) {
      case RideStatus.onTheWay:
        if (_driverPosition != null)
          _mapLogic.drawPhase1Route(_driverPosition!);
        break;
      case RideStatus.arrived:
        if (_driverPosition != null) {
          _mapLogic.fitBoundsDriverToPickup(_driverPosition!);
        }
        break;
      case RideStatus.startRide:
        // Clear the pickup route, then draw a new route to drop-off
        await _mapLogic.clearRoute();
        _mapLogic.drawPhase2Route(_driverPosition);
        break;
      case RideStatus.completed:
        _mapLogic.stopAnimations();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _moveAnim?.dispose();
    _mapLogic.dispose();
    _positionSubscription?.cancel();
    _bgGpsSubscription?.cancel();
    _locationService.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Stack(
        children: [
          Positioned.fill(
            child: MapWidget(
              styleUri: isDark
                  ? MapboxStyles.DARK
                  : MapboxStyles.MAPBOX_STREETS,
              cameraOptions: CameraOptions(
                center: Point(
                  coordinates: Position(
                    (_driverPosition ?? _pickupPt).lon,
                    (_driverPosition ?? _pickupPt).lat,
                  ),
                ),
                zoom: 14.0,
              ),
              onMapCreated: _onMapCreated,
              onStyleLoadedListener: (StyleLoadedEventData _) =>
                  _onStyleLoaded(),
            ),
          ),

          // Show blocking message if tracking is not allowed
          if (!_canTrack && _trackingBlockReason != null)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.all(24),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_off,
                            size: 48,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tracking Disabled',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _trackingBlockReason!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Go to Settings > Apps > Moviroo Driver > Location > "Allow all the time"',
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Go Back'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          Positioned(
            right: 16,
            bottom: 320,
            child: Column(
              children: [
                TrackingMapBtn(
                  icon: Icons.my_location_rounded,
                  onTap: () {
                    if (_driverPosition != null) {
                      _mapLogic.animateToDriver(
                        _driverPosition!,
                        bearing: _driverBearing,
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
                TrackingMapBtn(
                  icon: Icons.zoom_out_map_rounded,
                  onTap: () {
                    if (_isPrePickup || _status == RideStatus.arrived) {
                      _driverPosition != null
                          ? _mapLogic.fitBoundsDriverToPickup(_driverPosition!)
                          : _mapLogic.fitToPickup();
                    } else {
                      _mapLogic.fitToFullRoute();
                    }
                  },
                ),
              ],
            ),
          ),

          Positioned(
            top: top + 12,
            left: 12,
            child: TrackingMapBtn(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),

          Positioned(
            top: top + 12,
            left: 62,
            right: 16,
            child: StatusStepIndicator(current: _status),
          ),

          TrackingBottomSheet(
            ride: widget.ride,
            onStatusChanged: _onStatusChanged,
          ),
        ],
      ),
    );
  }
}
