import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../routing/router.dart';
import '../../theme/app_colors.dart';

/// Shown at app start while AuthProvider.init() resolves.
/// Routes to dashboard if authenticated, login otherwise — no flash.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.status == AuthStatus.authenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppRouter.clearAndGo(context, AppRouter.driverDashboard);
      });
    } else if (auth.status == AuthStatus.unauthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppRouter.clearAndGo(context, AppRouter.driverLogin);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.primaryPurple,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset('images/lsnn.png', width: 90, height: 90),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}
