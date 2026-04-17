import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'routing/router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'theme/locale_provider.dart';
import 'l10n/app_localizations.dart';
import 'core/api/api_client.dart';
import 'core/notifications/notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/earnings_provider.dart';
import 'providers/online_provider.dart';
import 'providers/ride_provider.dart';

final themeProvider  = ThemeProvider();
final localeProvider = LocaleProvider();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ All notification logic is here
  await NotificationService.instance.init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const SmartWayApp());
}

class SmartWayApp extends StatefulWidget {
  const SmartWayApp({super.key});

  static void restartApp(BuildContext context) =>
      context.findAncestorStateOfType<_SmartWayAppState>()?.restartApp();

  @override
  State<SmartWayApp> createState() => _SmartWayAppState();
}

class _SmartWayAppState extends State<SmartWayApp> {
  int _restartCount = 0;

  void restartApp() => setState(() => _restartCount++);

  void _applySystemUI(ThemeMode mode) {
    final isDark =
        mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDark
            ? const Color(0xFF0B0B0F)
            : const Color(0xFFF4F4F8),
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey(_restartCount),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
          ChangeNotifierProvider(create: (_) => EarningsProvider()),
          ChangeNotifierProvider(create: (_) => OnlineProvider()),
          ChangeNotifierProvider(create: (_) => RideProvider()),
        ],
        child: ListenableBuilder(
          listenable: Listenable.merge([themeProvider, localeProvider]),
          builder: (context, _) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _applySystemUI(themeProvider.mode),
            );

            return MaterialApp(
              navigatorKey: navigatorKey,
              title: 'Moviroo Driver',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.mode,
              locale: localeProvider.locale,
              supportedLocales: const [
                Locale('en'),
                Locale('fr'),
                Locale('ar'),
                Locale('de'),
                Locale('es'),
                Locale('it'),
                Locale('ja'),
                Locale('pt'),
                Locale('ru'),
                Locale('tr'),
                Locale('zh'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              localeResolutionCallback: (locale, supportedLocales) {
                if (locale == null) return supportedLocales.first;
                for (final supported in supportedLocales) {
                  if (supported.languageCode == locale.languageCode) {
                    return supported;
                  }
                }
                return supportedLocales.first;
              },
              initialRoute: AppRouter.splash,
              onGenerateRoute: (settings) {
                final builder = AppRouter.routes[settings.name];
                if (builder == null) return null;
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (context, _, _) => builder(context),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                );
              },
            );
          },
        ),
      ),
    );
  }
}