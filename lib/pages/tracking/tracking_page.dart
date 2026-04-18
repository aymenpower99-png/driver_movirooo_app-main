// lib/pages/tracking/tracking_page.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/pages/tracking/ride_model.dart';
import 'package:moviroo_driver_app/pages/tracking/tracking_bottom_sheet.dart';
import 'package:moviroo_driver_app/pages/tracking/widgets/status_step_indicator.dart';
import 'package:moviroo_driver_app/services/tracking_socket_service.dart';
import 'package:moviroo_driver_app/services/osrm_route_service.dart';
import 'package:geolocator/geolocator.dart';

// ── OSM tile styles (free, no API key) ───────────────────────────────────────
const _osmStyleLight = 'https://tiles.openfreemap.org/styles/liberty';
const _osmStyleDark  = 'https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json';

class TrackPassengerPage extends StatefulWidget {
  final RideModel ride;

  const TrackPassengerPage({super.key, required this.ride});

  static Route<void> route(RideModel ride) => MaterialPageRoute(
        builder: (_) => TrackPassengerPage(ride: ride),
      );

  @override
  State<TrackPassengerPage> createState() => _TrackPassengerPageState();
}

class _TrackPassengerPageState extends State<TrackPassengerPage>
    with TickerProviderStateMixin {
  RideStatus _status = RideStatus.assigned;

  // Default: Tunisia
  static const LatLng _defaultCenter = LatLng(36.8189, 10.1658);

  MapLibreMapController? _mapController;
  final TrackingSocketService _socket = TrackingSocketService();

  LatLng? _driverPosition;
  LatLng? _prevDriverPosition;
  double _driverBearing = 0;
  StreamSubscription<Position>? _gpsSub;

  // Smooth animation
  AnimationController? _moveAnim;
  LatLng? _animStart;
  LatLng? _animEnd;

  // Pulse animation for arrival
  AnimationController? _pulseAnim;

  // Route line drawn?
  bool _routeDrawn = false;

  // ETA & distance overlay
  String _etaText = '';
  String _distText = '';

  LatLng get _pickupLatLng =>
      widget.ride.pickupLat != null && widget.ride.pickupLon != null
          ? LatLng(widget.ride.pickupLat!, widget.ride.pickupLon!)
          : _defaultCenter;

  LatLng get _dropoffLatLng =>
      widget.ride.dropoffLat != null && widget.ride.dropoffLon != null
          ? LatLng(widget.ride.dropoffLat!, widget.ride.dropoffLon!)
          : _defaultCenter;

  @override
  void initState() {
    super.initState();
    _moveAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addListener(_onMoveAnimTick);

    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _etaText = '${widget.ride.etaMinutes} min';
    _distText = '${widget.ride.distanceKm.toStringAsFixed(1)} km';

    _initSocket();
    _startGps();
  }

  // ── Socket ─────────────────────────────────────────────────────────────────
  Future<void> _initSocket() async {
    await _socket.connect(widget.ride.id);
    _socket.onLocationUpdate = (lat, lng) {
      // Passenger-side location update (could show on map if needed)
    };
  }

  // ── GPS streaming ──────────────────────────────────────────────────────────
  Future<void> _startGps() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return;
    }

    _gpsSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen(_onNewGpsPosition);
  }

  void _onNewGpsPosition(Position pos) {
    final newLl = LatLng(pos.latitude, pos.longitude);

    // Calculate bearing from previous position
    if (_driverPosition != null) {
      _driverBearing = _calculateBearing(_driverPosition!, newLl);
    }

    _prevDriverPosition = _driverPosition ?? newLl;
    _driverPosition = newLl;

    // Send to backend
    _socket.sendGps(
      rideId: widget.ride.id,
      latitude: pos.latitude,
      longitude: pos.longitude,
      speedKmh: (pos.speed * 3.6),
    );

    // Start smooth animation
    _animStart = _prevDriverPosition;
    _animEnd = newLl;
    _moveAnim?.forward(from: 0.0);

    // Follow camera
    _animateCamera(newLl, bearing: _driverBearing);
  }

  void _onMoveAnimTick() {
    if (_animStart == null || _animEnd == null || _mapController == null) return;
    final t = Curves.easeInOut.transform(_moveAnim!.value);
    final lat = _lerpDouble(_animStart!.latitude, _animEnd!.latitude, t);
    final lng = _lerpDouble(_animStart!.longitude, _animEnd!.longitude, t);

    _updateDriverMarker(LatLng(lat, lng), _driverBearing);
  }

  // ── Map callbacks ──────────────────────────────────────────────────────────
  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
  }

  void _onStyleLoaded() async {
    if (_mapController == null) return;

    // Add pickup marker
    await _mapController!.addSymbol(SymbolOptions(
      geometry: _pickupLatLng,
      iconImage: 'marker-15',
      iconSize: 1.8,
      iconColor: '#22C55E',
      textField: 'Pickup',
      textOffset: const Offset(0, 2.0),
      textColor: '#22C55E',
      textSize: 11,
    ));

    // Add dropoff marker
    await _mapController!.addSymbol(SymbolOptions(
      geometry: _dropoffLatLng,
      iconImage: 'marker-15',
      iconSize: 1.8,
      iconColor: '#A855F7',
      textField: 'Drop-off',
      textOffset: const Offset(0, 2.0),
      textColor: '#A855F7',
      textSize: 11,
    ));

    // Draw route line
    _drawRoute();

    // Fit camera to show full route
    _fitBoundsToRoute();
  }

  // ── Route drawing (OSRM real road route) ────────────────────────────────────
  Future<void> _drawRoute() async {
    if (_mapController == null || _routeDrawn) return;
    _routeDrawn = true;

    final pickup = _pickupLatLng;
    final dropoff = _dropoffLatLng;

    // Fetch real road geometry from OSRM
    final result = await OsrmRouteService.fetchRoute(pickup, dropoff);

    if (result != null && result.points.length >= 2) {
      // Update ETA/distance with real data
      setState(() {
        _etaText = result.etaText;
        _distText = result.distanceText;
      });

      // Ghost route (wider, transparent)
      await _mapController!.addLine(LineOptions(
        geometry: result.points,
        lineColor: '#A855F7',
        lineWidth: 7.0,
        lineOpacity: 0.15,
      ));

      // Main route line
      await _mapController!.addLine(LineOptions(
        geometry: result.points,
        lineColor: '#A855F7',
        lineWidth: 4.0,
        lineOpacity: 0.85,
      ));
    } else {
      // Fallback: straight line if OSRM fails
      await _mapController!.addLine(LineOptions(
        geometry: [pickup, dropoff],
        lineColor: '#A855F7',
        lineWidth: 4.0,
        lineOpacity: 0.8,
      ));

      await _mapController!.addLine(LineOptions(
        geometry: [pickup, dropoff],
        lineColor: '#A855F7',
        lineWidth: 6.0,
        lineOpacity: 0.2,
      ));
    }
  }

  // ── Camera control ─────────────────────────────────────────────────────────
  void _fitBoundsToRoute() {
    if (_mapController == null) return;
    final sw = LatLng(
      math.min(_pickupLatLng.latitude, _dropoffLatLng.latitude),
      math.min(_pickupLatLng.longitude, _dropoffLatLng.longitude),
    );
    final ne = LatLng(
      math.max(_pickupLatLng.latitude, _dropoffLatLng.latitude),
      math.max(_pickupLatLng.longitude, _dropoffLatLng.longitude),
    );
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(southwest: sw, northeast: ne),
      left: 60,
      right: 60,
      top: 120,
      bottom: 300,
    ));
  }

  void _animateCamera(LatLng target, {double? bearing}) {
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: target,
        zoom: 16.0,
        bearing: bearing ?? 0,
        tilt: 45.0,
      ),
    ));
  }

  // ── Driver marker update ───────────────────────────────────────────────────
  Circle? _driverCircle;

  Future<void> _updateDriverMarker(LatLng pos, double bearing) async {
    if (_mapController == null) return;

    // Remove old driver circle and add new one for smooth effect
    if (_driverCircle != null) {
      await _mapController!.removeCircle(_driverCircle!);
    }
    _driverCircle = await _mapController!.addCircle(CircleOptions(
      geometry: pos,
      circleRadius: 8,
      circleColor: '#A855F7',
      circleStrokeWidth: 3,
      circleStrokeColor: '#FFFFFF',
    ));

    setState(() {}); // update ETA overlay if needed
  }

  // ── Arrival pulse ──────────────────────────────────────────────────────────
  void _startArrivalPulse() {
    _pulseAnim?.repeat(reverse: true);
  }

  // ── Math helpers ───────────────────────────────────────────────────────────
  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;

  double _calculateBearing(LatLng from, LatLng to) {
    final dLon = _degToRad(to.longitude - from.longitude);
    final lat1 = _degToRad(from.latitude);
    final lat2 = _degToRad(to.latitude);
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return (_radToDeg(math.atan2(y, x)) + 360) % 360;
  }

  double _degToRad(double deg) => deg * math.pi / 180;
  double _radToDeg(double rad) => rad * 180 / math.pi;

  // ── Status change handler ──────────────────────────────────────────────────
  void _onStatusChanged(RideStatus newStatus) {
    setState(() => _status = newStatus);

    if (newStatus == RideStatus.arrived || newStatus == RideStatus.completed) {
      _startArrivalPulse();
    }

    if (newStatus == RideStatus.startRide) {
      // Zoom out to show full route when ride starts
      _fitBoundsToRoute();
      // Re-fetch pickup→dropoff ETA
      _refreshDropoffEta();
    }
  }

  Future<void> _refreshDropoffEta() async {
    final result =
        await OsrmRouteService.fetchRoute(_pickupLatLng, _dropoffLatLng);
    if (result != null && mounted) {
      setState(() {
        _etaText = result.etaText;
        _distText = result.distanceText;
      });
    }
  }

  @override
  void dispose() {
    _gpsSub?.cancel();
    _socket.disconnect();
    _moveAnim?.dispose();
    _pulseAnim?.dispose();
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
          // ── MapLibre GL Map ────────────────────────────────────────────
          Positioned.fill(
            child: MapLibreMap(
              styleString: isDark ? _osmStyleDark : _osmStyleLight,
              initialCameraPosition: CameraPosition(
                target: _driverPosition ?? _pickupLatLng,
                zoom: 14.0,
              ),
              onMapCreated: _onMapCreated,
              onStyleLoadedCallback: _onStyleLoaded,
              myLocationEnabled: true,
              myLocationTrackingMode: MyLocationTrackingMode.trackingCompass,
              myLocationRenderMode: MyLocationRenderMode.compass,
              trackCameraPosition: true,
              compassEnabled: false,
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: true,
            ),
          ),

          // ── ETA / Distance overlay ─────────────────────────────────────
          Positioned(
            top: top + 70,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkSurface : Colors.white).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time_rounded, size: 14, color: AppColors.primaryPurple),
                      const SizedBox(width: 4),
                      Text(
                        _etaText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.route_rounded, size: 14, color: AppColors.primaryPurple),
                      const SizedBox(width: 4),
                      Text(
                        _distText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Map control buttons ────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: 320,
            child: Column(
              children: [
                _MapBtn(
                  icon: Icons.my_location_rounded,
                  onTap: () {
                    if (_driverPosition != null) {
                      _animateCamera(_driverPosition!, bearing: _driverBearing);
                    }
                  },
                ),
                const SizedBox(height: 8),
                _MapBtn(
                  icon: Icons.zoom_out_map_rounded,
                  onTap: _fitBoundsToRoute,
                ),
              ],
            ),
          ),

          // ── Back button ───────────────────────────────────────────────────
          Positioned(
            top: top + 12,
            left: 12,
            child: _MapBtn(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),

          // ── Status step indicator ──────────────────────────────────────
          Positioned(
            top: top + 12,
            left: 62,
            right: 16,
            child: StatusStepIndicator(current: _status),
          ),

          // ── Bottom sheet controls ──────────────────────────────────────
          TrackingBottomSheet(
            ride: widget.ride,
            onStatusChanged: _onStatusChanged,
          ),
        ],
      ),
    );
  }
}

// ── Map button widget ────────────────────────────────────────────────────────
class _MapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.text(context)),
      ),
    );
  }
}
