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
    with TickerProviderStateMixin {
  bool _isOnline = false;

  late AnimationController _bounceCtrl;
  late Animation<double> _bounceScale;

  // Slide+fade for the activity card appearing on go-online
  late AnimationController _cardCtrl;
  late Animation<double>   _cardFade;
  late Animation<Offset>   _cardSlide;

  void _handleTabTap(int index) {
    final routes = [
      AppRouter.driverDashboard,
      AppRouter.driverEarningsPage,
      AppRouter.driverRides,
      AppRouter.driverProfile,
    ];
    AppRouter.replace(context, routes[index]);
  }

  Future<void> _handleToggle() async {
    // Bounce the power button
    await _bounceCtrl.forward();
    await _bounceCtrl.reverse();

    final goingOnline = !_isOnline;

    if (!goingOnline) {
      // Going offline — slide card out first, then flip state
      await _cardCtrl.reverse();
      setState(() => _isOnline = false);
    } else {
      // Going online — flip state, then slide card in
      setState(() => _isOnline = true);
      _cardCtrl.forward();
    }
  }

  @override
  void initState() {
    super.initState();

    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
    );
    _bounceScale = Tween<double>(begin: 1.0, end: 0.84).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );

    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _cardFade = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: DashboardHeader(isOnline: _isOnline),
            ),

            // ── Body ──────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // Power button + title + subtitle
                    PowerSection(
                      isOnline: _isOnline,
                      bounceScale: _bounceScale,
                      onToggle: _handleToggle,
                    ),

                    const SizedBox(height: 32),

                    // Activity card — slides in when online, out when offline
                    if (_isOnline || _cardCtrl.isAnimating)
                      FadeTransition(
                        opacity: _cardFade,
                        child: SlideTransition(
                          position: _cardSlide,
                          child: ActivityCard(isOnline: _isOnline),
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
        currentIndex: 0,
        onTap: _handleTabTap,
      ),
    );
  }
}