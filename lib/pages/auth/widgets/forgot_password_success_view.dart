import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';

class ForgotPasswordSuccessView extends StatelessWidget {
  final Animation<double> successFade;
  final Animation<double> successScale;
  final String email;
  final VoidCallback onBackToSignIn;
  final VoidCallback onResend;

  const ForgotPasswordSuccessView({
    super.key,
    required this.successFade,
    required this.successScale,
    required this.email,
    required this.onBackToSignIn,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).translate;

    return FadeTransition(
      opacity: successFade,
      child: ScaleTransition(
        scale: successScale,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Big check circle
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.green.shade500,
                  size: 40,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Tip card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.text(context).withValues(alpha: 0.4),
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t('forgot_spam_tip'),
                      style: AppTextStyles.bodySmall(context).copyWith(
                        color: AppColors.text(context).withValues(alpha: 0.6),
                        fontSize: 13,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Back to sign in button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onBackToSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA855F7),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  t('back_to_sign_in'),
                  style: AppTextStyles.buttonPrimary.copyWith(
                    fontSize: 16,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Resend link
            Center(
              child: GestureDetector(
                onTap: onResend,
                child: Text(
                  t('resend_email'),
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: const Color(0xFFA855F7),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
