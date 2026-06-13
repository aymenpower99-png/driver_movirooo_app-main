// lib/pages/tracking/completion/widgets/meta_footer.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/pages/tracking/ride_model.dart';
import 'package:moviroo_driver_app/l10n/app_localizations.dart';
import 'meta_cell.dart';

class MetaFooter extends StatelessWidget {
  final RideModel ride;
  final Color borderColor;
  const MetaFooter({super.key, required this.ride, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    // For completed rides show the ACTUAL distance/duration computed by the
    // backend from GPS waypoints + timestamps.  Fallback to the original
    // booking estimate only when real values are missing.
    final durationValue = _formatDuration(context, ride.durationMinReal);
    final distanceValue = ride.distanceKmReal != null && ride.distanceKmReal! > 0
        ? _formatDistance(ride.distanceKmReal!)
        : '${ride.distanceKm.toStringAsFixed(1)} km';

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: MetaCell(
              icon: Icons.schedule_outlined,
              value: durationValue,
              label: AppLocalizations.of(context).translate('completion_duration'),
            ),
          ),
          VerticalDivider(width: 1, thickness: 1, color: borderColor),
          Expanded(
            child: MetaCell(
              icon: Icons.route_outlined,
              value: distanceValue,
              label: AppLocalizations.of(context).translate('completion_distance'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(BuildContext context, double? minutes) {
    if (minutes == null || minutes <= 0) {
      return AppLocalizations.of(context).translate('duration_less_than_min');
    }
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = (minutes % 60).round();
      if (m > 0) return '${h}h ${m}min';
      return '${h}h';
    }
    if (minutes < 1) {
      final seconds = (minutes * 60).round();
      return '${seconds}s';
    }
    return '${minutes.round()} min';
  }

  String _formatDistance(double km) {
    if (km < 1) {
      final meters = (km * 1000).round();
      return '${meters} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }
}
