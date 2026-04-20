import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVITY CARD  —  4 performance stats only, no demand/last ride/peak
// ─────────────────────────────────────────────────────────────────────────────
class ActivityCard extends StatelessWidget {
  final bool   isOnline;
  final String onlineTime;
  final String vehicleName;    // e.g. "Toyota Camry" or "—"
  final String vehicleClass;   // e.g. "Business" or "—"
  final int    acceptanceRate;
  final int    cancellations;

  const ActivityCard({
    super.key,
    required this.isOnline,
    this.vehicleName    = '—',
    this.vehicleClass   = '—',
    this.onlineTime     = '0m',
    this.acceptanceRate = 0,
    this.cancellations  = 0,
  });

  @override
  Widget build(BuildContext context) {
    const rateColor = AppColors.success; // always green
    const cancelColor = AppColors.error;  // always red

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                AppLocalizations.of(
                  context,
                ).translate('dashboard_today_activity'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.subtext(context),
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              if (!isOnline) ...[
                Icon(
                  Icons.wifi_off_rounded,
                  size: 13,
                  color: AppColors.subtext(context),
                ),
                const SizedBox(width: 4),
                Text(
                  AppLocalizations.of(context).translate('status_offline'),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.subtext(context),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 14),

          _ActivityRow(
            icon: Icons.directions_car_rounded,
            iconColor: AppColors.primaryPurple,
            label: AppLocalizations.of(context).translate('dashboard_vehicle'),
            value: vehicleName,
          ),
          const SizedBox(height: 10),
          _ActivityRow(
            icon: Icons.workspace_premium_rounded,
            iconColor: AppColors.primaryPurple,
            label: AppLocalizations.of(context).translate('dashboard_vehicle_class'),
            value: vehicleClass,
          ),
          const SizedBox(height: 10),
          _ActivityRow(
            icon: Icons.schedule_outlined,
            iconColor: AppColors.primaryPurple,
            label: AppLocalizations.of(
              context,
            ).translate('dashboard_online_time'),
            value: onlineTime,
          ),
          const SizedBox(height: 10),
          _ActivityRow(
            icon: Icons.verified_rounded,
            iconColor: rateColor,
            label: AppLocalizations.of(
              context,
            ).translate('dashboard_acceptance_rate'),
            value: '$acceptanceRate%',
            valueColor: rateColor,
          ),
          const SizedBox(height: 10),
          _ActivityRow(
            icon: Icons.cancel_outlined,
            iconColor: cancelColor,
            label: AppLocalizations.of(
              context,
            ).translate('dashboard_cancellations'),
            value: '$cancellations',
            valueColor: cancelColor,
          ),
        ],
      ),
    );
  }
}

// ── Single stat row inside ActivityCard ───────────────────────────────────────
class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;

  const _ActivityRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: AppColors.text(context)),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.text(context),
          ),
        ),
      ],
    );
  }
}
