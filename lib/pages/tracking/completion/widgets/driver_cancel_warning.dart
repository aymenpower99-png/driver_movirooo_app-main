// lib/pages/tracking/completion/widgets/driver_cancel_warning.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/l10n/app_localizations.dart';

/// Amber warning banner shown when the **driver** cancels a ride.
/// Warns that repeated cancellations may affect their account.
class DriverCancelWarning extends StatelessWidget {
  const DriverCancelWarning({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF2A2310) : const Color(0xFFFFFBEB);
    final border = isDark ? const Color(0xFF3D3010) : const Color(0xFFFDE68A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Color(0xFFD97706),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(
                context,
              ).translate('cancellation_driver_warning'),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFD97706),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}