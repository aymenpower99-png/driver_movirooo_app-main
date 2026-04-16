import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // ─── Init ────────────────────────────────────────────────────────────────

  Future<void> init() async {
    await _requestPermission();
    await _initLocalNotifications();
    await _setForegroundOptions();
    _listenToMessages();
    await _handleInitialMessage();
    await printToken();
  }

  // ─── Permission ──────────────────────────────────────────────────────────

  Future<void> _requestPermission() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ─── Local Notifications Setup ───────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(initSettings);
  }

  // ─── Foreground Options ──────────────────────────────────────────────────

  Future<void> _setForegroundOptions() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ─── Show Local Notification Popup ───────────────────────────────────────

  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'Default notification channel',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title,
      message.notification?.body,
      details,
    );
  }

  // ─── Listeners ───────────────────────────────────────────────────────────

  void _listenToMessages() {
    // App is open (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Foreground notification received!');
      print('   Title: ${message.notification?.title}');
      print('   Body:  ${message.notification?.body}');
      _showNotification(message);
    });

    // App in background, user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 Notification tapped (background): ${message.notification?.title}');
      // TODO: navigate to specific screen based on message.data
    });
  }

  // ─── App Launched from Terminated via Notification ───────────────────────

  Future<void> _handleInitialMessage() async {
    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('🚀 App launched from notification: ${initialMessage.notification?.title}');
      // TODO: navigate to specific screen based on initialMessage.data
    }
  }

  // ─── Print Token (for testing) ───────────────────────────────────────────

  Future<void> printToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    print('=============================');
    print('FCM Token: $token');
    print('=============================');
  }

  // ─── Get Token (to send to your backend) ─────────────────────────────────

  Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  // ─── Token Refresh (call this to keep backend updated) ───────────────────

  void onTokenRefresh(Function(String) callback) {
    FirebaseMessaging.instance.onTokenRefresh.listen(callback);
  }
}