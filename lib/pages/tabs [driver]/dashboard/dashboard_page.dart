import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../theme/app_colors.dart';
import '../../../routing/router.dart';
import '../../../providers/online_provider.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/tab_bar.dart';
import 'dashboard_widgets.dart';
import 'dashboard_cards.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {

  late AnimationController _bounceCtrl;
  late Animation<double> _bounceScale;

  late AnimationController _cardCtrl;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();

    // Bounce animation (toggle button effect)
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
    );

    _bounceScale = Tween<double>(begin: 1.0, end: 0.84).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );

    // Card animation (online activity panel)
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _cardFade = CurvedAnimation(
      parent: _cardCtrl,
      curve: Curves.easeOut,
    );

    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic),
    );

    // Load driver profile after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnlineProvider>().loadDriverProfile();
    });
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  void _handleTabTap(int index) {
    final routes = [
      AppRouter.driverDashboard,
      AppRouter.driverEarningsPage,
      AppRouter.driverRides,
      AppRouter.driverProfile,
    ];

    AppRouter.replace(context, routes[index]);
  }

  Future<void> _handleToggle(OnlineProvider online) async {
    await _bounceCtrl.forward();
    await _bounceCtrl.reverse();

    final wasOnline = online.isOnline;
    await online.toggleOnline();

    if (wasOnline) {
      await _cardCtrl.reverse();
    } else if (online.isOnline) {
      _cardCtrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final online = context.watch<OnlineProvider>();
    final auth = context.watch<AuthProvider>();
    final driver = online.driverProfile;
    final isOnline = online.isOnline;

    // Show backend errors safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (online.error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(online.error!),
              backgroundColor: Colors.red,
            ),
          );

        online.clearError();
      }
    });

    // Keep animation synced with state
    if (isOnline && !_cardCtrl.isAnimating && _cardCtrl.value == 0) {
      _cardCtrl.forward();
    } else if (!isOnline && !_cardCtrl.isAnimating && _cardCtrl.value == 1) {
      _cardCtrl.reverse();
    }

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: DashboardHeader(isOnline: isOnline),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    PowerSection(
                      isOnline: isOnline,
                      bounceScale: _bounceScale,
                      onToggle: online.loading
                          ? () {}
                          : () => _handleToggle(online),
                    ),

                    const SizedBox(height: 32),

                    if (isOnline || _cardCtrl.isAnimating)
                      FadeTransition(
                        opacity: _cardFade,
                        child: SlideTransition(
                          position: _cardSlide,
                          child: ActivityCard(
                            isOnline: isOnline,
                            onlineTime: online.onlineTimeFormatted,
                            ridesCompleted: driver?.totalTrips ?? 0,
                          ),
                        ),
                      ),

                    if (driver != null) ...[
                      const SizedBox(height: 16),
                      DriverStatusRow(
                        rating: driver.ratingAverage,
                        streakDays: 0,
                        level: 'Standard',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: DriverTabBar(
        currentIndex: 0,
        onTap: _handleTabTap,
      ),
    );
  }
}