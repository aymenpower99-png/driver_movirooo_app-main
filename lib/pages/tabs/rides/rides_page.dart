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
import '../widgets/tab_bar.dart';
import 'ride_widgets.dart';
import 'available_ride_card.dart';

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
          return _OfferCard(offer: offer);
        },
      ),
    );
  }
}

// ── Offer card — matches RideCard design with Accept/Reject buttons ──────────

class _OfferCard extends StatelessWidget {
  final OfferModel offer;
  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final ride = offer.ride;
    final t = AppLocalizations.of(context).translate;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header (avatar + name + status pill) ───────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    ride.passengerInitials,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.passengerName ?? 'Passenger',
                        style: AppTextStyles.bodyLarge(context),
                      ),
                      if (ride.vehicleClassName.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          ride.vehicleClassName,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.subtext(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    t('ride_status_new'),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: AppColors.border(context)),

          // ── Ride time (date + time + distance chips) ───────
          if (ride.rideTime.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Builder(builder: (_) {
                final dt = tryParseDateTime(ride.rideTime);
                if (dt == null) {
                  return Row(children: [
                    RideInfoChip(icon: Icons.schedule_outlined, label: ride.rideTime),
                    if ((ride.distanceKm ?? 0) > 0) ...[
                      const SizedBox(width: 14),
                      RideInfoChip(icon: Icons.route_rounded, label: '${ride.distanceKm!.toStringAsFixed(1)} km'),
                    ],
                  ]);
                }
                return Row(children: [
                  RideInfoChip(icon: Icons.calendar_today_outlined, label: formatRideDate(dt)),
                  const SizedBox(width: 14),
                  RideInfoChip(icon: Icons.access_time_outlined, label: formatRideTime(dt)),
                  if ((ride.distanceKm ?? 0) > 0) ...[
                    const SizedBox(width: 14),
                    RideInfoChip(icon: Icons.route_rounded, label: '${ride.distanceKm!.toStringAsFixed(1)} km'),
                  ],
                ]);
              }),
            ),

          // ── Route timeline + price ─────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RideRouteTimeline(
                    from: ride.from,
                    to: ride.to,
                    textStyle: AppTextStyles.bodySmall(context),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${ride.price.toStringAsFixed(1)} TND',
                  style: AppTextStyles.priceMedium(context).copyWith(
                    color: AppColors.primaryPurple,
                  ),
                ),
              ],
            ),
          ),

          // ── Accept / Reject buttons ────────────────────────
          Divider(height: 1, color: AppColors.border(context)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final ok = await context.read<RideProvider>().rejectOffer(offer.id);
                      if (context.mounted && !ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.read<RideProvider>().error ?? 'Error'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(t('ride_reject')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final ok = await context.read<RideProvider>().acceptOffer(offer.id);
                      if (context.mounted) {
                        if (ok) {
                          final ride = offer.ride;
                          final initial = (ride.passengerName ?? '').trim().isNotEmpty
                              ? ride.passengerName!.trim()[0].toUpperCase()
                              : '?';
                          final trackRide = tracking.RideModel(
                            id: offer.rideId,
                            passenger: tracking.PassengerModel(
                              name: ride.passengerName ?? 'Passenger',
                              rating: 4.8,
                              avatarInitial: initial,
                              phone: ride.passengerPhone,
                            ),
                            pickupAddress: ride.from,
                            dropOffAddress: ride.to,
                            distanceKm: ride.distanceKm ?? 0,
                            etaMinutes: 0,
                            earningsAmount: ride.price,
                            currency: 'TND',
                            pickupLat: ride.pickupLat,
                            pickupLon: ride.pickupLon,
                            dropoffLat: ride.dropoffLat,
                            dropoffLon: ride.dropoffLon,
                          );
                          Navigator.of(context).push(TrackPassengerPage.route(trackRide));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.read<RideProvider>().error ?? 'Error'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(t('ride_accept')),
                  ),
                ),
              ],
            ),
          ),
        ],
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
