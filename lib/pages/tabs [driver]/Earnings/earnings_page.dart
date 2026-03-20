import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/pages/tabs%20%5Bdriver%5D/earnings/EarningsTabs.dart';
import 'package:moviroo_driver_app/pages/tabs%20%5Bdriver%5D/widgets/tab_bar.dart';
import '../../../../theme/app_colors.dart';
import '_EarningsHeader.dart';
import '_EarningsSummaryCard.dart';
import '_StatsRow.dart';
import '_EarningsChart.dart';
import '_MonthlyBreakdown.dart';
import '_RecentMonths.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {

  // ✅ Toutes les variables en haut du state
  String _selectedMonth = 'October 2024';
  int _selectedTab = 1; // 0=Weekly, 1=Monthly, 2=All-Time

  final List<String> _months = [
    'October 2024',
    'September 2024',
    'August 2024',
    'July 2024',
  ];

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ..._months.map((m) => ListTile(
            title: Text(m,
                style: TextStyle(
                  color: m == _selectedMonth
                      ? AppColors.primaryPurple
                      : AppColors.text(context),
                  fontWeight: m == _selectedMonth
                      ? FontWeight.w700
                      : FontWeight.w500,
                )),
            trailing: m == _selectedMonth
                ? Icon(Icons.check_rounded,
                    color: AppColors.primaryPurple)
                : null,
            onTap: () {
              setState(() => _selectedMonth = m);
              Navigator.pop(context);
            },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [

            // ── Month selector ───────────────────────────
            SliverToBoxAdapter(
              child: EarningsHeader(
                month: _selectedMonth,
                onChangeTap: _showMonthPicker,
              ),
            ),

            // ── Weekly / Monthly / All-Time tabs ─────────
            SliverToBoxAdapter(
              child: EarningsTabs(
                selectedIndex: _selectedTab,
                onTap: (i) => setState(() => _selectedTab = i),
              ),
            ),

            // ── Content ───────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 24),
                  const RecentMonths(),
                  const SizedBox(height: 32),
                ]),
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