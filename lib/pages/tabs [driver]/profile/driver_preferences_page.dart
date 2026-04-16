import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

class DriverPreferencesPage extends StatefulWidget {
  const DriverPreferencesPage({super.key});

  @override
  State<DriverPreferencesPage> createState() => _DriverPreferencesPageState();
}

class _DriverPreferencesPageState extends State<DriverPreferencesPage> {
  bool _darkMode = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'XOF (CFA)';

  final List<String> _languages = ['English', 'Français', 'Wolof'];
  final List<String> _currencies = ['XOF (CFA)', 'USD', 'EUR'];

  @override
  Widget build(BuildContext context) {
    _darkMode = Theme.of(context).brightness == Brightness.dark;
    final t = AppLocalizations.of(context).translate;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.text(context),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(t('prefs_title'), style: AppTextStyles.pageTitle(context)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── APPEARANCE ───────────────────────────────────────────
          _SectionHeader(label: t('prefs_appearance_section')),
          const SizedBox(height: 10),
          _SettingsCard(
            children: [
              _ToggleRow(
                icon: Icons.dark_mode_outlined,
                label: t('prefs_dark_mode'),
                subtitle: t('prefs_dark_mode_subtitle'),
                value: _darkMode,
                onChanged: (v) {
                  setState(() => _darkMode = v);
                  // TODO: wire up ThemeNotifier / provider
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── LANGUAGE & REGION ────────────────────────────────────
          _SectionHeader(label: t('prefs_lang_region_section')),
          const SizedBox(height: 10),
          _SettingsCard(
            children: [
              _DropdownRow(
                icon: Icons.language_rounded,
                label: t('prefs_language'),
                value: _selectedLanguage,
                items: _languages,
                onChanged: (v) => setState(() => _selectedLanguage = v!),
              ),
              _Divider(),
              _DropdownRow(
                icon: Icons.monetization_on_outlined,
                label: t('prefs_currency'),
                value: _selectedCurrency,
                items: _currencies,
                onChanged: (v) => setState(() => _selectedCurrency = v!),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) =>
      Text(label, style: AppTextStyles.sectionLabel(context));
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _IconBox(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.settingsItem(context)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.settingsItemValue(context)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primaryPurple,
          ),
        ],
      ),
    );
  }
}

class _DropdownRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _IconBox(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: AppTextStyles.settingsItem(context)),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              style: AppTextStyles.settingsItemValue(context),
              dropdownColor: AppColors.surface(context),
              icon: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.subtext(context),
                size: 20,
              ),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  const _IconBox({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.iconBg(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.primaryPurple, size: 18),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 66,
      color: AppColors.border(context),
    );
  }
}
