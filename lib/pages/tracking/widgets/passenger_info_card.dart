// lib/pages/tracking/widgets/passenger_info_card.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/l10n/app_localizations.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/pages/tracking/ride_model.dart';
import 'package:moviroo_driver_app/pages/tracking/widgets/contact_buttons.dart';
import 'package:moviroo_driver_app/pages/tracking/widgets/ride_meta_row.dart';
import 'package:moviroo_driver_app/pages/tracking/widgets/report_issue_sheet.dart';

class PassengerInfoCard extends StatelessWidget {
  final PassengerModel passenger;
  final String pickupAddress;
  final String dropOffAddress;
  final double distanceKm;
  final int etaMinutes;
  final bool showContactButtons;
  final bool showMetaTile;
  final bool showActions;
  final String? rideId;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;
  final VoidCallback? onCancelRide;

  const PassengerInfoCard({
    super.key,
    required this.passenger,
    required this.pickupAddress,
    required this.dropOffAddress,
    required this.distanceKm,
    required this.etaMinutes,
    required this.showContactButtons,
    this.showMetaTile = false,
    this.showActions = true,
    this.rideId,
    this.onCall,
    this.onMessage,
    this.onCancelRide,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. PASSENGER HEADER ───────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Row(
            children: [
              _PassengerAvatar(passenger: passenger),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passenger.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.text(context),
                      ),
                    ),
                    const SizedBox(height: 3),
                    _StarRating(rating: passenger.rating),
                  ],
                ),
              ),
              ContactButtons(onCall: onCall, onMessage: onMessage),
            ],
          ),
        ),

        Divider(height: 1, color: AppColors.border(context)),

        // ── 2. ROUTE ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pickup
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(top: 3),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryPurple,
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          ).translate('tracking_pickup_label'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryPurple,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          pickupAddress,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showMetaTile) ...[
                    const SizedBox(width: 8),
                    RideMetaBadge(
                      icon: Icons.route_rounded,
                      value: '${distanceKm.toStringAsFixed(1)} km',
                    ),
                  ],
                ],
              ),

              // Connector
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Container(
                  width: 2,
                  height: 22,
                  color: AppColors.border(context),
                ),
              ),

              // Drop-off
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(top: 3),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          ).translate('tracking_dropoff_label'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryPurple,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          dropOffAddress,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showMetaTile) ...[
                    const SizedBox(width: 8),
                    RideMetaBadge(
                      icon: Icons.schedule_rounded,
                      value: '$etaMinutes min',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // ── 3. REPORT / CANCEL ────────────────────────────────────
        if (showActions) ...[
          Divider(height: 1, color: AppColors.border(context)),
          IntrinsicHeight(
            child: Row(
              children: [
                // Report Issue — navigates to full-screen page
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReportIssuePage(
                            passengerName: passenger.name,
                            rideId: rideId ?? '',
                            pickupAddress: pickupAddress,
                            dropOffAddress: dropOffAddress,
                            onSubmit: (issue, note, photos) {
                              debugPrint(
                                'Report: ${issue.label} | $note | ${photos.length} photo(s)',
                              );
                            },
                          ),
                        ),
                      );
                    },
                    icon: Image.asset(
                      'images/icons/warning.png',
                      width: 14,
                      height: 14,
                      color: isDark ? Colors.white : AppColors.subtext(context),
                    ),
                    label: Text(
                      AppLocalizations.of(
                        context,
                      ).translate('tracking_report_action'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.white
                            : AppColors.subtext(context),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),

                VerticalDivider(width: 1, color: AppColors.border(context)),

                // Cancel Ride
                Expanded(
                  child: TextButton.icon(
                    onPressed: onCancelRide,
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 14,
                      color: AppColors.error,
                    ),
                    label: Text(
                      AppLocalizations.of(
                        context,
                      ).translate('tracking_cancel_action'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.error,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _PassengerAvatar extends StatelessWidget {
  final PassengerModel passenger;
  const _PassengerAvatar({required this.passenger});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: passenger.avatarUrl == null ? AppColors.purpleGradient : null,
        image: passenger.avatarUrl != null
            ? DecorationImage(
                image: NetworkImage(passenger.avatarUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: passenger.avatarUrl == null
          ? Center(
              child: Text(
                passenger.avatarInitial,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}

// ── Star Rating ───────────────────────────────────────────────────────────────

class _StarRating extends StatelessWidget {
  final double rating;
  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;
    return Row(
      children: [
        ...List.generate(5, (i) {
          final IconData ico;
          if (i < full) {
            ico = Icons.star_rounded;
          } else if (i == full && half) {
            ico = Icons.star_half_rounded;
          } else {
            ico = Icons.star_outline_rounded;
          }
          return Icon(ico, size: 14, color: const Color(0xFFFFC107));
        }),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.subtext(context),
          ),
        ),
      ],
    );
  }
}
