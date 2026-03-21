// lib/pages/tracking/widgets/passenger_info_card.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/pages/tracking/ride_model.dart';

class PassengerInfoCard extends StatelessWidget {
  final PassengerModel passenger;
  final String pickupAddress;
  final String dropOffAddress;
  final double distanceKm;
  final int etaMinutes;
  final bool showContactButtons;
  final bool showMetaTile;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;
  final VoidCallback? onReportIssue;
  final VoidCallback? onCancelRide;

  const PassengerInfoCard({
    super.key,
    required this.passenger,
    required this.pickupAddress,
    required this.dropOffAddress,
    required this.distanceKm,
    required this.etaMinutes,
    required this.showContactButtons,
    this.showMetaTile = false,
    this.onCall,
    this.onMessage,
    this.onReportIssue,
    this.onCancelRide,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── 1. PASSENGER HEADER (always at top) ───────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Row(
            children: [
              _Avatar(passenger: passenger),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(passenger.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text(context),
                        )),
                    const SizedBox(height: 3),
                    _StarRating(rating: passenger.rating),
                  ],
                ),
              ),
              // Call + Message always visible in header
              Row(
                children: [
                  _StrokeIconBtn(
                      child: _PhoneIcon(), onTap: onCall ?? () {}),
                  const SizedBox(width: 8),
                  _StrokeIconBtn(
                      child: _ChatIcon(), onTap: onMessage ?? () {}),
                ],
              ),
            ],
          ),
        ),

        Divider(height: 1, color: AppColors.border(context)),

        // ── 2. ROUTE ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pickup — empty circle
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(top: 3),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primaryPurple, width: 2),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PICKUP',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryPurple,
                              letterSpacing: 0.4,
                            )),
                        const SizedBox(height: 3),
                        Text(pickupAddress,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text(context),
                            )),
                      ],
                    ),
                  ),
                ],
              ),

              // Connector
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Container(
                    width: 2, height: 22, color: const Color(0xFFE5E7EB)),
              ),

              // Drop-off — filled circle
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(top: 3),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('DROP-OFF',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryPurple,
                              letterSpacing: 0.4,
                            )),
                        const SizedBox(height: 3),
                        Text(dropOffAddress,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text(context),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Divider(height: 1, color: AppColors.border(context)),

        // ── 3. DISTANCE + ETA tile (hidden on Assigned) ───────────
        if (showMetaTile) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bg(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            Icon(Icons.route_rounded,
                                size: 18, color: AppColors.primaryPurple),
                            const SizedBox(height: 4),
                            Text('${distanceKm.toStringAsFixed(1)} km',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text(context),
                                )),
                            Text('Distance',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.subtext(context))),
                          ],
                        ),
                      ),
                    ),
                    VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: AppColors.border(context)),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            Icon(Icons.schedule_rounded,
                                size: 18, color: AppColors.primaryPurple),
                            const SizedBox(height: 4),
                            Text('$etaMinutes min',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text(context),
                                )),
                            Text('ETA',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.subtext(context))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],

        // ── 4. REPORT / CANCEL ────────────────────────────────────
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onReportIssue,
                  icon: Icon(Icons.flag_outlined,
                      size: 14, color: AppColors.subtext(context)),
                  label: Text('Report Issue',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.subtext(context),
                      )),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero),
                  ),
                ),
              ),
              VerticalDivider(width: 1, color: AppColors.border(context)),
              Expanded(
                child: TextButton.icon(
                  onPressed: onCancelRide,
                  icon: const Icon(Icons.cancel_outlined,
                      size: 14, color: AppColors.error),
                  label: const Text('Cancel Ride',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.error,
                      )),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final PassengerModel passenger;
  const _Avatar({required this.passenger});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient:
            passenger.avatarUrl == null ? AppColors.purpleGradient : null,
        image: passenger.avatarUrl != null
            ? DecorationImage(
                image: NetworkImage(passenger.avatarUrl!),
                fit: BoxFit.cover)
            : null,
      ),
      child: passenger.avatarUrl == null
          ? Center(
              child: Text(passenger.avatarInitial,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)))
          : null,
    );
  }
}

// ── Star rating ───────────────────────────────────────────────────────────────
class _StarRating extends StatelessWidget {
  final double rating;
  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;
    return Row(
      children: [
        ...List.generate(5, (i) {
          IconData ico;
          if (i < full)               ico = Icons.star_rounded;
          else if (i == full && half) ico = Icons.star_half_rounded;
          else                        ico = Icons.star_outline_rounded;
          return Icon(ico, size: 14, color: const Color(0xFFFFC107));
        }),
        const SizedBox(width: 4),
        Text(rating.toStringAsFixed(1),
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.subtext(context))),
      ],
    );
  }
}

// ── Stroke icon button ────────────────────────────────────────────────────────
class _StrokeIconBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _StrokeIconBtn({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F3F5),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

// ── Phone icon ────────────────────────────────────────────────────────────────
class _PhoneIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(20, 20), painter: _PhonePainter());
}

class _PhonePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.primaryPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width;
    final h = size.height;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.72, h * 0.58)
        ..cubicTo(w * 0.72, h * 0.58, w * 0.88, h * 0.74, w * 0.88, h * 0.80)
        ..cubicTo(w * 0.88, h * 0.86, w * 0.82, h * 0.92, w * 0.76, h * 0.92)
        ..cubicTo(w * 0.40, h * 0.92, w * 0.08, h * 0.60, w * 0.08, h * 0.24)
        ..cubicTo(w * 0.08, h * 0.18, w * 0.14, h * 0.12, w * 0.20, h * 0.12)
        ..cubicTo(w * 0.26, h * 0.12, w * 0.42, h * 0.28, w * 0.42, h * 0.28)
        ..cubicTo(w * 0.46, h * 0.32, w * 0.46, h * 0.38, w * 0.42, h * 0.42)
        ..lineTo(w * 0.36, h * 0.48)
        ..cubicTo(w * 0.44, h * 0.58, w * 0.52, h * 0.64, w * 0.52, h * 0.64)
        ..cubicTo(w * 0.62, h * 0.72, w * 0.70, h * 0.78, w * 0.70, h * 0.78)
        ..lineTo(w * 0.76, h * 0.72)
        ..cubicTo(w * 0.80, h * 0.68, w * 0.86, h * 0.68, w * 0.90, h * 0.72),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ── Chat icon ─────────────────────────────────────────────────────────────────
class _ChatIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(20, 20), painter: _ChatPainter());
}

class _ChatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.primaryPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = size.width;
    final h = size.height;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.06, h * 0.06, w * 0.88, h * 0.68),
        Radius.circular(w * 0.12),
      ),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.20, h * 0.74)
        ..lineTo(w * 0.10, h * 0.94)
        ..lineTo(w * 0.36, h * 0.74),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}