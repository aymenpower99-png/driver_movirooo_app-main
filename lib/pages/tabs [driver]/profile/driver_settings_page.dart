import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:moviroo_driver_app/pages/contact_support/contact_support_page.dart';
import 'package:moviroo_driver_app/pages/help_center/help_center_page.dart';

class DriverSettingsPage extends StatelessWidget {
  const DriverSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).translate;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.text(context),
                size: 18,
              ),
            ),
          ),
        ),
        title: Text(
          t('settings_title'),
          style: AppTextStyles.pageTitle(context),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // ── PRIVACY & SECURITY ───────────────────────────────────
          _SectionHeader(label: t('settings_privacy_section')),

          _TapRow(
            label: t('change_password'),
            onTap: () => Navigator.pushNamed(context, '/driver/password-reset'),
          ),
          _RowDivider(),
          _TapRow(
            label: t('settings_work_area'),
            onTap: () => Navigator.pushNamed(context, '/driver/work-area'),
          ),

          const SizedBox(height: 28),

          // ── SUPPORT ──────────────────────────────────────────────────────
          _SectionHeader(label: t('settings_support_section')),

          _TapRow(
            label: t('settings_help_center'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpCenterPage()),
            ),
          ),
          _RowDivider(),

          _TapRow(
            label: t('settings_contact_support'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContactSupportPage()),
            ),
          ),
          _RowDivider(),

          _TapRow(
            label: t('settings_my_tickets'),
            onTap: () => Navigator.pushNamed(context, '/driver/my-tickets'),
          ),

          const SizedBox(height: 28),

          // ── ABOUT ────────────────────────────────────────────────
          _SectionHeader(label: t('settings_about_section')),

          _TapRow(
            label: t('settings_app_version'),
            onTap: () => Navigator.pushNamed(context, '/app-version'),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 16, bottom: 4),
    child: Text(label, style: AppTextStyles.sectionLabel(context)),
  );
}

// ── Thin divider ──────────────────────────────────────────────────────────────

class _RowDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    thickness: 0.8,
    indent: 16,
    endIndent: 16,
    color: AppColors.border(context),
  );
}

// ── Tap Row ───────────────────────────────────────────────────────────────────

class _TapRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TapRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: AppTextStyles.settingsItem(context)),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: AppColors.subtext(context),
            ),
          ],
        ),
      ),
    );
  }
}

