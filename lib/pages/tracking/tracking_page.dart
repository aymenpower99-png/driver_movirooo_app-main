// lib/pages/tracking/track_passenger_page.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/pages/tracking/ride_model.dart';
import 'package:moviroo_driver_app/pages/tracking/tracking_bottom_sheet.dart';
import 'package:moviroo_driver_app/pages/tracking/widgets/status_step_indicator.dart';

class TrackPassengerPage extends StatefulWidget {
  final RideModel ride;

  const TrackPassengerPage({super.key, required this.ride});

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
      backgroundColor: AppColors.bg(context),
      body: Stack(
        children: [
          Positioned.fill(child: _MapPlaceholder(status: _status)),
          Positioned(
            top: top + 12,
            left: 16,
            right: 16,
            child: StatusStepIndicator(current: _status),
          ),
          TrackingBottomSheet(
            ride: widget.ride,
            onStatusChanged: (s) => setState(() => _status = s),
          ),
        ],
      ),
    );
  }
}

// ── Map Placeholder ───────────────────────────────────────────────────────────
class _MapPlaceholder extends StatelessWidget {
  final RideStatus status;
  const _MapPlaceholder({required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Map background: dark blue-gray in dark mode, light gray-blue in light
    final mapBg       = isDark ? const Color(0xFF0F1923) : const Color(0xFFE8EEF4);
    final gridColor   = isDark ? const Color(0xFF1A2535) : const Color(0xFFCDD7E2);
    final routeColor  = isDark
        ? const Color(0xFFA855F7).withValues(alpha: 0.7)
        : const Color(0xFFA855F7).withValues(alpha: 0.55);

    return Container(
      color: mapBg,
      child: Stack(
        children: [
          CustomPaint(
              painter: _GridPainter(color: gridColor), size: Size.infinite),
          CustomPaint(
              painter: _RoutePainter(color: routeColor), size: Size.infinite),
          Align(
            alignment: const Alignment(0, -0.15),
            child: _CircleMarker(
                color: AppColors.primaryPurple,
                icon: Icons.navigation_rounded),
          ),
          Align(
            alignment: const Alignment(0.55, 0.30),
            child: _LabeledMarker(
                color: AppColors.success,
                icon: Icons.location_on_rounded,
                label: 'Pickup'),
          ),
          if (status.showDropoffMarker)
            Align(
              alignment: const Alignment(-0.45, -0.55),
              child: _LabeledMarker(
                  color: AppColors.primaryPurple,
                  icon: Icons.flag_rounded,
                  label: 'Drop-off'),
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
                color: color.withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 4)
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelBg = isDark ? AppColors.darkSurface : Colors.white;
    final labelTextColor = color;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.3), blurRadius: 10)
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: labelBg,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                  blurRadius: 6)
            ],
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: labelTextColor)),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  const _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.color != color;
}

class _RoutePainter extends CustomPainter {
  final Color color;
  const _RoutePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.5, size.height * 0.38)
        ..quadraticBezierTo(
            size.width * 0.54, size.height * 0.52,
            size.width * 0.64, size.height * 0.62),
      p,
    );
  }

  @override
  bool shouldRepaint(_RoutePainter old) => old.color != color;
}