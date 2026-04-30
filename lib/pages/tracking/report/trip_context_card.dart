// lib/pages/tracking/report/widgets/trip_context_card.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import '../widgets/shared/trip_row.dart';

class TripContextCard extends StatelessWidget {
  final String passengerName;
  final String pickupAddress;
  final String dropOffAddress;

  const TripContextCard({
    required this.passengerName,
    required this.pickupAddress,
    required this.dropOffAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 14,
                color: AppColors.primaryPurple,
              ),
              const SizedBox(width: 6),
              Text(
                passengerName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TripRow(
            icon: Icons.radio_button_unchecked_rounded,
            label: pickupAddress,
          ),
          const SizedBox(height: 4),
          TripRow(icon: Icons.circle, label: dropOffAddress),
        ],
      ),
    );
  }
}
