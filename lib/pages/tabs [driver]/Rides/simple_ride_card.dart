// ════════════════════════════════════════════════════════════════════
//  simple_ride_card.dart  —  used by Upcoming / Completed / Cancelled
// ════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_text_styles.dart';
import 'ride_model.dart';
import 'ride_widgets.dart';

class SimpleRideCard extends StatelessWidget {
  final RideModel ride;
  final Color accentColor;
  final String statusLabel;

  const SimpleRideCard({
    super.key,
    required this.ride,
    required this.accentColor,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row ─────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    ride.passengerAvatar,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ride.passengerName,
                          style: AppTextStyles.bodyLarge(context)),
                      const SizedBox(height: 2),
                      Text(
                        'Booking #${ride.id}',
                        style: AppTextStyles.bodySmall(context),
                      ),
                    ],
                  ),
                ),
                // Status pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Divider(height: 1, color: AppColors.border(context)),
            const SizedBox(height: 10),

            // ── Meta chips ──────────────────────────────────────────
            Row(
              children: [
                RideInfoChip(
                  icon: Icons.calendar_today_outlined,
                  label: _formatDate(ride.dateTime),
                ),
                const SizedBox(width: 14),
                RideInfoChip(
                  icon: Icons.access_time_outlined,
                  label: _formatTime(ride.dateTime),
                ),
                const SizedBox(width: 14),
                RideInfoChip(
                  icon: Icons.people_outline,
                  label: '${ride.passengerCount} pax',
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Route + price ───────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RideRouteTimeline(
                    from: ride.from,
                    to: ride.to,
                    textStyle: AppTextStyles.bodySmall(context),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${ride.price.toStringAsFixed(2)}',
                  style: AppTextStyles.priceMedium(context).copyWith(
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
  }
}