// lib/pages/tracking/completion/widgets/commission_tier_card.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/core/models/earnings_model.dart';
import 'package:moviroo_driver_app/l10n/app_localizations.dart';

/// Commission tier progress card shown on the ride completion screen.
/// Mirrors the style of the Earnings screen tier card.
class CommissionTierCard extends StatelessWidget {
  final EarningsModel? earnings;

  const CommissionTierCard({super.key, this.earnings});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).translate;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB);

    if (earnings == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final currentTier = earnings!.currentTier;
    final completed = earnings!.ridesCompleted;

    final tierNumber = currentTier != null
        ? earnings!.tiers.indexWhere((t) => t.tierId == currentTier.tierId) + 1
        : 0;

    final nextTierName = earnings!.nextTierName;
    final ridesNeeded = earnings!.nextTierRidesNeeded ?? 0;
    final nextRequired = nextTierName != null && ridesNeeded > 0
        ? completed + ridesNeeded
        : null;
    final progress = nextRequired != null && nextRequired > 0
        ? (completed / nextRequired).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentTier != null
                          ? '${currentTier.tierName} (${t('commission_tier_title')} $tierNumber)'
                          : t('commission_tier_title'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentTier != null
                          ? '${t('commission_rate_label')}: ${(currentTier.commissionRate * 100).toStringAsFixed(0)}%'
                          : t('commission_tier_hint'),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.subtext(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (currentTier != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(currentTier.commissionRate * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress
          if (nextTierName != null && nextRequired != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t('commission_progress_rides')
                          .replaceAll('{completed}', '$completed')
                          .replaceAll('{nextRequired}', '$nextRequired'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text(context),
                      ),
                    ),
                    Text(
                      t('commission_to_next')
                          .replaceAll('{ridesNeeded}', '$ridesNeeded')
                          .replaceAll('{nextTierName}', nextTierName),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.subtext(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.border(context),
                    valueColor: AlwaysStoppedAnimation(
                      AppColors.primaryPurple.withValues(
                        alpha: 0.4 + progress * 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              t('commission_all_tiers'),
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF10b981),
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}
