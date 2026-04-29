// lib/pages/tracking/widgets/passenger/passenger_avatar.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/pages/tracking/ride_model.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';

class PassengerAvatar extends StatelessWidget {
  final PassengerModel passenger;
  const PassengerAvatar({required this.passenger});

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
