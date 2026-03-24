// lib/pages/tracking/completion/widgets/cancel_earnings_card.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/l10n/app_localizations.dart';

/// Who triggered the cancellation.
enum CancelledBy { passenger, driver }

/// Whether the passenger cancelled early (no fee) or late (fee applies).
enum PassengerCancelType { early, late }

/// Earnings card shown on the **cancellation** screen.
///
/// Handles all three earning cases:
/// - **Case A** — passenger cancels late → driver gets a cancellation fee.
/// - **Case B** — passenger cancels early → driver earns nothing.
/// - **Case C** — driver cancels → driver earns nothing.
class CancelEarningsCard extends StatelessWidget {
  final CancelledBy cancelledBy;
  final PassengerCancelType passengerCancelType;

  /// Fee charged to the passenger (Case A only).
  final double cancellationFee;

  /// Driver's share of the cancellation fee (Case A only).
  final double driverEarnings;

  const CancelEarningsCard({
    super.key,
    required this.cancelledBy,
    this.passengerCancelType = PassengerCancelType.early,
    this.cancellationFee = 0,
    this.driverEarnings = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('completion_earnings'),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.subtext(context),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildBody(context),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    // Case C — driver cancelled
    if (cancelledBy == CancelledBy.driver) {
      return _NoEarningsRow(
        mainLabel: AppLocalizations.of(
          context,
        ).translate('cancellation_no_earnings'),
        subLabel: AppLocalizations.of(
          context,
        ).translate('cancellation_you_cancelled'),
        icon: Icons.cancel_outlined,
      );
    }

    // Case B — passenger cancelled early
    if (passengerCancelType == PassengerCancelType.early) {
      return _NoEarningsRow(
        mainLabel: AppLocalizations.of(
          context,
        ).translate('cancellation_no_earnings'),
        subLabel: AppLocalizations.of(
          context,
        ).translate('cancellation_early'),
        icon: Icons.timer_off_outlined,
      );
    }

    // Case A — passenger cancelled late → show fee
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(
                context,
              ).translate('cancellation_fee_label'),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.text(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${cancellationFee.toStringAsFixed(0)} TND',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.text(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  ).translate('completion_you_earn'),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  AppLocalizations.of(
                    context,
                  ).translate('completion_after_commission'),
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.subtext(context),
                  ),
                ),
              ],
            ),
            Text(
              '+${driverEarnings.toStringAsFixed(0)} TND',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── No-earnings row ───────────────────────────────────────────────────────────
class _NoEarningsRow extends StatelessWidget {
  final String mainLabel;
  final String subLabel;
  final IconData icon;

  const _NoEarningsRow({
    required this.mainLabel,
    required this.subLabel,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.subtext(context)),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mainLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.text(context),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subLabel,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.subtext(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}