import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/pages/tabs%20%5Bdriver%5D/earnings/EarningsTabs.dart';
import 'package:moviroo_driver_app/pages/tabs%20%5Bdriver%5D/widgets/tab_bar.dart';
import '../../../../theme/app_colors.dart';
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
  int _selectedTab = 1; // 0=Weekly, 1=Monthly, 2=All-Time

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [

            // ── Tabs pinned at top ───────────────────────
            EarningsTabs(
              selectedIndex: _selectedTab,
              onTap: (i) => setState(() => _selectedTab = i),
            ),

            // ── Scrollable content ───────────────────────
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const EarningsSummaryCard(
                          amount: '3,420.00 DT',
                          growth: '+8.5%',
                        ),
                        const SizedBox(height: 12),
                        const StatsRow(),
                        const SizedBox(height: 12),
                        const EarningsChart(),
                        const SizedBox(height: 12),
                        const MonthlyBreakdown(),
                        const SizedBox(height: 32),
                      ]),
                    ),
                  ),
                ],
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