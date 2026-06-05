import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../main.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../services/auth/auth_service.dart';
import '../../../../core/notifications/notification_service.dart';

class DriverLanguagePage extends StatefulWidget {
  const DriverLanguagePage({super.key});

  @override
  State<DriverLanguagePage> createState() => _DriverLanguagePageState();
}

class _DriverLanguagePageState extends State<DriverLanguagePage> {
  late String _selectedLanguage;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = localeProvider.locale.languageCode;
  }

  Future<void> _selectLanguage(String languageCode) async {
    if (_isUpdating) return;

    final previousLanguage = _selectedLanguage;
    setState(() {
      _selectedLanguage = languageCode;
      _isUpdating = true;
    });

    try {
      localeProvider.setLocaleByCode(languageCode);
      await NotificationService.instance.setLanguage(languageCode);
      await AuthService().updateLanguage(languageCode);
      if (mounted) Navigator.pop(context, languageCode);
    } catch (e) {
      localeProvider.setLocaleByCode(localeProvider.locale.languageCode);
      setState(() => _selectedLanguage = previousLanguage);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update language. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

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
                      t.translate('language'),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.pageTitle(context),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
              const SizedBox(height: 32),

              // ── Section label ────────────────────────────────────
              Text(
                t.translate('selectLanguage'),
                style: AppTextStyles.sectionLabel(context),
              ),
              const SizedBox(height: 12),

              // ── Language options (separate cards) ────────────────
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _LanguageTile(
                      label: t.translate('english'),
                      subtitle: t.translate('englishUS'),
                      languageCode: 'en',
                      selected: _selectedLanguage,
                      onTap: () => _selectLanguage('en'),
                    ),
                    const SizedBox(height: 10),
                    _LanguageTile(
                      label: t.translate('french'),
                      subtitle: 'Français',
                      languageCode: 'fr',
                      selected: _selectedLanguage,
                      onTap: () => _selectLanguage('fr'),
                    ),
                    const SizedBox(height: 10),
                    _LanguageTile(
                      label: t.translate('arabic'),
                      subtitle: 'العربية',
                      languageCode: 'ar',
                      selected: _selectedLanguage,
                      onTap: () => _selectLanguage('ar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final String languageCode;
  final String selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.label,
    required this.subtitle,
    required this.languageCode,
    required this.selected,
    required this.onTap,
  });

  bool get _isSelected => selected == languageCode;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.settingsItem(context)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodySmall(context)),
                ],
              ),
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
