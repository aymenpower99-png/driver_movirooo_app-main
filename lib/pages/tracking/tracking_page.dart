// lib/pages/tracking/tracking_page.dart

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:moviroo_driver_app/core/models/geo_point.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/services/background/background_tracking_service.dart';
import 'package:moviroo_driver_app/services/tracking/tracking_socket_service.dart';
import 'ride_model.dart';
import 'tracking_bottom_sheet.dart';
import 'tracking_map_logic.dart';
import 'controllers/tracking_page_controller.dart';
import 'widgets/status/status_step_indicator.dart';
import 'widgets/map/tracking_map_btn.dart';

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
  late TrackingPageController _controller;
  late TrackingMapLogic _mapLogic;
  late RideStatus _status;
  late RideModel _currentRide;
  final TrackingSocketService _socketService = TrackingSocketService();

  GeoPoint get _pickupPt => widget.ride.pickupLat != null
      ? GeoPoint(widget.ride.pickupLat!, widget.ride.pickupLon!)
      : throw Exception('Pickup coordinates required');

  GeoPoint get _dropoffPt => widget.ride.dropoffLat != null
      ? GeoPoint(widget.ride.dropoffLat!, widget.ride.dropoffLon!)
      : throw Exception('Dropoff coordinates required');

  bool get _isPrePickup =>
      _status == RideStatus.assigned || _status == RideStatus.onTheWay;
  bool get _isInTrip =>
      _status == RideStatus.startRide || _status == RideStatus.completed;

  @override
  void initState() {
    super.initState();
    debugPrint(' [TrackingPage] Page opened for ride: ${widget.ride.id}');

    _status = widget.ride.status;
    _currentRide = widget.ride;

    _controller = TrackingPageController(
      rideId: widget.ride.id,
      pickupPt: _pickupPt,
      dropoffPt: _dropoffPt,
      onPositionUpdate: _onPositionUpdate,
      onAnimationTick: _onAnimationTick,
    );

    _controller.initialize(this);

    // Start background tracking service
    debugPrint(
      '🗺️ [TrackingPage] Requesting GPS tracking for ride: ${widget.ride.id}',
    );
    debugPrint(
      '🗺️ [TrackingPage] NOTE: GPS should already be running if driver is online with active ride',
    );
    debugPrint(
      '🗺️ [TrackingPage] This call ensures GPS is running (idempotent)',
    );
    BackgroundTrackingService.startTracking(widget.ride.id);
    debugPrint('🗺️ [TrackingPage] GPS tracking request sent');

    _controller.subscribeToGpsStreams();

    _mapLogic = TrackingMapLogic(
      pickupPt: _pickupPt,
      dropoffPt: _dropoffPt,
      onEtaUpdate: (_, __, ___) {},
    );

    // Connect to tracking socket for reroute events
    _socketService.onReroute = (routeGeometry, sequence) {
      debugPrint(
        '🗺️ [TrackingPage] Reroute event received - sequence=$sequence',
      );
      _mapLogic.handleReroute(routeGeometry, sequence);
    };

    _socketService.connect(widget.ride.id);
  }

  void _onPositionUpdate(GeoPoint position, double bearing) {
    // Check for route deviation and trigger re-routing if needed
    _mapLogic.checkAndReroute(position, _isPrePickup);

    // Note: marker movement, rotation AND camera follow are handled smoothly
    // via _onAnimationTick -> updateDriverSymbol (which pans camera without
    // resetting zoom). No need to call animateToDriver here on every update.

    if (_status == RideStatus.onTheWay && !_isInTrip) {
      _mapLogic.drawPhase1Route(position);
    }
    _mapLogic.maybeRefreshEta(position, _isPrePickup, _isInTrip);

    // Truncate the route line so the portion behind the driver disappears
    _mapLogic.truncateRoute(position);
  }

  void _onAnimationTick(GeoPoint position, double bearing) {
    // Smoothly move and rotate the driver marker on every animation frame.
    _mapLogic.updateDriverSymbol(position, bearing);
  }

  void _onMapCreated(MapboxMap map) {
    _mapLogic.onMapCreated(map);
    map.compass.updateSettings(CompassSettings(enabled: false));
    map.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
  }

  Future<void> _onStyleLoaded() async {
    await _mapLogic.onStyleLoaded();
    // If we already have a driver position, update the marker immediately
    if (_controller.driverPosition != null) {
      _mapLogic.updateDriverSymbol(
        _controller.driverPosition!,
        _controller.driverBearing,
      );
      // Center camera on driver position
      _mapLogic.animateToDriver(
        _controller.driverPosition!,
        bearing: _controller.driverBearing,
      );
    }
  }

  Future<void> _onStatusChanged(RideStatus newStatus) async {
    setState(() {
      _status = newStatus;
      _currentRide = RideModel(
        id: widget.ride.id,
        passenger: widget.ride.passenger,
        pickupAddress: widget.ride.pickupAddress,
        dropOffAddress: widget.ride.dropOffAddress,
        distanceKm: widget.ride.distanceKm,
        etaMinutes: widget.ride.etaMinutes,
        earningsAmount: widget.ride.earningsAmount,
        currency: widget.ride.currency,
        pickupLat: widget.ride.pickupLat,
        pickupLon: widget.ride.pickupLon,
        dropoffLat: widget.ride.dropoffLat,
        dropoffLon: widget.ride.dropoffLon,
        status: newStatus,
      );
    });
    switch (newStatus) {
      case RideStatus.onTheWay:
        if (_controller.driverPosition != null) {
          _mapLogic.drawPhase1Route(_controller.driverPosition!);
          _mapLogic.fitBoundsDriverToPickup(_controller.driverPosition!);
        }
        break;
      case RideStatus.arrived:
        if (_controller.driverPosition != null) {
          _mapLogic.fitBoundsDriverToPickup(_controller.driverPosition!);
        }
        break;
      case RideStatus.startRide:
        await _mapLogic.clearRoute();
        _mapLogic.drawPhase2Route(_controller.driverPosition);
        _mapLogic.fitToFullRoute();
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
    debugPrint('🗺️ [TrackingPage] Page closing, disposing resources');
    _controller.dispose();
    _mapLogic.dispose();

    // Disconnect tracking socket
    _socketService.disconnect();

    // If the ride reached a terminal state (completed), make sure background
    // tracking is fully stopped. Cancel/end paths already stop it explicitly,
    // but this is a safety net for any other navigation away from the page.
    if (_status == RideStatus.completed) {
      debugPrint(
        '🗺️ [TrackingPage] Ride is COMPLETED — stopping background tracking',
      );
      BackgroundTrackingService.stopTracking();
      BackgroundTrackingService.stop();
    }
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
                    (_controller.driverPosition ?? _pickupPt).lon,
                    (_controller.driverPosition ?? _pickupPt).lat,
                  ),
                ),
                zoom: 14.0,
              ),
              onMapCreated: _onMapCreated,
              onStyleLoadedListener: (StyleLoadedEventData _) =>
                  _onStyleLoaded(),
              onCameraChangeListener: (CameraChangedEventData data) {
                // Only disable follow mode when user manually interacts with the map
                // (not during programmatic camera moves like following the driver)
                if (!_mapLogic.camera.isProgrammaticMove) {
                  _mapLogic.disableFollowMode();
                }
              },
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
                    if (_controller.driverPosition != null) {
                      _mapLogic.animateToDriver(
                        _controller.driverPosition!,
                        bearing: _controller.driverBearing,
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
                TrackingMapBtn(
                  icon: Icons.zoom_out_map_rounded,
                  onTap: () {
                    _mapLogic.fitBothMarkers();
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
            ride: _currentRide,
            onStatusChanged: _onStatusChanged,
          ),
        ],
      ),
    );
  }
}
