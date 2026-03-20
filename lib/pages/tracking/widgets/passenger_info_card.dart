// lib/pages/tabs/[driver]/Rides/tracking/widgets/passenger_info_card.dart
//
// Redesigned card matching the Figma reference:
// - Photo avatar (circle) with name + rating + ETA + distance
// - PICKUP / DROP-OFF labeled rows with icons
// - Call / Message / Copy buttons row
// - Bottom: Report Issue | Cancel Ride

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
  final VoidCallback? onCopyAddress;
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
    this.onCopyAddress,
    this.onReportIssue,
    this.onCancelRide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Passenger header ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                _PassengerAvatar(passenger: passenger),
                const SizedBox(width: 14),

                // Name + rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        passenger.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF141414),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _StarRating(rating: passenger.rating),
                    ],
                  ),
                ),

                // ETA + Distance
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$etaMinutes ',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                          const TextSpan(
                            text: 'MIN',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${distanceKm.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9AA3AD),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1, color: const Color(0xFFF1F3F5)),

          // ── Route ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              children: [
                _RouteRow(
                  dotColor: AppColors.success,
                  label: 'PICKUP',
                  address: pickupAddress,
                  isDot: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 9),
                  child: Container(
                    width: 1.5,
                    height: 20,
                    color: const Color(0xFFE5E7EB),
                  ),
                ),
                _RouteRow(
                  dotColor: AppColors.error,
                  label: 'DROP-OFF',
                  address: dropOffAddress,
                  isDot: false,
                ),
              ],
            ),
          ),

          // ── Copy address ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: GestureDetector(
              onTap: onCopyAddress,
              child: Row(
                children: [
                  Icon(Icons.copy_outlined,
                      size: 13, color: const Color(0xFF9AA3AD)),
                  const SizedBox(width: 6),
                  Text(
                    'Copy address',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9AA3AD),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Call / Message / Copy buttons ─────────────────────────
          if (showContactButtons) ...[
            Divider(height: 1, color: const Color(0xFFF1F3F5)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.phone_rounded,
                      label: 'Call',
                      color: AppColors.primaryPurple,
                      onTap: onCall ?? () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.chat_bubble_rounded,
                      label: 'Message',
                      color: AppColors.primaryPurple,
                      onTap: onMessage ?? () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.copy_rounded,
                      label: 'Copy',
                      color: AppColors.primaryPurple,
                      onTap: onCopyAddress ?? () {},
                    ),
                  ),
                ],
              ),
            ),
          ],

          Divider(height: 1, color: const Color(0xFFF1F3F5)),

          // ── Report Issue / Cancel Ride ────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: onReportIssue,
                    icon: const Icon(Icons.flag_outlined,
                        size: 15, color: Color(0xFF9AA3AD)),
                    label: const Text(
                      'Report Issue',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9AA3AD),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                Container(width: 1, height: 28, color: const Color(0xFFE5E7EB)),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onCancelRide,
                    icon: const Icon(Icons.cancel_outlined,
                        size: 15, color: Color(0xFFFF3B30)),
                    label: const Text(
                      'Cancel Ride',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFF3B30),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
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

// ── Passenger Avatar ──────────────────────────────────────────────────────────

class _PassengerAvatar extends StatelessWidget {
  final PassengerModel passenger;
  const _PassengerAvatar({required this.passenger});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
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
                  fontSize: 22,
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
          IconData icon;
          if (i < full) {
            icon = Icons.star_rounded;
          } else if (i == full && half) {
            icon = Icons.star_half_rounded;
          } else {
            icon = Icons.star_outline_rounded;
          }
          return Icon(icon, size: 15, color: const Color(0xFFFFC107));
        }),
        const SizedBox(width: 5),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9AA3AD),
          ),
        ),
      ],
    );
  }
}

// ── Route Row ─────────────────────────────────────────────────────────────────

class _RouteRow extends StatelessWidget {
  final Color dotColor;
  final String label;
  final String address;
  final bool isDot;

  const _RouteRow({
    required this.dotColor,
    required this.label,
    required this.address,
    required this.isDot,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: isDot
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: dotColor.withOpacity(0.35), blurRadius: 4)
                    ],
                  ),
                )
              : Icon(Icons.location_on_rounded, size: 14, color: dotColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: dotColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF141414),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Action Button (Call / Message / Copy) ─────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}