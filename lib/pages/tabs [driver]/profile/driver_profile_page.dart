import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/routing/router.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../widgets/tab_bar.dart';
import 'edit_profile/driver_profile_edit_page.dart';
import 'notification/driver_notifications_page.dart';
import 'driver_settings_page.dart';
import 'preferences/driver_appearance_page.dart';
import 'preferences/driver_language_page.dart';

class DriverProfilePage extends StatelessWidget {
  const DriverProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      bottomNavigationBar: const DriverTabBar(currentIndex: 3),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ── Page Title ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text('Profile', style: AppTextStyles.pageTitle(context)),
            ),

            // ── Profile Hero Card ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border(context)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryPurple.withOpacity(0.1),
                                  border: Border.all(
                                    color: AppColors.primaryPurple.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: AppColors.primaryPurple,
                                    size: 32,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.surface(context),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Amadou Diallo',
                                  style: AppTextStyles.pageTitle(context)
                                      .copyWith(fontSize: 17),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    _Badge(
                                      label: 'Premium Driver',
                                      bgColor: AppColors.primaryPurple.withOpacity(0.1),
                                      textColor: AppColors.primaryPurple,
                                    ),
                                    const SizedBox(width: 6),
                                    _Badge(
                                      label: 'Online',
                                      bgColor: AppColors.success.withOpacity(0.12),
                                      textColor: AppColors.success,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const DriverProfileEditPage()),
                            ),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.edit_outlined,
                                color: AppColors.primaryPurple,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── PERSONAL DETAILS ─────────────────────────────────
            const _SectionHeader(label: 'PERSONAL DETAILS'),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SoloCard(
                icon: Icons.manage_accounts_outlined,
                label: 'Account',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DriverProfileEditPage())),
              ),
            ),

            const SizedBox(height: 10),

            // ── PREFERENCES ──────────────────────────────────────
            const _SectionHeader(label: 'PREFERENCES'),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SoloCard(
                icon: Icons.palette_outlined,
                label: 'Appearance',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DriverAppearancePage())),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SoloCard(
                icon: Icons.language_rounded,
                label: 'Language',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DriverLanguagePage())),
              ),
            ),

            const SizedBox(height: 10),

            // ── SETTINGS ─────────────────────────────────────────
            const _SectionHeader(label: 'SETTINGS'),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SoloCard(
                icon: Icons.notifications_outlined,
                label: 'Push Notification',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DriverNotificationsPage())),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SoloCard(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DriverSettingsPage())),
              ),
            ),

            const SizedBox(height: 10),

            // ── Logout ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SoloCard(
                icon: Icons.logout_rounded,
                label: 'Log Out',
                iconColor: Colors.red,
                labelColor: Colors.red,
                onTap: () => AppRouter.clearAndGo(context, AppRouter.driverLogin),
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

// ── Solo Card ─────────────────────────────────────────────────────────────────

class _SoloCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback onTap;

  const _SoloCard({
    required this.icon,
    required this.label,
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
        height: 64, // ← increased from 48
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
              child: Text(
                label,
                style: AppTextStyles.settingsItem(context)
                    .copyWith(color: labelColor),
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

// ── Badge ─────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _Badge({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(label, style: AppTextStyles.sectionLabel(context)),
    );
  }
}

// ── Stat Cell ─────────────────────────────────────────────────────────────────

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color accentColor;

  const _StatCell({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.profileStatValue(context)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.profileStatLabel(context)),
        ],
      ),
    );
  }
}

// ── Vertical Divider ──────────────────────────────────────────────────────────

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 44,
      color: AppColors.border(context),
    );
  }
}