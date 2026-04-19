import 'package:flutter/material.dart';
import '../../../../core/models/earnings_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class MonthlyBreakdown extends StatelessWidget {
  final EarningsModel earnings;
  const MonthlyBreakdown({super.key, required this.earnings});

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Monthly Breakdown',
            style: AppTextStyles.bodyLarge(context).copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 16),
          _BreakdownRow(
            label: 'Base Salary',
            value: '${earnings.baseSalary.toStringAsFixed(2)} DT',
            isNegative: false,
          ),
          Divider(height: 20, color: AppColors.border(context)),
          _BreakdownRow(
            label: earnings.tiers.isNotEmpty
                ? 'Commission Bonuses (${earnings.tiers.where((t) => t.reached).length} tiers reached)'
                : 'Commission (${earnings.ridesCompleted > earnings.ridesThreshold ? earnings.ridesCompleted - earnings.ridesThreshold : 0} extra rides)',
            value: '+${earnings.commission.toStringAsFixed(2)} DT',
            isNegative: false,
            valueColor: Colors.green,
          ),
          Divider(height: 20, color: AppColors.border(context)),
          _BreakdownRow(
            label: 'Deductions (${earnings.missedDays} missed days)',
            value: '-${earnings.deductionAmount.toStringAsFixed(2)} DT',
            isNegative: true,
          ),
          Divider(height: 20, color: AppColors.border(context)),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Net Earnings',
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${earnings.total.toStringAsFixed(2)} DT',
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isNegative;
  final Color? valueColor;

  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.isNegative,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: AppColors.subtext(context),
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyLarge(context).copyWith(
            fontWeight: FontWeight.w800,
            color:
                valueColor ?? (isNegative ? Colors.red : AppColors.text(context)),
          ),
        ),
      ],
    );
  }
}
