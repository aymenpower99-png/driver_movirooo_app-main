import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import 'dashboard_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EARNINGS BANNER
// ─────────────────────────────────────────────────────────────────────────────
class EarningsBanner extends StatelessWidget {
  const EarningsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Earnings",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'DT 84.50',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up_rounded,
                          size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '+12% vs yesterday',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: Colors.white.withValues(alpha: 0.2),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _MiniStat(icon: Icons.route_rounded, label: '127 km', sublabel: 'Distance'),
              const SizedBox(height: 12),
              _MiniStat(icon: Icons.receipt_long_rounded, label: '7 trips', sublabel: 'Today'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  const _MiniStat({required this.icon, required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.75)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            Text(sublabel,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.65))),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ONLINE CARD
// ─────────────────────────────────────────────────────────────────────────────
class OnlineCard extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onToggle;
  final bool isDark;

  const OnlineCard({
    super.key,
    required this.isOnline,
    required this.onToggle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOnline
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.border(context),
        ),
        boxShadow: [
          BoxShadow(
            color: (isOnline ? AppColors.success : Colors.black)
                .withValues(alpha: isDark ? 0.2 : isOnline ? 0.08 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isOnline
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.iconBg(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                    key: ValueKey(isOnline),
                    color: isOnline ? AppColors.success : AppColors.primaryPurple,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        isOnline ? 'You are Online' : 'You are Offline',
                        key: ValueKey('title_$isOnline'),
                        style: AppTextStyles.bodyLarge(context)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Row(
                        key: ValueKey('sub_$isOnline'),
                        children: [
                          PulsingDot(isOnline: isOnline),
                          const SizedBox(width: 6),
                          Text(
                            isOnline
                                ? 'Waiting for requests...'
                                : 'Go online to receive trips',
                            style: AppTextStyles.bodySmall(context).copyWith(
                              color: isOnline
                                  ? AppColors.success
                                  : AppColors.subtext(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: isOnline
                    ? LinearGradient(
                        colors: [AppColors.error, AppColors.error.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : AppColors.purpleGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: (isOnline ? AppColors.error : AppColors.primaryPurple)
                        .withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      isOnline ? Icons.pause_rounded : Icons.power_settings_new_rounded,
                      key: ValueKey('icon_$isOnline'),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      isOnline ? 'Go Offline' : 'Go Online',
                      key: ValueKey('text_$isOnline'),
                      style: AppTextStyles.buttonPrimary.copyWith(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            child: isOnline
                ? const Padding(
                    padding: EdgeInsets.only(top: 14),
                    child: DotsLoader(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TRIP OVERVIEW CARD
// ─────────────────────────────────────────────────────────────────────────────
class TripOverviewCard extends StatelessWidget {
  final bool isDark;
  const TripOverviewCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.iconBg(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    color: AppColors.primaryPurple, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trip Overview',
                      style: AppTextStyles.bodyLarge(context)
                          .copyWith(fontWeight: FontWeight.bold)),
                  Text('Your activity at a glance',
                      style: AppTextStyles.bodySmall(context)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.iconBg(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Text(
                  'All Time',
                  style: AppTextStyles.bodySmall(context).copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.directions_car_rounded,
                  iconColor: AppColors.primaryPurple,
                  bgColor: AppColors.iconBg(context),
                  value: '1,248',
                  label: 'Total Trips',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  icon: Icons.check_circle_rounded,
                  iconColor: AppColors.success,
                  bgColor: AppColors.success.withValues(alpha: 0.1),
                  value: '1,180',
                  label: 'Accepted',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.cancel_rounded,
                  iconColor: AppColors.error,
                  bgColor: AppColors.error.withValues(alpha: 0.1),
                  value: '68',
                  label: 'Cancelled',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  icon: Icons.timer_outlined,
                  iconColor: AppColors.warning,
                  bgColor: AppColors.warning.withValues(alpha: 0.1),
                  value: '6.5h',
                  label: 'Online Time',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          const _AcceptanceRateBar(accepted: 1180, total: 1248),
        ],
      ),
    );
  }
}

// ── Stat Tile ────────────────────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: AppTextStyles.profileStatValue(context)
                        .copyWith(fontSize: 15),
                    overflow: TextOverflow.ellipsis),
                Text(label,
                    style: AppTextStyles.bodySmall(context),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Acceptance Rate Bar ───────────────────────────────────────────────────────
class _AcceptanceRateBar extends StatelessWidget {
  final int accepted;
  final int total;
  const _AcceptanceRateBar({required this.accepted, required this.total});

  Color _rateColor(double rate) {
    if (rate >= 0.9) return AppColors.success;
    if (rate >= 0.7) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final rate = accepted / total;
    final pct = (rate * 100).toStringAsFixed(0);
    final color = _rateColor(rate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.verified_rounded, size: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  'Acceptance Rate',
                  style: AppTextStyles.bodySmall(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text(context),
                  ),
                ),
              ],
            ),
            Text(
              '$pct%',
              style: AppTextStyles.priceMedium(context).copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: rate,
            minHeight: 8,
            backgroundColor: AppColors.border(context),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$accepted of $total trips accepted',
          style: AppTextStyles.bodySmall(context).copyWith(fontSize: 11),
        ),
      ],
    );
  }
}