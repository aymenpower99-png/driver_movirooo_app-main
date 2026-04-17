import 'package:flutter/material.dart';
import '../../../../core/models/earnings_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class EarningsSummaryCard extends StatelessWidget {
  final EarningsModel earnings;

  const EarningsSummaryCard({super.key, required this.earnings});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Earnings',
            style: AppTextStyles.bodySmall(context).copyWith(
              color: AppColors.subtext(context),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${earnings.total.toStringAsFixed(2)} DT',
            style: TextStyle(
              color: AppColors.primaryPurple,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          _BreakdownChip(
            label: 'Base Salary',
            value: '${earnings.baseSalary.toStringAsFixed(0)} DT',
            color: AppColors.text(context),
            bgColor: AppColors.bg(context),
          ),
          const SizedBox(height: 8),
          _BreakdownChip(
            label: 'Commission',
            value: '+${earnings.commission.toStringAsFixed(2)} DT',
            color: Colors.green,
            bgColor: Colors.green.withValues(alpha: 0.1),
          ),
          if (earnings.deductionAmount > 0) ...[
            const SizedBox(height: 8),
            _BreakdownChip(
              label: 'Deductions (${earnings.missedDays} days)',
              value: '-${earnings.deductionAmount.toStringAsFixed(2)} DT',
              color: Colors.red,
              bgColor: Colors.red.withValues(alpha: 0.1),
            ),
          ],
        ],
      ),
    );
  }
}

class _BreakdownChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  const _BreakdownChip({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodySmall(context).copyWith(
                color: AppColors.subtext(context),
              )),
          Text(value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              )),
        ],
      ),
    );
  }
}
