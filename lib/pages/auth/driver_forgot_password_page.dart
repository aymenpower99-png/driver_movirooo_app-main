import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';

class DriverForgotPasswordPage extends StatefulWidget {
  const DriverForgotPasswordPage({super.key});

  @override
  State<DriverForgotPasswordPage> createState() =>
      _DriverForgotPasswordPageState();
}

class _DriverForgotPasswordPageState extends State<DriverForgotPasswordPage>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  bool _sent = false;

  late AnimationController _animCtrl;
  late AnimationController _successCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _successFade;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successFade = CurvedAnimation(parent: _successCtrl, curve: Curves.easeOut);
    _successScale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _successCtrl, curve: Curves.easeOutBack));

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _successCtrl.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    final auth = context.read<AuthProvider>();
    final ok   = await auth.forgotPassword(email);
    if (!mounted) return;
    if (ok) {
      setState(() => _sent = true);
      _successCtrl.forward();
    }
    // error handled by auth.error snackbar in parent
  }

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
    final t       = AppLocalizations.of(context).translate;
    final auth    = context.watch<AuthProvider>();
    final loading = auth.loading;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (auth.error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(auth.error!),
            backgroundColor: Colors.red.shade700,
          ));
        auth.clearError();
      }
    });
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // ── Back button ───────────────────────────────────────
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.text(context),
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Icon tile (always visible) ────────────────────────
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFA855F7).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: Color(0xFFA855F7),
                          size: 30,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Heading (always visible) ──────────────────────────
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _sent
                                ? t('forgot_check_inbox')
                                : t('forgot_password'),
                            style: AppTextStyles.pageTitle(context).copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _sent
                                ? t('forgot_sent_link').replaceAll(
                                    '{email}',
                                    _emailController.text.trim(),
                                  )
                                : t('forgot_password_subtitle'),
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              color: AppColors.text(context).withValues(alpha: 0.6),
                              fontSize: 14,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ══════════════════════════════════════════════════════
                  // SUCCESS STATE
                  // ══════════════════════════════════════════════════════
                  if (_sent) ...[
                    FadeTransition(
                      opacity: _successFade,
                      child: ScaleTransition(
                        scale: _successScale,
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
                                    color: AppColors.text(
                                      context,
                                    ).withValues(alpha: 0.4),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      t('forgot_spam_tip'),
                                      style: AppTextStyles.bodySmall(context)
                                          .copyWith(
                                            color: AppColors.text(
                                              context,
                                            ).withValues(alpha: 0.6),
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
                                onPressed: () => Navigator.of(context).pop(),
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
                                onTap: () {
                                  setState(() => _sent = false);
                                  _successCtrl.reset();
                                },
                                child: Text(
                                  t('resend_email'),
                                  style: AppTextStyles.bodySmall(context)
                                      .copyWith(
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
                    ),
                  ],

                  // ══════════════════════════════════════════════════════
                  // DEFAULT STATE
                  // ══════════════════════════════════════════════════════
                  if (!_sent) ...[
                    // Email field
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('label_email'),
                              style: AppTextStyles.bodySmall(context).copyWith(
                                color: AppColors.text(
                                  context,
                                ).withValues(alpha: 0.55),
                                fontWeight: FontWeight.w700,
                                fontSize: 10.5,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              cursorColor: const Color(0xFFA855F7),
                              style: AppTextStyles.bodyMedium(
                                context,
                              ).copyWith(fontSize: 15),
                              decoration: _fieldDecoration(context),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Send button
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: loading ? null : _submit,
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
                      opacity: _fadeAnim,
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

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
