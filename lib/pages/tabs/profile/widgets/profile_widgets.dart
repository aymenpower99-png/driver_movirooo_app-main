import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_text_styles.dart';

// ── Solo Card ─────────────────────────────────────────────────────────────────

class ProfileSoloCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback onTap;

  const ProfileSoloCard({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.iconColor,
    this.labelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border(context)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppColors.primaryPurple, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.settingsItem(
                      context,
                    ).copyWith(color: labelColor),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.subtext(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: labelColor ?? AppColors.subtext(context),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class ProfileSectionHeader extends StatelessWidget {
  final String label;
  const ProfileSectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(label, style: AppTextStyles.sectionLabel(context)),
    );
  }
}
