// ════════════════════════════════════════════════════════════════════
//  rides_page.dart
// ════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_text_styles.dart';
import '../widgets/tab_bar.dart';
import 'ride_model.dart';
import 'ride_dummy_data.dart';
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<RideModel> _ridesFor(RideStatus status) =>
      dummyRides.where((r) => r.status == status).toList();

  @override
  Widget build(BuildContext context) {
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
          _AvailableTab(rides: _ridesFor(RideStatus.available)),
          _UpcomingTab(rides: _ridesFor(RideStatus.upcoming)),
          _RideListTab(
            rides: _ridesFor(RideStatus.completed),
            emptyMessage: AppLocalizations.of(
              context,
            ).translate('ride_empty_completed'),
            statusLabel: AppLocalizations.of(
              context,
            ).translate('ride_status_completed'),
            statusColor: AppColors.success,
          ),
          _RideListTab(
            rides: _ridesFor(RideStatus.cancelled),
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
//  AVAILABLE TAB
// ════════════════════════════════════════════════════════════════════

class _AvailableTab extends StatefulWidget {
  final List<RideModel> rides;
  const _AvailableTab({required this.rides});

  @override
  State<_AvailableTab> createState() => _AvailableTabState();
}

class _AvailableTabState extends State<_AvailableTab> {
  late List<RideModel> _rides;

  @override
  void initState() {
    super.initState();
    _rides = List.from(widget.rides);
  }

  void _accept(RideModel ride) {
    final t = AppLocalizations.of(context).translate;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        content: Text(
          t('ride_accepted_snack').replaceAll('{id}', ride.id),
          style: const TextStyle(fontFamily: 'Inter', color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() => _rides.remove(ride));
  }

  void _reject(RideModel ride) {
    final t = AppLocalizations.of(context).translate;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.error,
        content: Text(
          t('ride_rejected_snack').replaceAll('{id}', ride.id),
          style: const TextStyle(fontFamily: 'Inter', color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() => _rides.remove(ride));
  }

  @override
  Widget build(BuildContext context) {
    if (_rides.isEmpty) {
      return RideEmptyState(
        message: AppLocalizations.of(context).translate('ride_empty_available'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: _rides.length,
      itemBuilder: (_, i) =>
          RideCard(ride: _rides[i], onAccept: _accept, onReject: _reject),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  UPCOMING TAB
// ════════════════════════════════════════════════════════════════════

class _UpcomingTab extends StatelessWidget {
  final List<RideModel> rides;
  const _UpcomingTab({required this.rides});

  /// Maps the rides-page RideModel → tracking RideModel
  tracking.RideModel _toTrackingRide(RideModel r) {
    final initial = r.passengerName.trim().isNotEmpty
        ? r.passengerName.trim()[0].toUpperCase()
        : '?';
    return tracking.RideModel(
      id: r.id,
      passenger: tracking.PassengerModel(
        name: r.passengerName,
        rating: 4.8, // swap for r.rating if your RideModel has it
        avatarInitial: initial,
      ),
      pickupAddress: r.from,
      dropOffAddress: r.to,
      distanceKm: 0, // swap for r.distanceKm if available
      etaMinutes: 0, // swap for r.etaMinutes if available
      earningsAmount: r.price,
      currency: 'TND',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (rides.isEmpty) {
      return RideEmptyState(
        message: AppLocalizations.of(context).translate('ride_empty_upcoming'),
      );
    }
    return ListView.builder(
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
          Navigator.pushNamed(context, '/chat', arguments: {'rideId': ride.id});
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  GENERIC RIDE LIST TAB  (Completed / Cancelled)
// ════════════════════════════════════════════════════════════════════

class _RideListTab extends StatelessWidget {
  final List<RideModel> rides;
  final String emptyMessage;
  final String statusLabel;
  final Color statusColor;

  const _RideListTab({
    required this.rides,
    required this.emptyMessage,
    required this.statusLabel,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    if (rides.isEmpty) return RideEmptyState(message: emptyMessage);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: rides.length,
      itemBuilder: (_, i) => RideCard(
        ride: rides[i],
        statusLabel: statusLabel,
        statusColor: statusColor,
      ),
    );
  }
}
