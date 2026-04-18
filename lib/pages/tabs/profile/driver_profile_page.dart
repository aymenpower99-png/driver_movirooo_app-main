import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/routing/router.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../main.dart' show localeProvider, themeProvider;
import '../../../../providers/auth_provider.dart';
import '../../../../providers/online_provider.dart';
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
    final t      = AppLocalizations.of(context).translate;
    final auth   = context.watch<AuthProvider>();
    final online = context.watch<OnlineProvider>();
    final user   = auth.user;
    final driver = online.driverProfile;

    final displayName = user != null
        ? '${user.firstName} ${user.lastName}'.trim()
        : 'Driver';
    final initials    = user?.initials ?? '?';
    final rating      = driver?.ratingAverage ?? 0.0;
    final totalTrips  = driver?.totalTrips ?? 0;
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
              child: Text(
                t('profile'),
                style: AppTextStyles.pageTitle(context),
              ),
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
                      color: Colors.black.withValues(alpha: 0.06),
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
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: AppColors.primaryPurple.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
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
                                  displayName,
                                  style: AppTextStyles.pageTitle(
                                    context,
                                  ).copyWith(fontSize: 17),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      rating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.text(context),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '($totalTrips ${t('profile_rides')})',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.subtext(context),
                                      ),
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
                                builder: (_) => const DriverProfileEditPage(),
                              ),
                            ),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple.withValues(alpha:
                                  0.08,
                                ),
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
            _SectionHeader(label: t('profile_section_personal')),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SoloCard(
                icon: Icons.manage_accounts_outlined,
                label: t('account_tile'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DriverProfileEditPage(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── PREFERENCES ──────────────────────────────────────
            _SectionHeader(label: t('profile_section_preferences')),
            const SizedBox(height: 8),
            ListenableBuilder(
              listenable: themeProvider,
              builder: (context, _) {
                final themeLabel = switch (themeProvider.mode) {
                  ThemeMode.dark => t('dark'),
                  ThemeMode.light => t('light'),
                  ThemeMode.system => t('system'),
                };
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SoloCard(
                    icon: Icons.palette_outlined,
                    label: t('profile_appearance'),
                    subtitle: themeLabel,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DriverAppearancePage(),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ListenableBuilder(
              listenable: localeProvider,
              builder: (context, _) {
                final code = localeProvider.locale.languageCode;
                final langName = t(
                  code == 'fr'
                      ? 'french'
                      : code == 'ar'
                      ? 'arabic'
                      : 'english',
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SoloCard(
                    icon: Icons.language_rounded,
                    label: t('profile_language'),
                    subtitle: langName,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DriverLanguagePage(),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // ── SETTINGS ─────────────────────────────────────────
            _SectionHeader(label: t('profile_section_settings')),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SoloCard(
                icon: Icons.notifications_outlined,
                label: t('push_notification_tile'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DriverNotificationsPage(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SoloCard(
                icon: Icons.settings_outlined,
                label: t('settings_title'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DriverSettingsPage()),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── Logout ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SoloCard(
                icon: Icons.logout_rounded,
                label: t('profile_logout'),
                iconColor: Colors.red,
                labelColor: Colors.red,
                onTap: () async {
                  final onlineProv = context.read<OnlineProvider>();
                  if (onlineProv.isOnline) await onlineProv.toggleOnline();
                  if (!context.mounted) return;
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    AppRouter.clearAndGo(context, AppRouter.driverLogin);
                  }
                },
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
  final String? subtitle;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback onTap;

  const _SoloCard({
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


