import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class DriverSettingsPage extends StatefulWidget {
  const DriverSettingsPage({super.key});

  @override
  State<DriverSettingsPage> createState() => _DriverSettingsPageState();
}

class _DriverSettingsPageState extends State<DriverSettingsPage> {
  bool _locationAlways = true;

  @override
  Widget build(BuildContext context) {
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
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.text(context), size: 18),
            ),
          ),
        ),
        title: Text('Settings', style: AppTextStyles.pageTitle(context)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // ── PRIVACY & SECURITY ───────────────────────────────────
          _SectionHeader(label: 'PRIVACY & SECURITY'),

          _ToggleRow(
            label: 'Always Share Location',
            value: _locationAlways,
            onChanged: (v) => setState(() => _locationAlways = v),
          ),
          _RowDivider(),
          _TapRow(
            label: 'Change Password',
            onTap: () => Navigator.pushNamed(context, '/driver/password-reset'),
          ),

          const SizedBox(height: 28),

          // ── SUPPORT ──────────────────────────────────────────────
          _SectionHeader(label: 'SUPPORT'),

          _TapRow(
            label: 'Help Center',
            onTap: () => Navigator.pushNamed(context, '/help-center'),
          ),
          _RowDivider(),
          _TapRow(
            label: 'Contact Support',
            onTap: () => Navigator.pushNamed(context, '/contact-support'),
          ),
          _RowDivider(),
          _TapRow(
            label: 'Rate the App',
            onTap: () => Navigator.pushNamed(context, '/rate-app'),
          ),

          const SizedBox(height: 28),

          // ── ABOUT ────────────────────────────────────────────────
          _SectionHeader(label: 'ABOUT'),

          _TapRow(
            label: 'Terms of Service',
            onTap: () => Navigator.pushNamed(context, '/terms-of-service'),
          ),
          _RowDivider(),
          _TapRow(
            label: 'Privacy Policy',
            onTap: () => Navigator.pushNamed(context, '/privacy-policy'),
          ),
          _RowDivider(),
          _TapRow(
            label: 'App Version',
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
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: AppTextStyles.settingsItem(context)),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 15, color: AppColors.subtext(context)),
          ],
        ),
      ),
    );
  }
}

// ── Toggle Row ────────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTextStyles.settingsItem(context)),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryPurple,
          ),
        ],
      ),
    );
  }
}