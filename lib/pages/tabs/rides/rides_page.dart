// ════════════════════════════════════════════════════════════════════
//  rides_page.dart
// ════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_text_styles.dart';
import '../../../providers/ride_provider.dart';
import '../../../core/models/offer_model.dart';
import '../../../core/models/ride_model.dart';
import '../../../core/widgets/app_toast.dart';
import '../widgets/tab_bar.dart';
import 'ride_widgets.dart';
import 'available_ride_card.dart';
import 'offer_card.dart';

// ── Tracking imports (relative — same Rides folder) ──────────────────────────
import '../../tracking/tracking_page.dart';
import '../../tracking/ride_model.dart' as tracking;
// ─────────────────────────────────────────────────────────────────────────────

class RidesPage extends StatefulWidget {
  const RidesPage({super.key});

  @override
  State<RidesPage> createState() => _RidesPageState();
}

class _RidesPageState extends State<RidesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<String> _tabLabels(BuildContext context) {
    final t = AppLocalizations.of(context).translate;
    return [
      t('rides_tab_available'),
      t('rides_tab_upcoming'),
      t('rides_tab_completed'),
      t('rides_tab_cancelled'),
    ];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RideProvider>();
      provider.loadPendingOffers();
      provider.loadDriverRides();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = context.watch<RideProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        centerTitle: false,
        title: Text(
          AppLocalizations.of(context).translate('rides_page_title'),
          style: AppTextStyles.pageTitle(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border(context), width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 0,
              ),
              indicatorColor: AppColors.primaryPurple,
              indicatorWeight: 2.5,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              labelColor: AppColors.primaryPurple,
              unselectedLabelColor: AppColors.gray7B,
              tabs: _tabLabels(
                context,
              ).map((label) => Tab(text: label)).toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _AvailableTab(),
          _UpcomingTab(rides: rideProvider.upcomingRides),
          _RideListTab(
            rides: rideProvider.completedRides,
            loading: rideProvider.ridesLoading,
            emptyMessage: AppLocalizations.of(
              context,
            ).translate('ride_empty_completed'),
            statusLabel: AppLocalizations.of(
              context,
            ).translate('ride_status_completed'),
            statusColor: AppColors.success,
          ),
          _RideListTab(
            rides: rideProvider.cancelledRides,
            loading: rideProvider.ridesLoading,
            emptyMessage: AppLocalizations.of(
              context,
            ).translate('ride_empty_cancelled'),
            statusLabel: AppLocalizations.of(
              context,
            ).translate('ride_status_cancelled'),
            statusColor: AppColors.error,
          ),
        ],
      ),
      bottomNavigationBar: DriverTabBar(currentIndex: 2),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  AVAILABLE TAB  —  real offers from RideProvider
// ════════════════════════════════════════════════════════════════════

class _AvailableTab extends StatelessWidget {
  const _AvailableTab();

  @override
  Widget build(BuildContext context) {
    final rideProvider = context.watch<RideProvider>();
    final t = AppLocalizations.of(context).translate;

    if (rideProvider.loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFA855F7)),
      );
    }

    if (rideProvider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(rideProvider.error!, style: TextStyle(color: AppColors.error)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.read<RideProvider>().loadPendingOffers(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (rideProvider.pendingOffers.isEmpty) {
      return RideEmptyState(message: t('ride_empty_available'));
    }

    return RefreshIndicator(
      color: const Color(0xFFA855F7),
      onRefresh: () => context.read<RideProvider>().loadPendingOffers(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        itemCount: rideProvider.pendingOffers.length,
        itemBuilder: (_, i) {
          final offer = rideProvider.pendingOffers[i];
          return OfferCard(offer: offer);
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  UPCOMING TAB
// ════════════════════════════════════════════════════════════════════

class _UpcomingTab extends StatelessWidget {
  final List<RideModel> rides;
  const _UpcomingTab({required this.rides});

  tracking.RideModel _toTrackingRide(RideModel r) {
    final initial = (r.passengerName ?? '').trim().isNotEmpty
        ? r.passengerName!.trim()[0].toUpperCase()
        : '?';
    return tracking.RideModel(
      id: r.id,
      passenger: tracking.PassengerModel(
        name: r.passengerName ?? 'Passenger',
        rating: 4.8,
        avatarInitial: initial,
        phone: r.passengerPhone,
      ),
      pickupAddress: r.from,
      dropOffAddress: r.to,
      distanceKm: r.distanceKm ?? 0,
      etaMinutes: 0,
      earningsAmount: r.price,
      currency: 'TND',
      pickupLat: r.pickupLat,
      pickupLon: r.pickupLon,
      dropoffLat: r.dropoffLat,
      dropoffLon: r.dropoffLon,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (rides.isEmpty) {
      return RideEmptyState(
        message: AppLocalizations.of(context).translate('ride_empty_upcoming'),
      );
    }
    return RefreshIndicator(
      color: AppColors.primaryPurple,
      onRefresh: () => context.read<RideProvider>().loadDriverRides(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        itemCount: rides.length,
        itemBuilder: (_, i) => RideCard(
          ride: rides[i],
          statusLabel: AppLocalizations.of(
            context,
          ).translate('ride_status_scheduled'),
          statusColor: AppColors.primaryPurple,
          onTrack: (ride) => Navigator.of(
            context,
          ).push(TrackPassengerPage.route(_toTrackingRide(ride))),
          onChat: (ride) {
            Navigator.pushNamed(context, '/chat', arguments: {
              'rideId': ride.id,
              'passengerName': ride.passengerName ?? 'Passenger',
            });
          },
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  GENERIC RIDE LIST TAB  (Completed / Cancelled)
// ════════════════════════════════════════════════════════════════════

class _RideListTab extends StatelessWidget {
  final List<RideModel> rides;
  final bool loading;
  final String emptyMessage;
  final String statusLabel;
  final Color statusColor;

  const _RideListTab({
    required this.rides,
    this.loading = false,
    required this.emptyMessage,
    required this.statusLabel,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryPurple),
      );
    }
    if (rides.isEmpty) return RideEmptyState(message: emptyMessage);
    return RefreshIndicator(
      color: AppColors.primaryPurple,
      onRefresh: () => context.read<RideProvider>().loadDriverRides(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        itemCount: rides.length,
        itemBuilder: (_, i) => RideCard(
          ride: rides[i],
          statusLabel: statusLabel,
          statusColor: statusColor,
        ),
      ),
    );
  }
}
