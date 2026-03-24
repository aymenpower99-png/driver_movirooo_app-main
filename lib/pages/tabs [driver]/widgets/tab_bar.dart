import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/routing/router.dart';
import '../../../../theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class DriverTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const DriverTabBar({super.key, required this.currentIndex, this.onTap});

  static const _routes = [
    AppRouter.driverDashboard,
    AppRouter.driverEarningsPage,
    AppRouter.driverRides,
    AppRouter.driverProfile,
  ];

  List<String> _labels(BuildContext context) {
    final t = AppLocalizations.of(context).translate;
    return [
      t('driver_tab_stats'),
      t('driver_tab_earnings'),
      t('driver_tab_activities'),
      t('driver_tab_profile'),
    ];
  }

  void _handleTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    onTap?.call(index);
    Navigator.pushReplacementNamed(context, _routes[index]);
  }

  IconData _icon(int index, bool active) {
    switch (index) {
      case 0:
        return active
            ? Icons.power_settings_new_rounded
            : Icons.power_settings_new_outlined;
      case 1:
        return active
            ? Icons.account_balance_wallet_rounded
            : Icons.account_balance_wallet_outlined;
      case 2:
        return active ? Icons.description_rounded : Icons.description_outlined;
      case 3:
        return active ? Icons.person_rounded : Icons.person_outline_rounded;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use card colors from AppTheme
    final bgColor = isDark ? AppTheme.darkSurface : Colors.white;
    final topBorder = isDark ? AppTheme.darkBorder : const Color(0xFFE0E0E8);

    const activeColor = Color(0xFF7C3AED);
    final unselectedColor = isDark
        ? const Color(0xFF6B6B75)
        : const Color(0xFF9B9BAA);

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: topBorder, width: 1)),
      ),
      child: Row(
        children: List.generate(_labels(context).length, (i) {
          final selected = i == currentIndex;
          final color = selected ? activeColor : unselectedColor;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _handleTap(context, i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_icon(i, selected), size: 24, color: color),
                  const SizedBox(height: 4),
                  Text(
                    _labels(context)[i],
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
