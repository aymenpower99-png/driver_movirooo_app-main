import 'package:flutter/material.dart';
import '../../../../core/models/earnings_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class EarningsChart extends StatelessWidget {
  final List<WeeklyData> weekly;
  const EarningsChart({super.key, required this.weekly});

  static const double _maxBarHeight = 120.0;

  @override
  Widget build(BuildContext context) {
    if (weekly.isEmpty) return const SizedBox.shrink();

    final maxVal = weekly.fold<double>(
        0, (prev, w) => w.salary + w.commission > prev ? w.salary + w.commission : prev);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Weekly Earnings',
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              _LegendDot(color: AppColors.primaryPurple, label: 'Salary'),
              const SizedBox(width: 14),
              _LegendDot(
                color: AppColors.primaryPurple.withValues(alpha: 0.30),
                label: 'Commission',
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: _maxBarHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weekly.map((w) {
                final total = w.salary + w.commission;
                final salaryH =
                    maxVal > 0 ? (w.salary / maxVal) * _maxBarHeight : 0.0;
                final totalH =
                    maxVal > 0 ? (total / maxVal) * _maxBarHeight : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          height: totalH,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withValues(alpha: 0.25),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                        ),
                        Container(
                          height: salaryH,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: weekly.map((w) {
              return Expanded(
                child: Text(
                  'W${w.week}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.subtext(context),
                    fontSize: 11,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: AppColors.subtext(context),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
