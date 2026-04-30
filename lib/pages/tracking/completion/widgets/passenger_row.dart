// lib/pages/tracking/completion/widgets/passenger_row.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/pages/tracking/ride_model.dart';
import 'package:moviroo_driver_app/pages/tracking/widgets/passenger/passenger_avatar.dart';

class PassengerRow extends StatelessWidget {
  final RideModel ride;
  final Color cardColor;
  const PassengerRow({required this.ride, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            height: 38,
            child: PassengerAvatar(passenger: ride.passenger),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ride.passenger.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text(context),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: Color(0xFFFFC107),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      ride.passenger.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.subtext(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
