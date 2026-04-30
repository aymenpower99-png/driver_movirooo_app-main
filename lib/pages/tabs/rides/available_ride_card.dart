// ════════════════════════════════════════════════════════════════════
//  ride_card.dart  —  one card for ALL tabs (uses global RideModel)
// ════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_text_styles.dart';
import '../../../core/models/ride_model.dart';
import 'ride_widgets.dart'; // includes formatRideDate, formatRideTime, tryParseDateTime

class RideCard extends StatelessWidget {
  final RideModel ride;

  /// Only provided for the Upcoming tab
  final void Function(RideModel)? onTrack;
  final void Function(RideModel)? onChat;

  /// Status pill label & colour (Upcoming / Completed / Cancelled)
  final String? statusLabel;
  final Color? statusColor;

  const RideCard({
    super.key,
    required this.ride,
    this.onTrack,
    this.onChat,
    this.statusLabel,
    this.statusColor,
  });

  bool get _isUpcoming => onTrack != null && onChat != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    ride.passengerInitials,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
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
                      Text(
                        ride.passengerName ?? 'Passenger',
                        style: AppTextStyles.bodyLarge(context),
                      ),
                      if (ride.vehicleClassName.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          ride.vehicleClassName,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.subtext(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _StatusPill(
                  label: statusLabel ?? ride.status,
                  color: statusColor ?? AppColors.primaryPurple,
                ),
              ],
            ),
          ),

          Divider(height: 1, color: AppColors.border(context)),

          // ── Ride time ──────────────────────────────────────────
          if (ride.rideTime.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Builder(
                builder: (_) {
                  final dt = tryParseDateTime(ride.rideTime);
                  if (dt == null) {
                    return Row(
                      children: [
                        RideInfoChip(
                          icon: Icons.schedule_outlined,
                          label: ride.rideTime,
                        ),
                        if ((ride.distanceKm ?? 0) > 0) ...[
                          const SizedBox(width: 14),
                          RideInfoChip(
                            icon: Icons.route_rounded,
                            label: '${ride.distanceKm!.toStringAsFixed(1)} km',
                          ),
                        ],
                      ],
                    );
                  }
                  return Row(
                    children: [
                      RideInfoChip(
                        icon: Icons.calendar_today_outlined,
                        label: formatRideDate(dt),
                      ),
                      const SizedBox(width: 14),
                      RideInfoChip(
                        icon: Icons.access_time_outlined,
                        label: formatRideTime(dt),
                      ),
                      if ((ride.distanceKm ?? 0) > 0) ...[
                        const SizedBox(width: 14),
                        RideInfoChip(
                          icon: Icons.route_rounded,
                          label: '${ride.distanceKm!.toStringAsFixed(1)} km',
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),

          // ── Route ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
            child: RideRouteTimeline(
              from: ride.from,
              to: ride.to,
              textStyle: AppTextStyles.bodySmall(context),
            ),
          ),

          // ── Track / Chat  (Upcoming tab only) ────────────────────
          if (_isUpcoming) ...[
            Divider(height: 1, color: AppColors.border(context)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onTrack!(ride),
                      icon: const Icon(Icons.map_outlined, size: 16),
                      label: Text(
                        AppLocalizations.of(
                          context,
                        ).translate('ride_action_track'),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryPurple,
                        side: BorderSide(color: AppColors.primaryPurple),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onChat!(ride),
                      icon: const Icon(Icons.chat_bubble_outline, size: 16),
                      label: Text(
                        AppLocalizations.of(
                          context,
                        ).translate('ride_action_chat'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Status pill ─────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
