// lib/pages/tracking/completion/widgets/ride_earnings_card.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/l10n/app_localizations.dart';

/// Earnings breakdown shown on the ride **completion** screen.
///
/// Displays the full commission breakdown:
/// Ride Price → Commission → Net Earnings
class RideEarningsCard extends StatelessWidget {
  final double? priceFinal;
  final double? commissionAmount;
  final double? driverEarnings;

  const RideEarningsCard({
    super.key,
    this.priceFinal,
    this.commissionAmount,
    this.driverEarnings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB);
    final t = AppLocalizations.of(context).translate;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('completion_earnings'),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.subtext(context),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),

          // Ride price (gross)
          _buildRow(
            context,
            label: t('completion_ride_price'),
            value: '${(priceFinal ?? 0).toStringAsFixed(2)} TND',
            isNegative: false,
          ),
          const SizedBox(height: 6),

          // Commission
          _buildRow(
            context,
            label: t('completion_commission'),
            value: '-${(commissionAmount ?? 0).toStringAsFixed(2)} TND',
            isNegative: true,
          ),
          const SizedBox(height: 6),
          Divider(height: 1, color: borderColor),
          const SizedBox(height: 6),

          // Net earnings
          _buildRow(
            context,
            label: t('completion_net_earnings'),
            value: '${(driverEarnings ?? 0).toStringAsFixed(2)} TND',
            isNegative: false,
            isBold: true,
            valueColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isNegative = false,
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.text(context),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 17 : 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ??
                (isNegative ? AppColors.error : AppColors.text(context)),
          ),
        ),
      ],
    );
  }
}
