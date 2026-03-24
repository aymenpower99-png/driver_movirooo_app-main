// lib/pages/tracking/completion/widgets/ride_earnings_card.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/l10n/app_localizations.dart';

/// Earnings breakdown shown on the ride **completion** screen.
///
/// Displays the full ride price (passenger charge) and the driver's
/// 70 % share after platform commission.
class RideEarningsCard extends StatelessWidget {
  /// Total amount the passenger paid (= [driverEarnings] / 0.70).
  final double ridePrice;

  /// Amount credited to the driver after commission.
  final double driverEarnings;

  const RideEarningsCard({
    super.key,
    required this.ridePrice,
    required this.driverEarnings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB);

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
            AppLocalizations.of(context).translate('completion_earnings'),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.subtext(context),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),

          // Ride price row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(
                  context,
                ).translate('completion_ride_price'),
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.text(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${ridePrice.toStringAsFixed(0)} TND',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Driver earnings row
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
      ),
    );
  }
}