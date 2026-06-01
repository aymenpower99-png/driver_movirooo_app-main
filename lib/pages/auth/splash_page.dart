import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../routing/router.dart';

/// Shown at app start while AuthProvider.init() resolves.
/// Routes to dashboard if authenticated, login otherwise — no flash.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Hide status bar for full-screen splash
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

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
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo with shadow
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 30,
                    spreadRadius: 5,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Image.asset('images/640WH.png', width: 120, height: 120),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Color(0xFFA855F7),
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}
