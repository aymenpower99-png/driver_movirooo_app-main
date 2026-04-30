// lib/pages/tracking/completion/widgets/ride_summary_card.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/pages/tracking/ride_model.dart';
import 'passenger_row.dart';
import 'full_route.dart';
import 'pickup_only_route.dart';
import 'meta_footer.dart';

/// Full summary card — passenger row, route, duration & distance footer.
/// Used by [RideCompletionPage].
///
/// For cancellation (no meta footer needed), set [showMeta] to false.
class RideSummaryCard extends StatelessWidget {
  final RideModel ride;

  /// Show the duration / distance footer row. Default: true.
  final bool showMeta;

  /// When true, the destination dot is replaced by a red circle
  /// and only the pickup address is shown (ride never started).
  final bool pickupOnly;

  const RideSummaryCard({
    super.key,
    required this.ride,
    this.showMeta = true,
    this.pickupOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          PassengerRow(ride: ride, cardColor: cardColor),
          Divider(height: 1, color: borderColor),
          pickupOnly
              ? PickupOnlyRoute(ride: ride)
              : FullRoute(ride: ride, cardColor: cardColor),
          if (showMeta) ...[
            Divider(height: 1, color: borderColor),
            MetaFooter(ride: ride, borderColor: borderColor),
          ],
        ],
      ),
    );
  }
}
