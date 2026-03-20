// lib/pages/tracking/widgets/ride_meta_row.dart
//
// Horizontal tile showing distance to pickup and ETA.
// Visible only during Assigned and On the Way states.

import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';


class RideMetaRow extends StatelessWidget {
  final double distanceKm;
  final int etaMinutes;

  const RideMetaRow({
    super.key,
    required this.distanceKm,
    required this.etaMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _MetaTile(
                icon: Icons.route_rounded,
                value: '${distanceKm.toStringAsFixed(1)} km',
                label: 'Distance',
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppColors.border(context),
            ),
            Expanded(
              child: _MetaTile(
                icon: Icons.schedule_rounded,
                value: '$etaMinutes min',
                label: 'ETA',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetaTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.primaryPurple),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.text(context),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppColors.subtext(context)),
        ),
      ],
    );
  }
}