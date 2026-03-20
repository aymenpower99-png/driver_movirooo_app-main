// lib/pages/tabs/[driver]/Rides/tracking/track_passenger_page.dart

import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';  // ← same depth as rides_page.dart
import 'ride_model.dart';
import 'tracking_bottom_sheet.dart';
import 'widgets/status_step_indicator.dart';

class TrackPassengerPage extends StatefulWidget {
  final RideModel ride;

  const TrackPassengerPage({super.key, required this.ride});

  /// Use this for Navigator.push:
  /// Navigator.of(context).push(TrackPassengerPage.route(ride));
  static Route<void> route(RideModel ride) => MaterialPageRoute(
        builder: (_) => TrackPassengerPage(ride: ride),
      );

  @override
  State<TrackPassengerPage> createState() => _TrackPassengerPageState();
}

class _TrackPassengerPageState extends State<TrackPassengerPage> {
  RideStatus _status = RideStatus.assigned;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          // ── Map background ───────────────────────────────────
          Positioned.fill(
            child: _MapPlaceholder(status: _status),
          ),

          // ── Step indicator ───────────────────────────────────
          Positioned(
            top: top + 12,
            left: 16,
            right: 16,
            child: StatusStepIndicator(current: _status),
          ),

          // ── Draggable bottom sheet ───────────────────────────
          TrackingBottomSheet(
            ride: widget.ride,
            onStatusChanged: (s) => setState(() => _status = s),
          ),
        ],
      ),
    );
  }
}

// ── Map placeholder ───────────────────────────────────────────────────────────

class _MapPlaceholder extends StatelessWidget {
  final RideStatus status;
  const _MapPlaceholder({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8EEF4),
      child: Stack(
        children: [
          CustomPaint(painter: _GridPainter(), size: Size.infinite),
          CustomPaint(painter: _RoutePainter(), size: Size.infinite),
          Align(
            alignment: const Alignment(0, -0.15),
            child: _CircleMarker(
              color: AppColors.primaryPurple,
              icon: Icons.navigation_rounded,
            ),
          ),
          Align(
            alignment: const Alignment(0.55, 0.30),
            child: _LabeledMarker(
              color: AppColors.success,
              icon: Icons.location_on_rounded,
              label: 'Pickup',
            ),
          ),
          if (status.showDropoffMarker)
            Align(
              alignment: const Alignment(-0.45, -0.55),
              child: _LabeledMarker(
                color: AppColors.primaryPurple,
                icon: Icons.flag_rounded,
                label: 'Drop-off',
              ),
            ),
        ],
      ),
    );
  }
}

class _CircleMarker extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _CircleMarker({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.4), blurRadius: 16, spreadRadius: 4)
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      );
}

class _LabeledMarker extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  const _LabeledMarker(
      {required this.color, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.3), blurRadius: 10)
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1), blurRadius: 6)
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      );
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFCDD7E2)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFA855F7).withOpacity(0.55)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.5, size.height * 0.38)
        ..quadraticBezierTo(
          size.width * 0.54,
          size.height * 0.52,
          size.width * 0.64,
          size.height * 0.62,
        ),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}