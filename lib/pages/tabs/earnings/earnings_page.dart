import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/earnings_provider.dart';
import '../../../../providers/online_provider.dart';
import '../../../../core/models/earnings_model.dart';
import '../widgets/tab_bar.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import 'earnings_summary_card.dart';
import 'earnings_chart.dart';

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
      // Ensure online time is loaded even if the driver opened this tab first
      context.read<OnlineProvider>().loadDriverProfile();
      context.read<EarningsProvider>().loadEarnings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EarningsProvider>();
    final online = context.watch<OnlineProvider>();
    final earnings = provider.earnings;
    final t = AppLocalizations.of(context).translate;

    // Only show live online time when viewing the current month
    final currentMonth =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    final isCurrentMonth = provider.selectedMonth == currentMonth;

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
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.primaryPurple,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.primaryPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    provider.displayMonth,
                    style: AppTextStyles.bodyLarge(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: provider.nextMonth,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primaryPurple,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: provider.loading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 40,
                            color: AppColors.subtext(context),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t('earnings_load_error'),
                            style: AppTextStyles.settingsItem(context),
                          ),
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
                      child: Text(
                        t('earnings_no_data'),
                        style: AppTextStyles.settingsItem(context),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: provider.loadEarnings,
                      child: CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                // 1. Salary card (full width)
                                _SalaryCard(salary: earnings.salary),
                                const SizedBox(height: 12),

                                // 2. Total Rides + Online Time
                                Row(
                                  children: [
                                    Expanded(
                                      child: _StatCard(
                                        label: t('earnings_total_rides'),
                                        value: '${earnings.ridesCompleted}',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _StatCard(
                                        label: t('earnings_online_time_label'),
                                        value: isCurrentMonth
                                            ? online.monthOnlineFormatted
                                            : '—',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // 3. Tier progress
                                if (earnings.tiers.isNotEmpty)
                                  _TierProgressWidget(earnings: earnings),
                                if (earnings.tiers.isNotEmpty)
                                  const SizedBox(height: 12),

                                // 4. Weekly chart
                                EarningsChart(dailyRides: earnings.dailyRides),
                                const SizedBox(height: 12),

                                // 5. Summary
                                EarningsSummaryCard(earnings: earnings),
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
      bottomNavigationBar: DriverTabBar(currentIndex: 1, onTap: (i) {}),
    );
  }
}

/* ── Salary Card ── */
class _SalaryCard extends StatelessWidget {
  final double salary;
  const _SalaryCard({required this.salary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryPurple,
            AppColors.primaryPurple.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('earnings_fixed_salary'),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${salary.toStringAsFixed(0)} DT',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}

/* ── Stat Card ── */
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
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
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.text(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall(
              context,
            ).copyWith(color: AppColors.subtext(context), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

/* ── Tier Progress ── */
class _TierProgressWidget extends StatelessWidget {
  final EarningsModel earnings;
  const _TierProgressWidget({required this.earnings});

  @override
  Widget build(BuildContext context) {
    final completed = earnings.ridesCompleted;

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
          Text(
            AppLocalizations.of(context).translate('earnings_commission_tiers'),
            style: AppTextStyles.bodyMedium(
              context,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          ...earnings.tiers.map((tier) {
            final progress = tier.requiredRides > 0
                ? (completed / tier.requiredRides).clamp(0.0, 1.0)
                : 1.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tier.tierName,
                          style: AppTextStyles.bodySmall(context).copyWith(
                            fontWeight: FontWeight.w700,
                            color: tier.reached
                                ? AppColors.text(context)
                                : AppColors.subtext(context),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        '$completed / ${tier.requiredRides}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: tier.reached
                              ? AppColors.primaryPurple
                              : AppColors.subtext(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: AppColors.border(context),
                      valueColor: AlwaysStoppedAnimation(
                        AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (earnings.nextTierName != null)
            Text(
              AppLocalizations.of(context)
                  .translate('earnings_rides_to_next_tier')
                  .replaceAll('{count}', '${earnings.nextTierRidesNeeded}')
                  .replaceAll('{tier}', '${earnings.nextTierName}'),
              style: AppTextStyles.bodySmall(
                context,
              ).copyWith(color: AppColors.subtext(context), fontSize: 11),
            )
          else
            Text(
              '${AppLocalizations.of(context).translate('earnings_all_tiers_reached')} 🎉',
              style: AppTextStyles.bodySmall(context).copyWith(
                color: const Color(0xFF10b981),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}
