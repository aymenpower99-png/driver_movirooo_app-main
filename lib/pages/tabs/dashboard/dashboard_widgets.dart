import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD HEADER  —  logo + online/offline badge
// ─────────────────────────────────────────────────────────────────────────────
class DashboardHeader extends StatelessWidget {
  final bool isOnline;
  const DashboardHeader({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Image.asset(
          isDark
              ? 'images/moviroo dark mode.png'
              : 'images/moviroo light mode.png',
          height: 28,
          fit: BoxFit.contain,
        ),
        const Spacer(),
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isOnline
                ? AppColors.success.withValues(alpha: 0.12)
                : const Color(0xFF9AA3AD).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isOnline ? AppColors.success : const Color(0xFF9AA3AD),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline ? AppColors.success : const Color(0xFF9AA3AD),
                ),
              ),
              const SizedBox(width: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  isOnline
                      ? AppLocalizations.of(context).translate('status_online')
                      : AppLocalizations.of(
                          context,
                        ).translate('status_offline'),
                  key: ValueKey(isOnline),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isOnline
                        ? AppColors.success
                        : const Color(0xFF9AA3AD),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
