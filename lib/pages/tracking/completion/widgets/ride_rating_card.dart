// lib/pages/tracking/completion/widgets/ride_rating_card.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/l10n/app_localizations.dart';

/// Star-rating card shared by both the completion and cancellation screens.
///
/// Only shown on the cancellation screen when the driver had already
/// reached the passenger ([RideCancellationPage.driverReachedPassenger] == true).
class RideRatingCard extends StatelessWidget {
  final int selectedStars;
  final ValueChanged<int> onStarTap;

  const RideRatingCard({
    super.key,
    required this.selectedStars,
    required this.onStarTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB);
    final inactiveStar = isDark
        ? const Color(0xFF2A3345)
        : const Color(0xFFD1D5DB);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context).translate('completion_rate_passenger'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.text(context),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < selectedStars;
              return GestureDetector(
                onTap: () => onStarTap(i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 36,
                    color: filled ? const Color(0xFFFFC107) : inactiveStar,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}