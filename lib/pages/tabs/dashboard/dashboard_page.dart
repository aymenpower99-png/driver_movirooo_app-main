import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';

import '../../../../theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../routing/router.dart';
import '../../../providers/online_provider.dart';
import '../../../core/widgets/app_toast.dart';
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

    _bounceScale = Tween<double>(
      begin: 1.0,
      end: 0.84,
    ).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));

    // Card animation (online activity panel)
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _cardFade = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);

    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));

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

    // If going online, check GPS first
    if (!online.isOnline) {
      final gpsOn = await Geolocator.isLocationServiceEnabled();
      if (!gpsOn) {
        _showGpsRequiredDialog(online);
        return;
      }
    }

    final wasOnline = online.isOnline;
    await online.toggleOnline();

    // If provider detected GPS off after our check (race), show modal
    if (online.gpsRequired) {
      _showGpsRequiredDialog(online);
      return;
    }

    if (wasOnline) {
      await _cardCtrl.reverse();
    } else if (online.isOnline) {
      _cardCtrl.forward();
    }
  }

  /// Shows a non-dismissable dialog that waits for GPS to be enabled.
  void _showGpsRequiredDialog(OnlineProvider online) {
    StreamSubscription<ServiceStatus>? sub;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        // Listen for GPS service status changes
        sub = Geolocator.getServiceStatusStream().listen((status) {
          if (status == ServiceStatus.enabled) {
            sub?.cancel();
            if (!ctx.mounted) return;
            Navigator.of(ctx).pop();
            online.clearGpsRequired();
            // GPS is now on — retry toggle
            _handleToggle(online);
          }
        });

        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: AppColors.surface(context),
            title: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_off_rounded,
                    color: AppColors.primaryPurple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(
                      context,
                    ).translate('dashboard_enable_location'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text(context),
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              AppLocalizations.of(
                context,
              ).translate('dashboard_gps_required_message'),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.subtext(context),
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  sub?.cancel();
                  online.clearGpsRequired();
                  Navigator.of(ctx).pop();
                },
                child: Text(
                  AppLocalizations.of(context).translate('cancel'),
                  style: TextStyle(color: AppColors.subtext(context)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  // Try native in-app dialog first
                  final location = loc.Location();
                  final enabled = await location.requestService();
                  if (!enabled) {
                    // Fallback to system settings if native dialog fails
                    await Geolocator.openLocationSettings();
                  }
                },
                icon: const Icon(Icons.gps_fixed, size: 18),
                label: Text(
                  AppLocalizations.of(
                    context,
                  ).translate('dashboard_turn_on_gps'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      // Cleanup if dialog closed without GPS enable
      sub?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final online = context.watch<OnlineProvider>();
    final driver = online.driverProfile;
    final isOnline = online.isOnline;

    // Show backend errors safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (online.error != null) {
        AppToast.error(context, online.error!);

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
                            onlineTime: online.todayOnlineFormatted,
                            vehicleName: driver?.vehicle?.displayName ?? '—',
                            vehicleClass: driver?.vehicle?.className ?? '—',
                            acceptanceRate: driver?.acceptanceRate ?? 100,
                            cancellations: driver?.cancellationCount ?? 0,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: DriverTabBar(currentIndex: 0, onTap: _handleTabTap),
    );
  }
}
