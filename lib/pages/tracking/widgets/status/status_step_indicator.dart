// lib/pages/tracking/widgets/status/status_step_indicator.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/l10n/app_localizations.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/pages/tracking/ride_model.dart';
import 'step_dot.dart';
import 'step_connector.dart';

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

  List<String> _localizedLabels(BuildContext context) {
    final t = AppLocalizations.of(context).translate;
    return [
      t('tracking_step_assigned'),
      t('tracking_step_on_way'),
      t('tracking_step_arrived'),
      t('tracking_step_start_ride'),
      t('tracking_step_complete'),
    ];
  }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = AppColors.surface(context);

    // Inactive label: white in dark mode, black in light mode
    final inactiveLabelColor = isDark ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.07),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final leftIdx = i ~/ 2;
            final isDone = _steps[leftIdx].index < widget.current.index;
            final isActive = _steps[leftIdx] == widget.current;
            return StepConnector(
              isDone: isDone,
              isActive: isActive,
              animation: _fill,
              isDark: isDark,
            );
          }

          // ── Dot ──────────────────────────────────────────────
          final idx = i ~/ 2;
          final step = _steps[idx];
          final isDone = step.index < widget.current.index;
          final isCurrent = step == widget.current;

          // ── Label color logic ────────────────────────────────
          final Color labelColor;
          if (isDone) {
            labelColor = AppColors.success;
          } else if (isCurrent) {
            labelColor = AppColors.primaryPurple;
          } else {
            labelColor = inactiveLabelColor;
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: StepDot(
                  isDone: isDone,
                  isCurrent: isCurrent,
                  animation: _fill,
                  isDark: isDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _localizedLabels(context)[idx],
                style: TextStyle(
                  fontSize: 7.5,
                  fontWeight: (isCurrent || isDone)
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: labelColor,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
