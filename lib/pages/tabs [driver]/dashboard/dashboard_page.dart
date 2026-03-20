import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../routing/router.dart';
import '../widgets/tab_bar.dart';
import 'dashboard_widgets.dart';
import 'dashboard_cards.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  bool _isOnline = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  void _handleTabTap(int index) {
    final routes = [
      AppRouter.driverDashboard,
      AppRouter.driverEarningsPage,
      AppRouter.driverRides,
      AppRouter.driverProfile,
    ];
    AppRouter.replace(context, routes[index]);
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                DashboardHeader(isOnline: _isOnline),
                const SizedBox(height: 20),
                const EarningsBanner(),
                const SizedBox(height: 16),
                OnlineCard(
                  isOnline: _isOnline,
                  isDark: isDark,
                  onToggle: () => setState(() => _isOnline = !_isOnline),
                ),
                const SizedBox(height: 16),
                TripOverviewCard(isDark: isDark),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: DriverTabBar(
        currentIndex: 0,
        onTap: _handleTabTap,
      ),
    );
  }
}