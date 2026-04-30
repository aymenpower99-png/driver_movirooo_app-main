// lib/pages/tracking/tracking_page.dart

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:moviroo_driver_app/core/models/geo_point.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/services/background/background_tracking_service.dart';
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
  RideStatus _status = RideStatus.assigned;

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

    _controller = TrackingPageController(
      rideId: widget.ride.id,
      pickupPt: _pickupPt,
      dropoffPt: _dropoffPt,
      onPositionUpdate: _onPositionUpdate,
      onAnimationTick: _onAnimationTick,
    );

    _controller.initialize(this);

    // Start background tracking service
    debugPrint(' [TrackingPage] Starting background tracking service...');
    BackgroundTrackingService.startTracking(widget.ride.id);
    debugPrint(' [TrackingPage] Background tracking service started');

    _controller.subscribeToGpsStreams();

    _mapLogic = TrackingMapLogic(
      pickupPt: _pickupPt,
      dropoffPt: _dropoffPt,
      onEtaUpdate: (_, __, ___) {},
    );
  }

  void _onPositionUpdate(GeoPoint position, double bearing) {
    debugPrint(
      '🗺️ [TrackingPage] Position update received: ${position.lat}, ${position.lon}',
    );

    // Note: marker movement & rotation are handled smoothly via _onAnimationTick.
    // We only handle camera + route + ETA refresh here.
    _mapLogic.animateToDriver(position, bearing: bearing);

    if (_status == RideStatus.onTheWay && !_isInTrip) {
      _mapLogic.drawPhase1Route(position);
    }
    _mapLogic.maybeRefreshEta(position, _isPrePickup, _isInTrip);
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
    setState(() => _status = newStatus);
    switch (newStatus) {
      case RideStatus.onTheWay:
        if (_controller.driverPosition != null)
          _mapLogic.drawPhase1Route(_controller.driverPosition!);
        break;
      case RideStatus.arrived:
        if (_controller.driverPosition != null) {
          _mapLogic.fitBoundsDriverToPickup(_controller.driverPosition!);
        }
        break;
      case RideStatus.startRide:
        await _mapLogic.clearRoute();
        _mapLogic.drawPhase2Route(_controller.driverPosition);
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
            ride: widget.ride,
            onStatusChanged: _onStatusChanged,
          ),
        ],
      ),
    );
  }
}
