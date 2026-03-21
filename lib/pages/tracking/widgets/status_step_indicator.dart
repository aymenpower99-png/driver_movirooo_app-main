// lib/pages/tracking/widgets/status_step_indicator.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/pages/tracking/ride_model.dart';

class StatusStepIndicator extends StatefulWidget {
  final RideStatus current;
  const StatusStepIndicator({super.key, required this.current});

  @override
  State<StatusStepIndicator> createState() => _StatusStepIndicatorState();
}

class _StatusStepIndicatorState extends State<StatusStepIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _fill;

  static final List<RideStatus> _steps = [
    RideStatus.assigned,
    RideStatus.onTheWay,
    RideStatus.arrived,
    RideStatus.startRide,
    RideStatus.completed,
  ];

  static const List<String> _labels = [
    'Assigned',
    'On the Way',
    'Arrived',
    'Start Ride',
    'Complete',
  ];

  @override
  void initState() {
    super.initState();
    _fill = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void didUpdateWidget(StatusStepIndicator old) {
    super.didUpdateWidget(old);
    if (old.current != widget.current) {
      _fill.forward(from: 0);
      _fill.repeat();
    }
  }

  @override
  void dispose() {
    _fill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // ── Compact: less padding, smaller overall ──────────────────
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final leftIdx  = i ~/ 2;
            final isDone   = _steps[leftIdx].index < widget.current.index;
            final isActive = _steps[leftIdx] == widget.current;

            if (isDone) {
              return Expanded(
                child: Container(
                  height: 2,
                  color: AppColors.success,
                ),
              );
            }

            if (isActive) {
              return Expanded(
                child: AnimatedBuilder(
                  animation: _fill,
                  builder: (context, child) => Stack(
                    children: [
                      Container(height: 2, color: const Color(0xFFE5E7EB)),
                      FractionallySizedBox(
                        widthFactor: _fill.value,
                        child: Container(height: 2, color: AppColors.primaryPurple),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Expanded(
              child: Container(height: 2, color: const Color(0xFFE5E7EB)),
            );
          }

          // ── Dot ────────────────────────────────────────────────
          final idx       = i ~/ 2;
          final step      = _steps[idx];
          final isDone    = step.index < widget.current.index;
          final isCurrent = step == widget.current;

          Widget dot;
          if (isDone) {
            // ── Green filled + check ─────────────────────────────
            dot = Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 9, color: Colors.white),
            );
          } else if (isCurrent) {
            // ── Purple pulsing ───────────────────────────────────
            dot = AnimatedBuilder(
              animation: _fill,
              builder: (context, child) {
                final alpha = 0.2 + 0.15 * ((_fill.value * 3.14159) % 3.14159 / 3.14159);
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
            // ── Grey empty ───────────────────────────────────────
            dot = Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD1D5DB), width: 1.5),
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 14, height: 14, child: dot),
              const SizedBox(height: 3),
              Text(
                _labels[idx],
                style: TextStyle(
                  fontSize: 7.5,
                  fontWeight: (isCurrent || isDone) ? FontWeight.w700 : FontWeight.w400,
                  color: isDone
                      ? AppColors.success
                      : isCurrent
                          ? AppColors.primaryPurple
                          : const Color(0xFFB0B8C1),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}