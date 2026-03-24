// lib/pages/tracking/completion/widgets/ride_summary_card.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/pages/tracking/ride_model.dart';
import 'package:moviroo_driver_app/l10n/app_localizations.dart';

/// Full summary card — passenger row, route, duration & distance footer.
/// Used by [RideCompletionPage].
///
/// For cancellation (no meta footer needed), set [showMeta] to false.
class RideSummaryCard extends StatelessWidget {
  final RideModel ride;

  /// Show the duration / distance footer row. Default: true.
  final bool showMeta;

  /// When true, the destination dot is replaced by a red circle
  /// and only the pickup address is shown (ride never started).
  final bool pickupOnly;

  const RideSummaryCard({
    super.key,
    required this.ride,
    this.showMeta = true,
    this.pickupOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _PassengerRow(ride: ride, cardColor: cardColor),
          Divider(height: 1, color: borderColor),
          pickupOnly
              ? _PickupOnlyRoute(ride: ride)
              : _FullRoute(ride: ride, cardColor: cardColor),
          if (showMeta) ...[
            Divider(height: 1, color: borderColor),
            _MetaFooter(ride: ride, borderColor: borderColor),
          ],
        ],
      ),
    );
  }
}

// ── Passenger row ─────────────────────────────────────────────────────────────
class _PassengerRow extends StatelessWidget {
  final RideModel ride;
  final Color cardColor;
  const _PassengerRow({required this.ride, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.purpleGradient,
            ),
            child: Center(
              child: Text(
                ride.passenger.avatarInitial,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ride.passenger.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text(context),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: Color(0xFFFFC107),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      ride.passenger.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.subtext(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Full route (pickup + dropoff + dashed line) ───────────────────────────────
class _FullRoute extends StatelessWidget {
  final RideModel ride;
  final Color cardColor;
  const _FullRoute({required this.ride, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: AppColors.primaryPurple,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(
                width: 11,
                height: 26,
                child: CustomPaint(painter: _DashedLinePainter()),
              ),
              Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryPurple,
                    width: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 11,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      ride.pickupAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text(context),
                        height: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  height: 11,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      ride.dropOffAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text(context),
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pickup-only route (for cancellation before pickup) ────────────────────────
class _PickupOnlyRoute extends StatelessWidget {
  final RideModel ride;
  const _PickupOnlyRoute({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 11,
            height: 11,
            margin: const EdgeInsets.only(top: 1),
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ride.pickupAddress,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.text(context),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Duration + distance footer ────────────────────────────────────────────────
class _MetaFooter extends StatelessWidget {
  final RideModel ride;
  final Color borderColor;
  const _MetaFooter({required this.ride, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _MetaCell(
              icon: Icons.schedule_outlined,
              value: '${ride.etaMinutes} min',
              label: AppLocalizations.of(
                context,
              ).translate('completion_duration'),
            ),
          ),
          VerticalDivider(width: 1, thickness: 1, color: borderColor),
          Expanded(
            child: _MetaCell(
              icon: Icons.route_outlined,
              value: '${ride.distanceKm.toStringAsFixed(1)} km',
              label: AppLocalizations.of(
                context,
              ).translate('completion_distance'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Meta cell ─────────────────────────────────────────────────────────────────
class _MetaCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _MetaCell({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Icon(icon, size: 15, color: AppColors.primaryPurple),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text(context),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.subtext(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dashed line painter ───────────────────────────────────────────────────────
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashH = 3.0;
    const gapH = 3.0;
    final paint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    double y = 0;
    final cx = size.width / 2;
    while (y < size.height) {
      canvas.drawLine(Offset(cx, y), Offset(cx, y + dashH), paint);
      y += dashH + gapH;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter _) => false;
}