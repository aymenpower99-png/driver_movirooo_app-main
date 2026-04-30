// lib/pages/tracking/completion/widgets/full_route.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/pages/tracking/ride_model.dart';
import 'dashed_line_painter.dart';

class FullRoute extends StatelessWidget {
  final RideModel ride;
  final Color cardColor;
  const FullRoute({required this.ride, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: AppColors.primaryPurple,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(
                width: 11,
                height: 26,
                child: CustomPaint(painter: DashedLinePainter()),
              ),
              Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryPurple, width: 2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 11,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      ride.pickupAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text(context),
                        height: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  height: 11,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      ride.dropOffAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text(context),
                        height: 1,
                      ),
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
