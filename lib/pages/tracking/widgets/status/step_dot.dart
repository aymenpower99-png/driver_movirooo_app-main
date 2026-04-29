// lib/pages/tracking/widgets/status/step_dot.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';

class StepDot extends StatelessWidget {
  final bool isDone;
  final bool isCurrent;
  final Animation<double>? animation;
  final bool isDark;

  const StepDot({
    required this.isDone,
    required this.isCurrent,
    this.animation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveDotBorder = isDark
        ? AppColors.darkBorder
        : const Color(0xFFD1D5DB);
    final inactiveDotFill = AppColors.surface(context);

    if (isDone) {
      return Container(
        width: 14,
        height: 14,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 9, color: Colors.white),
      );
    } else if (isCurrent && animation != null) {
      return AnimatedBuilder(
        animation: animation!,
        builder: (_, _) {
          final alpha =
              0.2 + 0.15 * ((animation!.value * 3.14159) % 3.14159 / 3.14159);
          return Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: alpha),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      );
    } else {
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: inactiveDotFill,
          shape: BoxShape.circle,
          border: Border.all(color: inactiveDotBorder, width: 1.5),
        ),
      );
    }
  }
}
