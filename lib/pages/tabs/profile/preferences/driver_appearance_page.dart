import 'package:flutter/material.dart';
import '../../../../main.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

class DriverAppearancePage extends StatefulWidget {
  const DriverAppearancePage({super.key});

  @override
  State<DriverAppearancePage> createState() => _DriverAppearancePageState();
}

class _DriverAppearancePageState extends State<DriverAppearancePage> {
  ThemeMode get _selected => themeProvider.mode;

  void _select(ThemeMode mode) {
    themeProvider.setMode(mode);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).translate;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Top bar ──────────────────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border(context)),
                      ),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.text(context),
                        size: 22,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      t('appearance'),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.pageTitle(context),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
              const SizedBox(height: 32),

              // ── Section label ────────────────────────────────────
              Text(t('theme'), style: AppTextStyles.sectionLabel(context)),
              const SizedBox(height: 12),

              // ── Option tiles (separate cards) ────────────────────
              _ThemeTile(
                label: t('dark'),
                mode: ThemeMode.dark,
                selected: _selected,
                onTap: () => _select(ThemeMode.dark),
              ),
              const SizedBox(height: 10),
              _ThemeTile(
                label: t('light'),
                mode: ThemeMode.light,
                selected: _selected,
                onTap: () => _select(ThemeMode.light),
              ),
              const SizedBox(height: 10),
              _ThemeTile(
                label: t('system'),
                mode: ThemeMode.system,
                selected: _selected,
                onTap: () => _select(ThemeMode.system),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final String label;
  final ThemeMode mode;
  final ThemeMode selected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.label,
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  bool get _isSelected => selected == mode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isSelected
                ? AppColors.primaryPurple
                : AppColors.border(context),
            width: _isSelected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: AppTextStyles.settingsItem(context)),
            ),
            if (_isSelected)
              Icon(
                Icons.check_rounded,
                color: AppColors.primaryPurple,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}