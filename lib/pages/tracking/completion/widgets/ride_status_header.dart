// lib/pages/tracking/completion/widgets/ride_status_header.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';

class RideStatusHeader extends StatelessWidget {
  final Animation<double> scale;
  final String title;
  final Color iconColor;
  final Color iconBgColor;
  final IconData icon;

  /// Optional badge shown below the title (e.g. "Cancelled by passenger").
  final Widget? badge;

  const RideStatusHeader({
    super.key,
    required this.scale,
    required this.title,
    required this.iconColor,
    required this.iconBgColor,
    required this.icon,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 16),
      child: Column(
        children: [
          ScaleTransition(
            scale: scale,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 34),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.text(context),
            ),
          ),
          if (badge != null) ...[
            const SizedBox(height: 6),
            badge!,
          ],
        ],
      ),
    );
  }
}