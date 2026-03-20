// lib/pages/tabs/[driver]/Rides/tracking/widgets/status_step_indicator.dart
//
// 4-step progress bar: Assigned → On the Way → Arrived → Start Ride
// Completed steps show green filled circle with white checkmark.
// Active step shows purple filled circle with white filled inner dot.

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

  const StatusStepIndicator({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final leftStep = _steps[i ~/ 2];
            final isDone = leftStep.index < current.index;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                height: 3,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.success : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }

          final stepIdx = i ~/ 2;
          final step = _steps[stepIdx];
          final isDone = step.index < current.index;
          final isCurrent = step == current;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Circle ──────────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? AppColors.success
                      : isCurrent
                          ? AppColors.primaryPurple
                          : const Color(0xFFE5E7EB),
                  border: Border.all(
                    color: isDone
                        ? AppColors.success
                        : isCurrent
                            ? AppColors.primaryPurple
                            : const Color(0xFFD1D5DB),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : isCurrent
                          ? Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            )
                          : const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 6),
              // ── Label ────────────────────────────────────────────
              SizedBox(
                width: 62,
                child: Text(
                  step.stepLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: (isCurrent || isDone)
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: isDone
                        ? AppColors.success
                        : isCurrent
                            ? AppColors.primaryPurple
                            : const Color(0xFF9AA3AD),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}