// ════════════════════════════════════════════════════════════════════
//  ride_card.dart  —  one card for ALL tabs
// ════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_text_styles.dart';
import 'ride_model.dart';
import 'ride_widgets.dart';

class RideCard extends StatelessWidget {
  final RideModel ride;

  /// Only provided for the Available tab
  final void Function(RideModel)? onAccept;
  final void Function(RideModel)? onReject;

  /// Only provided for the Upcoming tab
  final void Function(RideModel)? onTrack;
  final void Function(RideModel)? onChat;

  /// Status pill label & colour (Upcoming / Completed / Cancelled)
  final String? statusLabel;
  final Color? statusColor;

  const RideCard({
    super.key,
    required this.ride,
    this.onAccept,
    this.onReject,
    this.onTrack,
    this.onChat,
    this.statusLabel,
    this.statusColor,
  });

  bool get _isAvailable => onAccept != null && onReject != null;
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
                    ride.passengerAvatar,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Name + passenger count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.passengerName,
                        style: AppTextStyles.bodyLarge(context),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 13,
                            color: AppColors.subtext(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ride.passengerCount == 1
                                ? '${ride.passengerCount} ${AppLocalizations.of(context).translate('ride_passenger_one')}'
                                : '${ride.passengerCount} ${AppLocalizations.of(context).translate('ride_passengers_many')}',
                            style: AppTextStyles.bodySmall(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Right badge: price (available) or status pill (others)
                _isAvailable
                    ? _PriceBadge(price: ride.price)
                    : _StatusPill(label: statusLabel!, color: statusColor!),
              ],
            ),
          ),

          Divider(height: 1, color: AppColors.border(context)),

          // ── Date / Time ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Row(
              children: [
                RideInfoChip(
                  icon: Icons.calendar_today_outlined,
                  label: _formatDate(ride.dateTime),
                ),
                const SizedBox(width: 18),
                RideInfoChip(
                  icon: Icons.access_time_outlined,
                  label: _formatTime(ride.dateTime),
                ),
                if (!_isAvailable) ...[
                  const SizedBox(width: 18),
                  RideInfoChip(
                    icon: Icons.people_outline,
                    label:
                        '${ride.passengerCount} ${AppLocalizations.of(context).translate('ride_pax')}',
                  ),
                ],
              ],
            ),
          ),

          // ── Route ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RideRouteTimeline(
                    from: ride.from,
                    to: ride.to,
                    textStyle: _isAvailable
                        ? AppTextStyles.bodyMedium(context)
                        : AppTextStyles.bodySmall(context),
                  ),
                ),
                // Price shown on the right for non-available tabs
                if (!_isAvailable) ...[
                  const SizedBox(width: 8),
                  Text(
                    '\$${ride.price.toStringAsFixed(2)}',
                    style: AppTextStyles.priceMedium(
                      context,
                    ).copyWith(color: statusColor ?? AppColors.primaryPurple),
                  ),
                ],
              ],
            ),
          ),

          // ── Track / Chat  (Upcoming tab only) ────────────────────
          if (_isUpcoming) ...[
            Divider(height: 1, color: AppColors.border(context)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Track on Map
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
                  // Chat
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

          // ── Accept / Reject  (Available tab only) ────────────────
          if (_isAvailable) ...[
            Divider(height: 1, color: AppColors.border(context)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onReject!(ride),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(
                          context,
                        ).translate('ride_action_reject'),
                        style: AppTextStyles.buttonSecondary.copyWith(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => onAccept!(ride),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(
                          context,
                        ).translate('ride_action_accept'),
                        style: AppTextStyles.buttonPrimary.copyWith(
                          fontSize: 14,
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

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
  }
}

// ─── Price badge ─────────────────────────────────────────────────────

class _PriceBadge extends StatelessWidget {
  final double price;
  const _PriceBadge({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '\$${price.toStringAsFixed(2)}',
        style: AppTextStyles.priceMedium(
          context,
        ).copyWith(color: AppColors.primaryPurple),
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
