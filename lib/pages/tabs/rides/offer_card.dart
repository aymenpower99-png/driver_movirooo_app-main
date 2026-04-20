import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_text_styles.dart';
import '../../../providers/ride_provider.dart';
import '../../../core/models/offer_model.dart';
import '../../../core/widgets/app_toast.dart';
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
                      if (context.mounted) {
                        if (ok) {
                          AppToast.info(context, AppLocalizations.of(context).translate('ride_rejected_snack').replaceFirst('{id}', ''));
                        } else {
                          AppToast.error(context, context.read<RideProvider>().error ?? 'Error');
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(t('ride_action_reject')),
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
                          AppToast.success(context, AppLocalizations.of(context).translate('ride_accepted_snack').replaceFirst('{id}', ''));
                          Navigator.of(context).push(TrackPassengerPage.route(trackRide));
                        } else {
                          AppToast.error(context, context.read<RideProvider>().error ?? 'Error');
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
