import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/online_provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final online = context.watch<OnlineProvider>();

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: AppLocalizations.of(context).translate('earnings_total_trips'),
            value: '${online.driverProfile?.totalTrips ?? 0}',
            sub: AppLocalizations.of(context).translate('earnings_this_month'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: AppLocalizations.of(context).translate('earnings_online_time'),
            value: online.allTimeOnlineFormatted,
            sub: AppLocalizations.of(context).translate('earnings_active_hours'),
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
            style: AppTextStyles.bodySmall(
              context,
            ).copyWith(color: AppColors.subtext(context)),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.bodyLarge(
              context,
            ).copyWith(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: AppTextStyles.bodySmall(
              context,
            ).copyWith(color: AppColors.subtext(context), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
