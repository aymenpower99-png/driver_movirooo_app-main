import 'package:flutter/material.dart';
import '../../widgets/top_bar.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _saving = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context).translate;
    final current = _currentCtrl.text.trim();
    final newPass = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('fill_all_fields')), backgroundColor: Colors.red),
      );
      return;
    }
    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('passwords_do_not_match')), backgroundColor: Colors.red),
      );
      return;
    }
    if (newPass.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('password_too_short')), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.updatePassword(
      currentPassword: current,
      newPassword: newPass,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('password_updated')), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? t('something_went_wrong')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium(
        context,
      ).copyWith(color: AppColors.subtext(context)),
      prefixIcon: Icon(
        Icons.lock_outline_rounded,
        color: AppColors.subtext(context),
        size: 20,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.subtext(context),
          size: 20,
        ),
        onPressed: onToggle,
      ),
      filled: true,
      fillColor: AppColors.surface(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: isDark
            ? BorderSide.none
            : BorderSide(color: AppColors.border(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: isDark
            ? BorderSide.none
            : BorderSide(color: AppColors.border(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: isDark
            ? BorderSide.none
            : BorderSide(color: AppColors.border(context)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).translate;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      resizeToAvoidBottomInset: true,
      // Save button pinned to bottom — no Cancel
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              disabledBackgroundColor: AppColors.primaryPurple.withValues(alpha: 0.5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
              t('save_new_password'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        // Tap anywhere outside a field to dismiss keyboard instantly
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: SingleChildScrollView(
            // Drag scroll down to dismiss keyboard — removes the heavy feeling
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TopBar(title: t('change_password')),
                const SizedBox(height: 12),

                _SectionLabel(label: t('password_details')),
                const SizedBox(height: 12),

                // Card 1 — Current password
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: _FieldTile(
                    label: t('current_password'),
                    child: TextField(
                      controller: _currentCtrl,
                      obscureText: _obscureCurrent,
                      cursorColor: AppColors.primaryPurple,
                      style: AppTextStyles.bodyMedium(context),
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDecoration(
                        context,
                        hint: '••••••••',
                        obscure: _obscureCurrent,
                        onToggle: () =>
                            setState(() => _obscureCurrent = !_obscureCurrent),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Card 2 — New password
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: _FieldTile(
                    label: t('new_password'),
                    child: TextField(
                      controller: _newCtrl,
                      obscureText: _obscureNew,
                      cursorColor: AppColors.primaryPurple,
                      style: AppTextStyles.bodyMedium(context),
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDecoration(
                        context,
                        hint: t('hint_new_password'),
                        obscure: _obscureNew,
                        onToggle: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Card 3 — Confirm new password
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: _FieldTile(
                    label: t('confirm_new_password'),
                    child: TextField(
                      controller: _confirmCtrl,
                      obscureText: _obscureConfirm,
                      cursorColor: AppColors.primaryPurple,
                      style: AppTextStyles.bodyMedium(context),
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      decoration: _fieldDecoration(
                        context,
                        hint: t('hint_retype_password'),
                        obscure: _obscureConfirm,
                        onToggle: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Password tips card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryPurple.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primaryPurple,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('password_tips_title'),
                              style: AppTextStyles.bodySmall(context).copyWith(
                                color: AppColors.primaryPurple,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              t('password_tips_body'),
                              style: AppTextStyles.bodySmall(context).copyWith(
                                color: AppColors.subtext(context),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.bodySmall(context).copyWith(
        color: AppColors.subtext(context),
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        fontSize: 11,
      ),
    );
  }
}

class _FieldTile extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldTile({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall(
              context,
            ).copyWith(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
