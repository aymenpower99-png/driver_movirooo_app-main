import 'package:flutter/material.dart';
import '../../../../core/models/earnings_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

class EarningsSummaryCard extends StatelessWidget {
  final EarningsModel earnings;
  const EarningsSummaryCard({super.key, required this.earnings});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row(
            label: AppLocalizations.of(
              context,
            ).translate('earnings_fixed_salary'),
            value: '${earnings.salary.toStringAsFixed(0)} DT',
            context: context,
          ),
          const SizedBox(height: 10),
          _Row(
            label: AppLocalizations.of(
              context,
            ).translate('earnings_commission_earned'),
            value: '+${earnings.commission.toStringAsFixed(0)} DT',
            context: context,
            valueColor: const Color(0xFF22C55E),
          ),
          const SizedBox(height: 14),
          Divider(color: AppColors.border(context), height: 1),
          const SizedBox(height: 14),
          _Row(
            label: AppLocalizations.of(
              context,
            ).translate('earnings_net_earnings'),
            value: '${earnings.netEarnings.toStringAsFixed(0)} DT',
            context: context,
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final BuildContext context;
  final Color? valueColor;
  final bool bold;

  const _Row({
    required this.label,
    required this.value,
    required this.context,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext ctx) {
    final baseStyle = bold
        ? AppTextStyles.bodyLarge(
            context,
          ).copyWith(fontWeight: FontWeight.w900, fontSize: 17)
        : AppTextStyles.bodyMedium(
            context,
          ).copyWith(fontSize: 14, color: AppColors.subtext(context));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: baseStyle),
        Text(
          value,
          style: baseStyle.copyWith(
            color: valueColor ?? AppColors.text(context),
          ),
        ),
      ],
    );
  }
}
