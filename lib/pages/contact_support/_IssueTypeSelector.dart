import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class _IssueOption {
  final String label;
  final IconData icon;
  const _IssueOption({required this.label, required this.icon});
}

const List<_IssueOption> _issues = [
  _IssueOption(label: 'Login Issue',  icon: Icons.login_rounded),
  _IssueOption(label: 'Ride Issue',   icon: Icons.directions_car_outlined),
  _IssueOption(label: 'Other',        icon: Icons.help_outline_rounded),
];

class IssueTypeSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const IssueTypeSelector({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_issues.length, (i) {
        final selected = i == selectedIndex;
        final item = _issues[i];

        return GestureDetector(
          onTap: () => onSelect(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primaryPurple.withOpacity(0.08)
                  : AppColors.surface(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? AppColors.primaryPurple
                    : AppColors.border(context),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: selected
                      ? AppColors.primaryPurple
                      : AppColors.subtext(context),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? AppColors.primaryPurple
                          : AppColors.text(context),
                    ),
                  ),
                ),
                // Radio indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryPurple
                          : AppColors.border(context),
                      width: 2,
                    ),
                    color: selected
                        ? AppColors.primaryPurple
                        : Colors.transparent,
                  ),
                  child: selected
                      ? const Icon(Icons.circle,
                          color: Colors.white, size: 10)
                      : null,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
