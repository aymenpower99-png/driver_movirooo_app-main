import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_text_styles.dart';
import '../../../providers/ride_provider.dart';
import 'package:moviroo_driver_app/providers/online_provider.dart';
import '../../../core/models/offer_model.dart';
import '../../../core/widgets/app_toast.dart';
import 'package:moviroo_driver_app/core/notifications/notification_service.dart';
import 'ride_widgets.dart';
import '../../tracking/tracking_page.dart';
import '../../tracking/ride_model.dart' as tracking;

class OfferCard extends StatelessWidget {
  final OfferModel offer;
  const OfferCard({super.key, required this.offer});

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
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
              child: Builder(
                builder: (_) {
                  final dt = tryParseDateTime(ride.rideTime);
                  if (dt == null) {
                    return Row(
                      children: [
                        RideInfoChip(
                          icon: Icons.schedule_outlined,
                          label: ride.rideTime,
                        ),
                        if ((ride.distanceKm ?? 0) > 0) ...[
                          const SizedBox(width: 14),
                          RideInfoChip(
                            icon: Icons.route_rounded,
                            label: '${ride.distanceKm!.toStringAsFixed(1)} km',
                          ),
                        ],
                      ],
                    );
                  }
                  return Row(
                    children: [
                      RideInfoChip(
                        icon: Icons.calendar_today_outlined,
                        label: formatRideDate(dt),
                      ),
                      const SizedBox(width: 14),
                      RideInfoChip(
                        icon: Icons.access_time_outlined,
                        label: formatRideTime(dt),
                      ),
                      if ((ride.distanceKm ?? 0) > 0) ...[
                        const SizedBox(width: 14),
                        RideInfoChip(
                          icon: Icons.route_rounded,
                          label: '${ride.distanceKm!.toStringAsFixed(1)} km',
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),

          // ── Route timeline ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
            child: RideRouteTimeline(
              from: ride.from,
              to: ride.to,
              textStyle: AppTextStyles.bodySmall(context),
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
                      // Capture context-dependent refs BEFORE the await: the widget
                      // is removed from the tree once the offer is removed from the
                      // list, so context.mounted will be false by then.
                      final messenger = ScaffoldMessenger.of(context);
                      final rideProvider = context.read<RideProvider>();
                      final onlineProvider = context.read<OnlineProvider>();
                      final rejectedText = AppLocalizations.of(context)
                          .translate('ride_rejected_snack')
                          .replaceFirst('{id}', '');

                      final ok = await rideProvider.rejectOffer(offer.id);
                      if (ok) {
                        AppToast.infoMessenger(messenger, rejectedText);
                        NotificationService.instance.showLocalNotification(
                          title: 'Offer Rejected',
                          body: 'You have rejected this ride offer.',
                        );
                        onlineProvider.refreshDriverProfile();
                      } else {
                        AppToast.errorMessenger(
                          messenger,
                          rideProvider.error ?? 'Error',
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(t('ride_action_reject')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Capture context-dependent refs BEFORE the await.
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);
                      final rideProvider = context.read<RideProvider>();
                      final onlineProvider = context.read<OnlineProvider>();
                      final acceptedText = AppLocalizations.of(context)
                          .translate('ride_accepted_snack')
                          .replaceFirst('{id}', '');

                      final ok = await rideProvider.acceptOffer(offer.id);
                      if (ok) {
                        final rideData = offer.ride;
                        final initial =
                            (rideData.passengerName ?? '').trim().isNotEmpty
                            ? rideData.passengerName!.trim()[0].toUpperCase()
                            : '?';

                        // Map backend status to tracking RideStatus enum
                        tracking.RideStatus mapStatus(String status) {
                          switch (status.toUpperCase()) {
                            case 'ASSIGNED':
                              return tracking.RideStatus.assigned;
                            case 'EN_ROUTE_TO_PICKUP':
                              return tracking.RideStatus.onTheWay;
                            case 'ARRIVED':
                              return tracking.RideStatus.arrived;
                            case 'IN_TRIP':
                              return tracking.RideStatus.startRide;
                            case 'COMPLETED':
                              return tracking.RideStatus.completed;
                            default:
                              return tracking.RideStatus.assigned;
                          }
                        }

                        final trackRide = tracking.RideModel(
                          id: offer.rideId,
                          passenger: tracking.PassengerModel(
                            name: rideData.passengerName ?? 'Passenger',
                            rating: 4.8,
                            avatarInitial: initial,
                            phone: rideData.passengerPhone,
                          ),
                          pickupAddress: rideData.from,
                          dropOffAddress: rideData.to,
                          distanceKm: rideData.distanceKm ?? 0,
                          etaMinutes: 0,
                          earningsAmount: rideData.price,
                          currency: 'TND',
                          pickupLat: rideData.pickupLat,
                          pickupLon: rideData.pickupLon,
                          dropoffLat: rideData.dropoffLat,
                          dropoffLon: rideData.dropoffLon,
                          status: mapStatus(rideData.status),
                        );
                        AppToast.successMessenger(messenger, acceptedText);
                        NotificationService.instance.showLocalNotification(
                          title: 'Ride Accepted',
                          body:
                              'You are on the way to pick up ${rideData.passengerName ?? 'the passenger'}.',
                        );
                        onlineProvider.refreshDriverProfile();
                        navigator.push(TrackPassengerPage.route(trackRide));
                      } else {
                        AppToast.errorMessenger(
                          messenger,
                          rideProvider.error ?? 'Error',
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(t('ride_action_accept')),
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
