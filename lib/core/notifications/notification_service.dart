import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Channel must match what the backend sends (android.notification.channelId)
const _kChannelId   = 'ride_offers';
const _kChannelName = 'Ride Offers';
const _kChannelDesc = 'New ride requests and trip updates';

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
    if (kDebugMode) await printToken();
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
    // Create high-importance Android channel for ride offers
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _kChannelId,
      _kChannelName,
      description: _kChannelDesc,
      importance: Importance.max,
      playSound: true,
    );

    // Create channel for driver status alerts (online/offline notifications)
    const AndroidNotificationChannel statusChannel = AndroidNotificationChannel(
      'driver_status',
      'Driver Status',
      description: 'Driver online/offline status alerts',
      importance: Importance.high,
      playSound: true,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(channel);
    await androidPlugin?.createNotificationChannel(statusChannel);

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
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
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _kChannelId,
      _kChannelName,
      channelDescription: _kChannelDesc,
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    final NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? _titleForType(message.data['type']),
      message.notification?.body,
      details,
      payload: message.data['type'],
    );
  }

  String _titleForType(String? type) {
    switch (type) {
      case 'RIDE_OFFER':     return '🚗 New Ride Request';
      case 'RIDE_CANCELLED': return '❌ Ride Cancelled';
      default:               return 'Moviroo';
    }
  }

  // ─── Notification tap (local) ─────────────────────────────────────────────

  void _onNotificationTap(NotificationResponse response) {
    final type = response.payload;
    onNotificationTap?.call(type);
  }

  // ─── Listeners ───────────────────────────────────────────────────────────

  /// Called when a RIDE_OFFER push arrives while app is in foreground.
  void Function()? onRideOfferReceived;

  /// Called when the backend forces the driver offline (stale heartbeat).
  void Function()? onDriverForcedOffline;

  /// Called when user taps a notification — payload is the notification type.
  void Function(String? type)? onNotificationTap;

  void _listenToMessages() {
    // App is open (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 Foreground push: ${message.notification?.title}');
      _showNotification(message);
      _handleData(message.data);
    });

    // App in background, user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🔔 Notification tapped (background): ${message.notification?.title}');
      _handleData(message.data, tapped: true);
    });
  }

  void _handleData(Map<String, dynamic> data, {bool tapped = false}) {
    final type = data['type'] as String?;
    if (type == 'RIDE_OFFER') {
      onRideOfferReceived?.call();
    }
    if (type == 'DRIVER_STATUS_OFFLINE') {
      onDriverForcedOffline?.call();
    }
    if (tapped) {
      onNotificationTap?.call(type);
    }
  }

  // ─── App Launched from Terminated via Notification ───────────────────────

  Future<void> _handleInitialMessage() async {
    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('🚀 App launched from notification: ${initialMessage.notification?.title}');
      _handleData(initialMessage.data, tapped: true);
    }
  }

  // ─── Show a custom local notification (e.g., driver went offline) ────────────

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'driver_status',
      'Driver Status',
      channelDescription: 'Driver online/offline status alerts',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(android: androidDetails);
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // ─── Token helpers ────────────────────────────────────────────────────────

  Future<void> printToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('=============================');
    debugPrint('FCM Token: $token');
    debugPrint('=============================');
  }

  Future<String?> getToken() async {
    return FirebaseMessaging.instance.getToken();
  }

  void onTokenRefresh(Function(String) callback) {
    FirebaseMessaging.instance.onTokenRefresh.listen(callback);
  }
}