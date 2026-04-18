import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';

class TrackingMapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const TrackingMapBtn({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.text(context)),
      ),
    );
  }
}
