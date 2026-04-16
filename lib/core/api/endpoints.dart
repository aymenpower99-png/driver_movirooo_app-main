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
  static const String driverMe           = '/drivers/me';
  static const String driverAvailability = '/drivers/me/availability';

  // ── Dispatch ──────────────────────────────────────────────────────────────
  static const String sendLocation  = '/dispatch/locations';
  static const String heartbeat     = '/dispatch/locations/heartbeat';
  static const String goOnline      = '/dispatch/locations/online';
  static const String goOffline     = '/dispatch/locations/offline';
  static const String pendingOffers = '/dispatch/offers/pending';

  static String acceptOffer(String id) => '/dispatch/offers/$id/accept';
  static String rejectOffer(String id) => '/dispatch/offers/$id/reject';

  // ── Support Tickets ──────────────────────────────────────────────────────
  static const String tickets       = '/support/tickets';
  static String ticket(String id)   => '/support/tickets/$id';
  static String ticketReply(String id) => '/support/tickets/$id/reply';

  // ── Rides ─────────────────────────────────────────────────────────────
  static const String rides = '/rides';
}
