// lib/pages/tabs/[driver]/Rides/tracking/widgets/status_step_indicator.dart

import 'package:flutter/material.dart';
import '../../../../../../theme/app_colors.dart';
import '../ride_model.dart';

class StatusStepIndicator extends StatelessWidget {
  final RideStatus current;

  static const _steps = [
    RideStatus.assigned,
    RideStatus.onTheWay,
    RideStatus.arrived,
    RideStatus.inTrip,
  ];

  static const _labels = ['Assigned', 'On Way', 'Arrived', 'Start Ride'];

  const StatusStepIndicator({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          // Connector line
          if (i.isOdd) {
            final isDone = _steps[i ~/ 2].index < current.index;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                height: 2,
                color: isDone ? AppColors.success : const Color(0xFFE5E7EB),
              ),
            );
          }

          final idx = i ~/ 2;
          final step = _steps[idx];
          final isDone = step.index < current.index;
          final isCurrent = step == current;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? AppColors.success
                      : isCurrent
                          ? AppColors.primaryPurple
                          : const Color(0xFFE5E7EB),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : isCurrent
                          ? Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            )
                          : const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 4),
              // Label
              Text(
                _labels[idx],
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: (isCurrent || isDone)
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: isDone
                      ? AppColors.success
                      : isCurrent
                          ? AppColors.primaryPurple
                          : const Color(0xFFB0B8C1),
                  letterSpacing: 0.1,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}