import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_colors.dart';
import 'power_section.dart';
import 'activity_card.dart';

export 'power_section.dart' show PowerSection;
export 'activity_card.dart' show ActivityCard;

// PowerSection — see power_section.dart
// ActivityCard — see activity_card.dart

// ─────────────────────────────────────────────────────────────────────────────
// DRIVER STATUS ROW  —  rating · streak · level
// (replaces the 3 stat tiles — no overlap with activity card or earnings page)
// ─────────────────────────────────────────────────────────────────────────────
class DriverStatusRow extends StatelessWidget {
  // Replace with real model values
  final double rating;
  final int streakDays;
  final String level;

  const DriverStatusRow({
    super.key,
    this.rating = 4.8,
    this.streakDays = 6,
    this.level = 'Gold',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Rating
        Expanded(
          child: _StatusTile(
            topWidget: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 15,
                  color: Color(0xFFFFC107),
                ),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text(context),
                  ),
                ),
              ],
            ),
            label: AppLocalizations.of(
              context,
            ).translate('dashboard_your_rating'),
          ),
        ),
        const SizedBox(width: 10),
        // Streak
        Expanded(
          child: _StatusTile(
            topWidget: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 4),
                Text(
                  '${streakDays}d',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text(context),
                  ),
                ),
              ],
            ),
            label: AppLocalizations.of(context).translate('dashboard_streak'),
          ),
        ),
        const SizedBox(width: 10),
        // Level
        Expanded(
          child: _StatusTile(
            topWidget: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  size: 15,
                  color: level == 'Gold'
                      ? const Color(0xFFFFB300)
                      : level == 'Silver'
                      ? const Color(0xFF9E9E9E)
                      : AppColors.primaryPurple,
                ),
                const SizedBox(width: 4),
                Text(
                  level,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text(context),
                  ),
                ),
              ],
            ),
            label: AppLocalizations.of(
              context,
            ).translate('dashboard_driver_level'),
          ),
        ),
      ],
    );
  }
}

class _StatusTile extends StatelessWidget {
  final Widget topWidget;
  final String label;
  const _StatusTile({required this.topWidget, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          topWidget,
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: AppColors.subtext(context)),
          ),
        ],
      ),
    );
  }
}

// ActivityCard — see activity_card.dart
// _ActivityRow — see activity_card.dart
