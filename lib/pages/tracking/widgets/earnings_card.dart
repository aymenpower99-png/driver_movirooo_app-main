// lib/pages/tracking/widgets/earnings_card.dart
//
// Purple gradient earnings preview card.
// Visible only during RideStatus.inTrip.

import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class EarningsCard extends StatelessWidget {
  final double amount;
  final String currency;

  const EarningsCard({
    super.key,
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Icon bubble
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.payments_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),

          // Labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimated Earnings',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$currency ${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.trending_up_rounded,
            color: Colors.white70,
            size: 20,
          ),
        ],
      ),
    );
  }
}