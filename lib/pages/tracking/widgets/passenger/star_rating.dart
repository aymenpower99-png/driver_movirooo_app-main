// lib/pages/tracking/widgets/passenger/star_rating.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';

class StarRating extends StatelessWidget {
  final double? rating;
  const StarRating({this.rating});

  @override
  Widget build(BuildContext context) {
    // Default to 5.0 for unrated passengers (null or 0).
    // Show actual rating only when it is > 0.
    final effectiveRating = (rating != null && rating! > 0) ? rating! : 5.0;
    final full = effectiveRating.floor();
    final half = (effectiveRating - full) >= 0.5;
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
          effectiveRating.toStringAsFixed(1),
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
