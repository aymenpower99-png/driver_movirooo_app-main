import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import 'widgets/forgot_password_success_view.dart';
import 'widgets/forgot_password_input_view.dart';

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
                    ForgotPasswordSuccessView(
                      successFade: _successFade,
                      successScale: _successScale,
                      email: _emailController.text.trim(),
                      onBackToSignIn: () => Navigator.of(context).pop(),
                      onResend: () {
                        setState(() => _sent = false);
                        _successCtrl.reset();
                      },
                    ),
                  ],

                  // ══════════════════════════════════════════════════════
                  // DEFAULT STATE
                  // ══════════════════════════════════════════════════════
                  if (!_sent) ...[
                    ForgotPasswordInputView(
                      emailController: _emailController,
                      fadeAnim: _fadeAnim,
                      slideAnim: _slideAnim,
                      loading: loading,
                      onSubmit: _submit,
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
