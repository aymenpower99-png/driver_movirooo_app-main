import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/routing/router.dart';

class DriverTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const DriverTabBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  static const _labels = ['Stats', 'Earnings', 'Activities', 'Profile'];

  static const _routes = [
    AppRouter.driverDashboard,
    AppRouter.driverEarningsPage,
    AppRouter.driverRides,
    AppRouter.driverProfile,
  ];

  void _handleTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    onTap?.call(index);
    Navigator.pushReplacementNamed(context, _routes[index]);
  }

  IconData _icon(int index, bool active) {
    switch (index) {
      case 0:
        return active ? Icons.power_settings_new_rounded : Icons.power_settings_new_outlined;
      case 1:
        return active ? Icons.account_balance_wallet_rounded : Icons.account_balance_wallet_outlined;
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
    final bgColor = isDark ? const Color(0xFF0F0F12) : Colors.white;
    final topBorder = isDark ? const Color(0xFF1E1E24) : const Color(0xFFE0E0E8);
    const activeColor = Color(0xFF7C3AED);
    final unselectedColor = isDark ? const Color(0xFF6B6B75) : const Color(0xFF9B9BAA);

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: topBorder, width: 1)),
      ),
      child: Row(
        children: List.generate(_labels.length, (i) {
          final selected = i == currentIndex;
          final color = selected ? activeColor : unselectedColor;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _handleTap(context, i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _icon(i, selected),
                    size: 24,
                    color: color,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _labels[i],
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