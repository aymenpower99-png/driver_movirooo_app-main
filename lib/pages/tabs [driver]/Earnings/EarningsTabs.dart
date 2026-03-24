// _EarningsTabs.dart
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_colors.dart';

class EarningsTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const EarningsTabs({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  static const List<String> _tabs = ['Weekly', 'Monthly', 'All-Time'];

  List<String> _tabLabels(BuildContext context) {
    final t = AppLocalizations.of(context).translate;
    return [
      t('earnings_tab_weekly'),
      t('earnings_tab_monthly'),
      t('earnings_tab_all_time'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border(context), width: 1),
        ),
      ),
      child: Row(
        children: List.generate(_tabLabels(context).length, (i) {
          final isSelected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      _tabLabels(context)[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primaryPurple
                            : AppColors.subtext(context),
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  // ── Underline indicator ──────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2.5,
                    width: isSelected ? 60.0 : 0.0,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple,
                      borderRadius: BorderRadius.circular(2),
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
