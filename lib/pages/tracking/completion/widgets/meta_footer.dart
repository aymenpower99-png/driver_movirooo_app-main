// lib/pages/tracking/completion/widgets/meta_footer.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/pages/tracking/ride_model.dart';
import 'package:moviroo_driver_app/l10n/app_localizations.dart';
import 'meta_cell.dart';

class MetaFooter extends StatelessWidget {
  final RideModel ride;
  final Color borderColor;
  const MetaFooter({required this.ride, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: MetaCell(
              icon: Icons.schedule_outlined,
              value: '${ride.etaMinutes} min',
              label: AppLocalizations.of(context).translate('completion_duration'),
            ),
          ),
          VerticalDivider(width: 1, thickness: 1, color: borderColor),
          Expanded(
            child: MetaCell(
              icon: Icons.route_outlined,
              value: '${ride.distanceKm.toStringAsFixed(1)} km',
              label: AppLocalizations.of(context).translate('completion_distance'),
            ),
          ),
        ],
      ),
    );
  }
}
