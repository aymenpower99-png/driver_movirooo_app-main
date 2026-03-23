// lib/pages/tracking/widgets/ride_meta_row.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';

class RideMetaBadge extends StatelessWidget {
  final IconData icon;
  final String value;

  const RideMetaBadge({super.key, required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AppColors.primaryPurple.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primaryPurple),
          const SizedBox(width: 4),
          Text(value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryPurple,
              )),
        ],
      ),
    );
  }
}