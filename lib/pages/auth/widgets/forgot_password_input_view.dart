import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';

class ForgotPasswordInputView extends StatelessWidget {
  final TextEditingController emailController;
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final bool loading;
  final VoidCallback onSubmit;

  const ForgotPasswordInputView({
    super.key,
    required this.emailController,
    required this.fadeAnim,
    required this.slideAnim,
    required this.loading,
    required this.onSubmit,
  });

  InputDecoration _fieldDecoration(BuildContext context) {
    final hint = AppLocalizations.of(context).translate('hint_email');
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium(context).copyWith(
        color: AppColors.text(context).withValues(alpha: 0.35),
        fontSize: 14,
      ),
      prefixIcon: const Icon(
        Icons.mail_outline_rounded,
        color: Color(0xFFA855F7),
        size: 19,
      ),
      filled: true,
      fillColor: AppColors.surface(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: const BorderSide(color: Color(0xFFA855F7), width: 1.8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).translate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email field
        FadeTransition(
          opacity: fadeAnim,
          child: SlideTransition(
            position: slideAnim,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('label_email'),
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.text(context).withValues(alpha: 0.55),
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: const Color(0xFFA855F7),
                  style: AppTextStyles.bodyMedium(context).copyWith(fontSize: 15),
                  decoration: _fieldDecoration(context),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Send button
        FadeTransition(
          opacity: fadeAnim,
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: loading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA855F7),
                disabledBackgroundColor: const Color(
                  0xFFA855F7,
                ).withValues(alpha: 0.45),
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.4,
                      ),
                    )
                  : Text(
                      t('send_recovery_link'),
                      style: AppTextStyles.buttonPrimary.copyWith(
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Remembered it? sign in link
        FadeTransition(
          opacity: fadeAnim,
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.bodySmall(context).copyWith(
                    fontSize: 13,
                    color: AppColors.text(context).withValues(alpha: 0.6),
                  ),
                  children: [
                    TextSpan(text: t('remembered_password')),
                    TextSpan(
                      text: t('sign_in'),
                      style: const TextStyle(
                        color: Color(0xFFA855F7),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
