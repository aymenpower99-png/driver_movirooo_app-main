import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/pages/auth/login_driver.dart' show DriverLoginPage;
import 'package:moviroo_driver_app/pages/auth/splash_page.dart';
import 'package:moviroo_driver_app/pages/contact_support/contact_support_page.dart';
import 'package:moviroo_driver_app/pages/support/my_tickets_page.dart';
import 'package:moviroo_driver_app/pages/support/ticket_detail_page.dart';
import 'package:moviroo_driver_app/pages/work_area/work_area_page.dart';

import '../pages/tabs/chat/chat_page.dart';
import '../pages/tabs/profile/password/passwordrest.dart';
import '../pages/tabs/profile/rate/rate.dart';
import '../pages/tabs/active_ride/active_ride_page.dart';
import '../pages/tabs/dashboard/dashboard_page.dart';
import '../pages/tabs/earnings/earnings_page.dart';
import '../pages/tabs/rides/rides_page.dart';
import '../pages/tabs/profile/driver_profile_page.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPass = '/forgot-password';
static const String driverEarningsPage = '/earnings';
  // Passenger
static const String driverLogin = '/driver/login';
static const String contactSupport = '/contact-support';
static const String rateApp = '/rate-app';
  // Driver
  static const String driverDashboard = '/driver/dashboard';
  static const String driverRides = '/driver/rides';
  static const String driverProfile = '/driver/profile';
static const String activeRide = '/driver/active-ride';
  static const String chat = '/chat';
static const String mapPreview = '/map-preview';
static const String driverPickup = '/driver/pickup';
static const String driverDone = '/driver/done';
// Dans routes :
static const String initialRoute = driverLogin;
static const String ratePassenger = '/rate-passenger';
static const String rest = '/driver/password-reset';
static const String myTickets = '/driver/my-tickets';
static const String ticketDetail = '/driver/ticket-detail';
static const String workArea = '/driver/work-area';
  static Map<String, WidgetBuilder> get routes => {
    splash:        (_) => const SplashPage(),
    contactSupport: (_) => const ContactSupportPage(),

  driverLogin: (_) => const DriverLoginPage(),
rest: (_) => const PasswordResetPage(),
driverEarningsPage: (_) => const EarningsPage(),
rateApp: (_) => RatePage(),
    // Driver
    driverDashboard: (_) => const DashboardPage(),
    driverRides: (_) => const RidesPage(),   // ← added
    driverProfile: (_) => const DriverProfilePage(),
  activeRide: (_) => const ActiveRidePage(),
    chat: (_) => const ChatPage(),
    myTickets: (_) => const MyTicketsPage(),
    ticketDetail: (_) => const TicketDetailPage(),
    workArea: (_) => const WorkAreaPage(),
  };

  static Future<T?> push<T>(
    BuildContext context,
    String routeName, {
    Object? args,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: args);
  }

  static Future<T?> replace<T>(
    BuildContext context,
    String routeName, {
    Object? args,
  }) {
    return Navigator.pushReplacementNamed<T, dynamic>(
      context,
      routeName,
      arguments: args,
    );
  }

  static Future<T?> clearAndGo<T>(
    BuildContext context,
    String routeName, {
    Object? args,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (_) => false,
      arguments: args,
    );
  }

  static void pop(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }
}