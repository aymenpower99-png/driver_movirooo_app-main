// ════════════════════════════════════════════════════════════════════
//  ride_widgets.dart  —  shared micro-widgets
// ════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_text_styles.dart';

// ─── Coloured dot (route timeline) ──────────────────────────────────

class RideDot extends StatelessWidget {
  final Color color;
  const RideDot({super.key, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: 9,
    height: 9,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

// ─── Icon + label chip ───────────────────────────────────────────────

class RideInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const RideInfoChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.subtext(context)),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.dateTime(context)),
      ],
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────

class RideEmptyState extends StatelessWidget {
  final String message;
  const RideEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 56,
            color: AppColors.subtext(context).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyMedium(
              context,
            ).copyWith(color: AppColors.subtext(context)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {},
            child: Text(
              AppLocalizations.of(context).translate('tap_to_refresh'),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Route timeline (from → to with dots + connector) ────────────────

class RideRouteTimeline extends StatelessWidget {
  final String from;
  final String to;
  final TextStyle? textStyle;

  const RideRouteTimeline({
    super.key,
    required this.from,
    required this.to,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final style = textStyle ?? AppTextStyles.bodyMedium(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dots + connector line
        Column(
          children: [
            const SizedBox(height: 3),
            RideDot(color: AppColors.primaryPurple),
            Container(width: 1.5, height: 26, color: AppColors.border(context)),
            RideDot(color: AppColors.secondaryPurple),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(from, style: style),
              const SizedBox(height: 14),
              Text(to, style: style),
            ],
          ),
        ),
      ],
    );
  }
}
