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

  // ✅ final not const — enum values from external file can't be const list
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ✅ withValues instead of withOpacity
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final leftIdx = i ~/ 2;
            final isDone  = _steps[leftIdx].index < widget.current.index;
            final isActive = _steps[leftIdx] == widget.current;

            if (isDone) {
              return Expanded(
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }

            if (isActive) {
              return Expanded(
                child: AnimatedBuilder(
                  animation: _fill,
                  // ✅ named params instead of _  __
                  builder: (context, child) {
                    return Stack(
                      children: [
                        Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: _fill.value,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            }

            return Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }

          final idx       = i ~/ 2;
          final step      = _steps[idx];
          final isDone    = step.index < widget.current.index;
          final isCurrent = step == widget.current;

          Widget circle;
          if (isDone) {
            circle = Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 12, color: Colors.white),
            );
          } else if (isCurrent) {
            circle = AnimatedBuilder(
              animation: _fill,
              // ✅ named params
              builder: (context, child) {
                final pulse = _fill.value * 2 * 3.14159;
                final alpha = 0.2 + 0.15 * ((pulse % 3.14159) / 3.14159);
                return Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        // ✅ withValues instead of withOpacity
                        color: AppColors.primaryPurple.withValues(alpha: alpha),
                        blurRadius: 8,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 7,
                      height: 7,
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
            circle = Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFD1D5DB),
                  width: 1.5,
                ),
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 20, height: 20, child: circle),
              const SizedBox(height: 4),
              Text(
                _labels[idx],
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: (isCurrent || isDone)
                      ? FontWeight.w700
                      : FontWeight.w400,
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