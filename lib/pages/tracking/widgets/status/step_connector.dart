// lib/pages/tracking/widgets/status/step_connector.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';

class StepConnector extends StatelessWidget {
  final bool isDone;
  final bool isActive;
  final Animation<double>? animation;
  final bool isDark;

  const StepConnector({
    required this.isDone,
    required this.isActive,
    this.animation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveLineColor = isDark
        ? AppColors.darkBorder
        : const Color(0xFFE5E7EB);

    if (isDone) {
      return Expanded(
        child: Container(height: 2, color: AppColors.success),
      );
    }
    if (isActive && animation != null) {
      return Expanded(
        child: AnimatedBuilder(
          animation: animation!,
          builder: (_, _) => Stack(
            children: [
              Container(height: 2, color: inactiveLineColor),
              FractionallySizedBox(
                widthFactor: animation!.value,
                child: Container(
                  height: 2,
                  color: AppColors.primaryPurple,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Expanded(
      child: Container(height: 2, color: inactiveLineColor),
    );
  }
}
