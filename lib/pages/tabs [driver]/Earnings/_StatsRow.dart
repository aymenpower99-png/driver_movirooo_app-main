import 'package:flutter/material.dart';
import '../../../../core/models/earnings_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class StatsRow extends StatelessWidget {
  final EarningsModel earnings;
  const StatsRow({super.key, required this.earnings});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Rides Completed',
            value: '${earnings.ridesCompleted}',
            sub: 'This month',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Attendance',
            value: '${earnings.attendance}/${earnings.expectedWorkDays}',
            sub: 'Work days',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall(context).copyWith(
              color: AppColors.subtext(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.bodyLarge(context).copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: AppTextStyles.bodySmall(context).copyWith(
              color: AppColors.subtext(context),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
