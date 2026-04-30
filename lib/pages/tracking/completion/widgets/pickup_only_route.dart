// lib/pages/tracking/completion/widgets/pickup_only_route.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/pages/tracking/ride_model.dart';

class PickupOnlyRoute extends StatelessWidget {
  final RideModel ride;
  const PickupOnlyRoute({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 11,
            height: 11,
            margin: const EdgeInsets.only(top: 1),
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ride.pickupAddress,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.text(context),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
