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
  final bool filled;
  const RideDot({super.key, required this.color, this.filled = true});

  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      color: filled ? color : Colors.transparent,
      shape: BoxShape.circle,
      border: Border.all(color: color, width: 2),
    ),
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

// ─── Date / time formatting helpers ──────────────────────────────────

const _frenchMonths = [
  'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
  'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
];

String formatRideDate(DateTime dt) {
  return '${dt.day} ${_frenchMonths[dt.month - 1]} ${dt.year}';
}

String formatRideTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

/// Try to parse an ISO 8601 string; returns null on failure.
DateTime? tryParseDateTime(String? s) {
  if (s == null || s.isEmpty) return null;
  return DateTime.tryParse(s);
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
            RideDot(color: AppColors.primaryPurple, filled: false),
            Container(width: 1.5, height: 26, color: AppColors.border(context)),
            RideDot(color: AppColors.primaryPurple, filled: true),
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
