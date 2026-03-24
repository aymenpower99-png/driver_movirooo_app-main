import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

class _MonthData {
  final String month;
  final String trips;
  final String commission;
  final String amount;
  final String status;

  const _MonthData({
    required this.month,
    required this.trips,
    required this.commission,
    required this.amount,
    required this.status,
  });
}

const List<_MonthData> _recentMonths = [
  _MonthData(
    month: 'September 2024',
    trips: '158 Trips',
    commission: '780.00 DT Commission',
    amount: '3,120.00 DT',
    status: 'SETTLED',
  ),
  _MonthData(
    month: 'August 2024',
    trips: '172 Trips',
    commission: '850.00 DT Commission',
    amount: '3,400.00 DT',
    status: 'SETTLED',
  ),
  _MonthData(
    month: 'July 2024',
    trips: '145 Trips',
    commission: '720.00 DT Commission',
    amount: '2,880.00 DT',
    status: 'SETTLED',
  ),
];

class RecentMonths extends StatelessWidget {
  const RecentMonths({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section title ──────────────────────────────
        Text(
          AppLocalizations.of(context).translate('earnings_recent_months'),
          style: TextStyle(
            color: AppColors.primaryPurple,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 12),

        // ── Month cards ────────────────────────────────
        ..._recentMonths.map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _MonthCard(data: m),
          ),
        ),
      ],
    );
  }
}

class _MonthCard extends StatelessWidget {
  final _MonthData data;
  const _MonthCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.month,
                  style: AppTextStyles.bodyLarge(
                    context,
                  ).copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.trips}  •  ${data.commission}',
                  style: AppTextStyles.bodySmall(
                    context,
                  ).copyWith(color: AppColors.subtext(context)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                data.amount,
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(
                  context,
                ).translate('earnings_status_settled'),
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
