import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_text_styles.dart';
import '../../../../../l10n/app_localizations.dart';
import '../models/help_category.dart';

class CategoryChipRow extends StatelessWidget {
  final List<HelpCategory> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  const CategoryChipRow({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          // "All" chip
          _CategoryChip(
            label: AppLocalizations.of(context).translate('category_all'),
            icon: Icons.apps_rounded,
            isSelected: selectedId == null,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: 8),
          ...categories.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _CategoryChip(
                label: cat.title,
                icon: cat.icon,
                isSelected: selectedId == cat.id,
                onTap: () => onSelected(selectedId == cat.id ? null : cat.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPurple
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryPurple
                : AppColors.border(context),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppColors.subtext(context),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.settingsItem(context).copyWith(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : AppColors.text(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
