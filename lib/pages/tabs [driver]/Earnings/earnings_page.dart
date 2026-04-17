import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/earnings_provider.dart';
import '../../../../core/models/earnings_model.dart';
import '../widgets/tab_bar.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '_EarningsSummaryCard.dart';
import '_StatsRow.dart';
import '_EarningsChart.dart';
import '_MonthlyBreakdown.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EarningsProvider>().loadEarnings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EarningsProvider>();
    final earnings = provider.earnings;
    final t = AppLocalizations.of(context).translate;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            // Month selector header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border(context)),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: provider.previousMonth,
                    child: Icon(Icons.chevron_left_rounded,
                        color: AppColors.primaryPurple, size: 28),
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_month_outlined,
                      color: AppColors.primaryPurple, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    provider.displayMonth,
                    style: AppTextStyles.bodyLarge(context)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: provider.nextMonth,
                    child: Icon(Icons.chevron_right_rounded,
                        color: AppColors.primaryPurple, size: 28),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: provider.loading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 40,
                                  color: AppColors.subtext(context)),
                              const SizedBox(height: 12),
                              Text(t('earnings_load_error'),
                                  style:
                                      AppTextStyles.settingsItem(context)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: provider.loadEarnings,
                                child: Text(t('retry')),
                              ),
                            ],
                          ),
                        )
                      : earnings == null
                          ? Center(
                              child: Text(t('earnings_no_data'),
                                  style:
                                      AppTextStyles.settingsItem(context)))
                          : RefreshIndicator(
                              onRefresh: provider.loadEarnings,
                              child: CustomScrollView(
                                slivers: [
                                  SliverPadding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 16, 16, 32),
                                    sliver: SliverList(
                                      delegate: SliverChildListDelegate([
                                        EarningsSummaryCard(
                                            earnings: earnings),
                                        const SizedBox(height: 12),
                                        StatsRow(earnings: earnings),
                                        const SizedBox(height: 12),
                                        if (earnings
                                                .ridesLeftForCommission >
                                            0)
                                          _CommissionProgress(
                                              earnings: earnings),
                                        if (earnings
                                                .ridesLeftForCommission >
                                            0)
                                          const SizedBox(height: 12),
                                        EarningsChart(
                                            weekly: earnings.weekly),
                                        const SizedBox(height: 12),
                                        MonthlyBreakdown(
                                            earnings: earnings),
                                        const SizedBox(height: 32),
                                      ]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DriverTabBar(
        currentIndex: 1,
        onTap: (i) {},
      ),
    );
  }
}

class _CommissionProgress extends StatelessWidget {
  final EarningsModel earnings;
  const _CommissionProgress({required this.earnings});

  @override
  Widget build(BuildContext context) {
    final ridesLeft = earnings.ridesLeftForCommission;
    final threshold = earnings.ridesThreshold;
    final completed = earnings.ridesCompleted;
    final progress =
        threshold > 0 ? (completed / threshold).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded,
                  color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$ridesLeft more rides to earn commission',
                  style: AppTextStyles.bodyMedium(context)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.border(context),
              valueColor:
                  AlwaysStoppedAnimation(AppColors.primaryPurple),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$completed / $threshold rides',
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