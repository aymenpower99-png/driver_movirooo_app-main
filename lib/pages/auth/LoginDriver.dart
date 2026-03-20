import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../routing/router.dart';
import 'driver_forgot_password_page.dart';

class DriverLoginPage extends StatefulWidget {
  const DriverLoginPage({super.key});

  @override
  State<DriverLoginPage> createState() => _DriverLoginPageState();
}

class _DriverLoginPageState extends State<DriverLoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passController  = TextEditingController();
  bool _obscurePass  = true;
  bool _isLoading    = false;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required String hint,
    required IconData prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium(context).copyWith(
        color: AppColors.text(context).withOpacity(0.35),
        fontSize: 14,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: const Color(0xFFA855F7),
        size: 19,
      ),
      suffixIcon: suffix,
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
        borderSide: BorderSide(
          color: Color(0xFFA855F7),
          width: 1.8,
        ),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
    );
  }

  void _login() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _isLoading = false);
    AppRouter.clearAndGo(context, AppRouter.driverDashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),

                  // ── Logo ──────────────────────────────────────────────
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'images/lsnn.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Title ─────────────────────────────────────────────
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Center(
                        child: Text(
                          'Movirooo',
                          style: AppTextStyles.pageTitle(context).copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── Email ─────────────────────────────────────────────
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label(context, 'EMAIL'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            cursorColor: AppColors.primaryPurple,
                            style: AppTextStyles.bodyMedium(context)
                                .copyWith(fontSize: 15),
                            decoration: _fieldDecoration(
                              context,
                              hint: 'you@example.com',
                              prefixIcon: Icons.mail_outline_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Password ───────────────────────────────────────────
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label(context, 'PASSWORD'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passController,
                            obscureText: _obscurePass,
                            cursorColor: AppColors.primaryPurple,
                            style: AppTextStyles.bodyMedium(context)
                                .copyWith(fontSize: 15),
                            decoration: _fieldDecoration(
                              context,
                              hint: 'Enter your password',
                              prefixIcon: Icons.lock_outline_rounded,
                              suffix: GestureDetector(
                                onTap: () => setState(
                                    () => _obscurePass = !_obscurePass),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Icon(
                                    _obscurePass
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.text(context)
                                        .withOpacity(0.45),
                                    size: 19,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Forgot password link ───────────────────────────────
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const DriverForgotPasswordPage(),
                          ),
                        ),
                        child: Text(
                          'Forgot password?',
                          style: AppTextStyles.bodySmall(context).copyWith(
                            color: AppColors.primaryPurple,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Sign In button ─────────────────────────────────────
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          disabledBackgroundColor:
                              AppColors.primaryPurple.withOpacity(0.45),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.4,
                                ),
                              )
                            : Text(
                                'Sign In',
                                style: AppTextStyles.buttonPrimary.copyWith(
                                  fontSize: 16,
                                  letterSpacing: 0.3,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    return Text(
      text,
      style: AppTextStyles.bodySmall(context).copyWith(
        color: AppColors.text(context),
        fontWeight: FontWeight.w700,
        fontSize: 10.5,
        letterSpacing: 1.1,
      ),
    );
  }
}