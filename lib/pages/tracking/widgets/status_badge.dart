// lib/pages/tracking/widgets/status_badge.dart
//
// Animated pill badge showing the current ride status.
// Hidden during RideStatus.assigned (no badge per spec).

import 'package:flutter/material.dart';
import '../../../../../../theme/app_colors.dart';
import '../ride_model.dart';

class StatusBadge extends StatelessWidget {
  final RideStatus status;

  const StatusBadge({super.key, required this.status});

  Color _color() {
    switch (status) {
      case RideStatus.onTheWay:  return AppColors.primaryPurple;
      case RideStatus.arrived:   return AppColors.success;
      case RideStatus.inTrip:    return AppColors.warning;
      default:                   return AppColors.primaryPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!status.showBadge) return const SizedBox.shrink();

    final color = _color();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(status),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              status.stepLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}