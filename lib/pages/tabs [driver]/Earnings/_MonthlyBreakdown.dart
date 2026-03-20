import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class MonthlyBreakdown extends StatelessWidget {
  const MonthlyBreakdown({super.key});

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

          Text('Monthly Breakdown',
              style: AppTextStyles.bodyLarge(context).copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 17,
              )),

          const SizedBox(height: 16),

          // ── Gross ──────────────────────────────────────
          _BreakdownRow(
            label: 'Total Gross Revenue',
            value: '4,275.00 DT',
            isNegative: false,
          ),

          Divider(height: 20, color: AppColors.border(context)),

          // ── Commission ─────────────────────────────────
          _BreakdownRow(
            label: 'Total Commission (20%)',
            value: '-855.00 DT',
            isNegative: true,
            showInfo: true,
          ),

          Divider(height: 20, color: AppColors.border(context)),

          // ── Net payout ─────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text('Total Net Payout',
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.w900,
                    )),
              ),
              Text('3,420.00 DT',
                  style: TextStyle(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  )),
            ],
          ),

          const SizedBox(height: 14),

          // ── Info note ──────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded,
                  color: AppColors.primaryPurple, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Monthly performance reports are finalized on the 1st of every month.',
                  style: TextStyle(
                    color: AppColors.primaryPurple,
                    fontSize: 11,
                    height: 1.4,
                  ),
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
  final bool showInfo;

  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.isNegative,
    this.showInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(label,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: AppColors.subtext(context),
                  )),
              if (showInfo) ...[
                const SizedBox(width: 4),
                Icon(Icons.help_outline_rounded,
                    size: 14,
                    color: AppColors.subtext(context)),
              ],
            ],
          ),
        ),
        Text(value,
            style: AppTextStyles.bodyLarge(context).copyWith(
              fontWeight: FontWeight.w800,
              color: isNegative
                  ? AppColors.text(context)
                  : AppColors.text(context),
            )),
      ],
    );
  }
}
