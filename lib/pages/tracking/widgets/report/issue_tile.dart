// lib/pages/tracking/widgets/report/issue_tile.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'ride_issue.dart';

class IssueTile extends StatelessWidget {
  final RideIssue issue;
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const IssueTile({
    required this.issue,
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryPurple.withValues(alpha: isDark ? 0.22 : 0.07)
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primaryPurple
                : AppColors.border(context),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              issue.icon,
              size: 20,
              color: selected
                  ? AppColors.primaryPurple
                  : AppColors.subtext(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? AppColors.text(context)
                      : AppColors.subtext(context),
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: selected
                  ? const Icon(
                      Icons.check_circle_rounded,
                      key: ValueKey('check'),
                      size: 18,
                      color: AppColors.primaryPurple,
                    )
                  : const SizedBox(key: ValueKey('empty'), width: 18),
            ),
          ],
        ),
      ),
    );
  }
}
