import '../config/app_config.dart';

/// Central registry of all backend API routes.
/// The base URL is defined in AppConfig — change it there when ngrok restarts.
class Endpoints {
  static String get baseUrl => AppConfig.baseUrl;

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login          = '/auth/login';
  static const String verifyLoginOtp = '/auth/login/verify-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String me             = '/auth/me';
  static const String updatePassword = '/auth/me/password';
  static const String refresh        = '/auth/refresh';
  static const String logout         = '/auth/logout';

  // ── Driver ────────────────────────────────────────────────────────────────
  static const String driverMe             = '/drivers/me';
  static const String driverAvailability   = '/drivers/me/availability';
  static const String notificationPrefs    = '/drivers/me/notifications';
  static const String driverSeedMonthlyTime = '/drivers/me/seed-monthly-time';

  // ── Dispatch ──────────────────────────────────────────────────────────────
  static const String sendLocation  = '/dispatch/locations';
  static const String heartbeat     = '/dispatch/locations/heartbeat';
  static const String goOnline      = '/dispatch/locations/online';
  static const String goOffline     = '/dispatch/locations/offline';
  static const String pendingOffers = '/dispatch/offers/pending';

  static String acceptOffer(String id) => '/dispatch/offers/$id/accept';
  static String rejectOffer(String id) => '/dispatch/offers/$id/reject';
  static const String registerFcmToken = '/dispatch/fcm-token';

  // ── Support Tickets ──────────────────────────────────────────────────────
  static const String tickets       = '/support/tickets';
  static String ticket(String id)   => '/support/tickets/$id';
  static String ticketReply(String id) => '/support/tickets/$id/reply';

  // ── Rides ─────────────────────────────────────────────────────────────
  static const String rides = '/rides';

  // ── Trip lifecycle ────────────────────────────────────────────────────
  static String tripEnroute(String rideId) => '/trips/$rideId/enroute';
  static String tripArrived(String rideId) => '/trips/$rideId/arrived';
  static String tripStart(String rideId)   => '/trips/$rideId/start';
  static String tripEnd(String rideId)     => '/trips/$rideId/end';
  static String tripCancel(String rideId)  => '/trips/$rideId/cancel';
  static String tripStatus(String rideId)  => '/trips/$rideId';

  // ── Help Center ──────────────────────────────────────────────────────
  static const String helpCenter = '/help-center';

  // ── Earnings ─────────────────────────────────────────────────────────
  static const String earningsMe     = '/earnings/me';
  static const String earningsConfig = '/earnings/config';

  // ── Chat ─────────────────────────────────────────────────────────────
  static String chatMessages(String rideId) => '/chat/$rideId/messages';
}
