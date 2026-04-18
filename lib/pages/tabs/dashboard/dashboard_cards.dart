import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// POWER SECTION
// ─────────────────────────────────────────────────────────────────────────────
class PowerSection extends StatefulWidget {
  final bool isOnline;
  final Animation<double> bounceScale;
  final VoidCallback onToggle;

  const PowerSection({
    super.key,
    required this.isOnline,
    required this.bounceScale,
    required this.onToggle,
  });

  @override
  State<PowerSection> createState() => _PowerSectionState();
}

class _PowerSectionState extends State<PowerSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  static const Color _offlineColor = Color(0xFFB0B7C3);

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseScale = Tween<double>(
      begin: 1.0,
      end: 1.35,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));
    _pulseOpacity = Tween<double>(
      begin: 0.45,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));

    if (widget.isOnline) _pulseCtrl.repeat();
  }

  @override
  void didUpdateWidget(PowerSection old) {
    super.didUpdateWidget(old);
    if (widget.isOnline && !old.isOnline) {
      _pulseCtrl.repeat();
    } else if (!widget.isOnline && old.isOnline) {
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.isOnline ? AppColors.success : _offlineColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: widget.onToggle,
          child: ScaleTransition(
            scale: widget.bounceScale,
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.isOnline)
                    AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (_, _) => Transform.scale(
                        scale: _pulseScale.value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.success.withValues(
                              alpha: _pulseOpacity.value,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (widget.isOnline)
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success.withValues(alpha: 0.13),
                      ),
                    ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeInOut,
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeColor,
                      boxShadow: widget.isOnline
                          ? [
                              BoxShadow(
                                color: AppColors.success.withValues(
                                  alpha: 0.38,
                                ),
                                blurRadius: 28,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : [],
                    ),
                    child: const Icon(
                      Icons.power_settings_new_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 22),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                  ),
              child: child,
            ),
          ),
          child: Text(
            widget.isOnline
                ? AppLocalizations.of(
                    context,
                  ).translate('dashboard_you_are_online')
                : AppLocalizations.of(
                    context,
                  ).translate('dashboard_you_are_offline'),
            key: ValueKey(widget.isOnline),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.text(context),
            ),
          ),
        ),

        const SizedBox(height: 6),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: Text(
            widget.isOnline
                ? AppLocalizations.of(
                    context,
                  ).translate('dashboard_available_for_rides')
                : AppLocalizations.of(
                    context,
                  ).translate('dashboard_tap_to_go_online'),
            key: ValueKey('sub_${widget.isOnline}'),
            style: TextStyle(fontSize: 13, color: AppColors.subtext(context)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DRIVER STATUS ROW  —  rating · streak · level
// (replaces the 3 stat tiles — no overlap with activity card or earnings page)
// ─────────────────────────────────────────────────────────────────────────────
class DriverStatusRow extends StatelessWidget {
  // Replace with real model values
  final double rating;
  final int streakDays;
  final String level;

  const DriverStatusRow({
    super.key,
    this.rating = 4.8,
    this.streakDays = 6,
    this.level = 'Gold',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Rating
        Expanded(
          child: _StatusTile(
            topWidget: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 15,
                  color: Color(0xFFFFC107),
                ),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text(context),
                  ),
                ),
              ],
            ),
            label: AppLocalizations.of(
              context,
            ).translate('dashboard_your_rating'),
          ),
        ),
        const SizedBox(width: 10),
        // Streak
        Expanded(
          child: _StatusTile(
            topWidget: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 4),
                Text(
                  '${streakDays}d',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text(context),
                  ),
                ),
              ],
            ),
            label: AppLocalizations.of(context).translate('dashboard_streak'),
          ),
        ),
        const SizedBox(width: 10),
        // Level
        Expanded(
          child: _StatusTile(
            topWidget: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  size: 15,
                  color: level == 'Gold'
                      ? const Color(0xFFFFB300)
                      : level == 'Silver'
                      ? const Color(0xFF9E9E9E)
                      : AppColors.primaryPurple,
                ),
                const SizedBox(width: 4),
                Text(
                  level,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text(context),
                  ),
                ),
              ],
            ),
            label: AppLocalizations.of(
              context,
            ).translate('dashboard_driver_level'),
          ),
        ),
      ],
    );
  }
}

class _StatusTile extends StatelessWidget {
  final Widget topWidget;
  final String label;
  const _StatusTile({required this.topWidget, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          topWidget,
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: AppColors.subtext(context)),
          ),
        ],
      ),
    );
  }
}

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
