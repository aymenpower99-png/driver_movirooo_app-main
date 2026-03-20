// lib/pages/tabs/[driver]/Rides/tracking/widgets/passenger_info_card.dart
//
// Single flat card — no nested card, no copy address.
// Sections: header · route · contact buttons (conditional) · report/cancel

import 'package:flutter/material.dart';
import '../../../../../../theme/app_colors.dart';
import '../ride_model.dart';

class PassengerInfoCard extends StatelessWidget {
  final PassengerModel passenger;
  final String pickupAddress;
  final String dropOffAddress;
  final double distanceKm;
  final int etaMinutes;
  final bool showContactButtons;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;
  final VoidCallback? onReportIssue;
  final VoidCallback? onCancelRide;

  const PassengerInfoCard({
    super.key,
    required this.passenger,
    required this.pickupAddress,
    required this.dropOffAddress,
    required this.distanceKm,
    required this.etaMinutes,
    required this.showContactButtons,
    this.onCall,
    this.onMessage,
    this.onReportIssue,
    this.onCancelRide,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: avatar + name + rating + ETA ──────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _Avatar(passenger: passenger),
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
                          color: AppColors.text(context),
                        ),
                      ),
                      const SizedBox(height: 3),
                      _StarRating(rating: passenger.rating),
                    ],
                  ),
                ),
                // ETA + distance
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$etaMinutes',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                          const TextSpan(
                            text: ' min',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${distanceKm.toStringAsFixed(1)} km',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.subtext(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1, color: AppColors.border(context)),

          // ── Route ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                _RouteRow(
                  icon: Icons.circle,
                  iconColor: AppColors.success,
                  iconSize: 10,
                  label: 'PICKUP',
                  labelColor: AppColors.success,
                  address: pickupAddress,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5, top: 2, bottom: 2),
                  child: Container(
                      width: 1.5, height: 16,
                      color: AppColors.border(context)),
                ),
                _RouteRow(
                  icon: Icons.location_on_rounded,
                  iconColor: AppColors.error,
                  iconSize: 14,
                  label: 'DROP-OFF',
                  labelColor: AppColors.error,
                  address: dropOffAddress,
                ),
              ],
            ),
          ),

          // ── Call / Message (on the way onward) ─────────────────
          if (showContactButtons) ...[
            Divider(height: 1, color: AppColors.border(context)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: _ContactBtn(
                      icon: Icons.phone_rounded,
                      label: 'Call',
                      onTap: onCall ?? () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ContactBtn(
                      icon: Icons.chat_bubble_rounded,
                      label: 'Message',
                      onTap: onMessage ?? () {},
                    ),
                  ),
                ],
              ),
            ),
          ],

          Divider(height: 1, color: AppColors.border(context)),

          // ── Report Issue / Cancel Ride ──────────────────────────
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: onReportIssue,
                    icon: Icon(Icons.flag_outlined,
                        size: 14, color: AppColors.subtext(context)),
                    label: Text(
                      'Report Issue',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.subtext(context),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                    ),
                  ),
                ),
                VerticalDivider(
                    width: 1, color: AppColors.border(context)),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onCancelRide,
                    icon: const Icon(Icons.cancel_outlined,
                        size: 14, color: AppColors.error),
                    label: const Text(
                      'Cancel Ride',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.error,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final PassengerModel passenger;
  const _Avatar({required this.passenger});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: passenger.avatarUrl == null
            ? AppColors.purpleGradient
            : null,
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
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}

// ── Star rating ───────────────────────────────────────────────────────────────

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
          IconData ico;
          if (i < full)                     ico = Icons.star_rounded;
          else if (i == full && half)       ico = Icons.star_half_rounded;
          else                              ico = Icons.star_outline_rounded;
          return Icon(ico, size: 13, color: const Color(0xFFFFC107));
        }),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.subtext(context),
          ),
        ),
      ],
    );
  }
}

// ── Route row ─────────────────────────────────────────────────────────────────

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final String label;
  final Color labelColor;
  final String address;

  const _RouteRow({
    required this.icon,
    required this.iconColor,
    required this.iconSize,
    required this.label,
    required this.labelColor,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                address,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Contact button ────────────────────────────────────────────────────────────

class _ContactBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.iconBg(context),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: AppColors.primaryPurple),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}