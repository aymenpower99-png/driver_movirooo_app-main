// lib/pages/tracking/widgets/report/trip_row.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';

class TripRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const TripRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 10, color: AppColors.primaryPurple),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.subtext(context),
            ),
          ),
        ),
      ],
    );
  }
}
