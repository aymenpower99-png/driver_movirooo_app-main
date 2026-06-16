import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../services/dispatch/dispatch_service.dart';

// Channel must match what the backend sends (android.notification.channelId)
const _kChannelId = 'ride_offers';
const _kChannelName = 'Ride Offers';
const _kChannelDesc = 'New ride requests and trip updates';

const _kRideUpdatesId = 'ride_updates';
const _kRideUpdatesName = 'Ride Updates';
const _kRideUpdatesDesc =
    'Ride status changes, cancellations, and confirmations';

const _kSupportId = 'support_messages';
const _kSupportName = 'Support Messages';
const _kSupportDesc = 'Support ticket replies and updates';

const _kChatId = 'chat_messages';
const _kChatName = 'Chat Messages';
const _kChatDesc = 'Messages from passengers';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String _currentLanguage = 'en';
  Map<String, String> _translations = {};

  /// Set the current language and load translations
  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) return;

    _currentLanguage = languageCode;
    try {
      final jsonStr = await rootBundle.loadString(
        'data/translations/$languageCode.json',
      );
      final Map<String, dynamic> data = json.decode(jsonStr);
      _translations = data.map((k, v) => MapEntry(k, v.toString()));
      debugPrint('🔔 Driver loaded translations for language: $languageCode');
    } catch (e) {
      debugPrint('❌ Failed to load driver translations for $languageCode: $e');
    }
  }

  /// Get localized string for a key
  String _translate(String key) => _translations[key] ?? key;

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

    // Ride updates channel (cancel, status changes)
    const AndroidNotificationChannel rideUpdatesChannel =
        AndroidNotificationChannel(
          _kRideUpdatesId,
          _kRideUpdatesName,
          description: _kRideUpdatesDesc,
          importance: Importance.high,
          playSound: true,
        );

    // Chat messages channel
    const AndroidNotificationChannel chatChannel = AndroidNotificationChannel(
      _kChatId,
      _kChatName,
      description: _kChatDesc,
      importance: Importance.high,
      playSound: true,
    );

    // Support ticket messages channel
    const AndroidNotificationChannel supportChannel =
        AndroidNotificationChannel(
          _kSupportId,
          _kSupportName,
          description: _kSupportDesc,
          importance: Importance.high,
          playSound: true,
        );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(channel);
    await androidPlugin?.createNotificationChannel(statusChannel);
    await androidPlugin?.createNotificationChannel(rideUpdatesChannel);
    await androidPlugin?.createNotificationChannel(chatChannel);
    await androidPlugin?.createNotificationChannel(supportChannel);

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/ic_stat_notification');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

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
    final channelId = _channelForType(message.data['type']);
    final channelInfo = _channelDetails(channelId);

    // Use driver_logo.png for chat messages, ic_stat_notification for others
    final icon = message.data['type'] == 'CHAT_MESSAGE'
        ? '@drawable/driver_logo'
        : '@drawable/ic_stat_notification';

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelInfo.id,
          channelInfo.name,
          channelDescription: channelInfo.desc,
          importance: Importance.max,
          priority: Priority.max,
          showWhen: true,
          icon: icon,
          color: const Color(0xFF6B4EFF),
          enableVibration: true,
        );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    // Get title/body - use localized strings if available
    String title =
        message.data['title'] ?? message.notification?.title ?? 'Moviroo';
    String body = message.data['body'] ?? message.notification?.body ?? '';

    final notificationType = message.data['type']?.toString() ?? '';
    if (notificationType.isNotEmpty && _translations.isNotEmpty) {
      String translationKey = notificationType.toLowerCase();

      // Special handling for RIDE_STATUS_CHANGED with status field
      if (notificationType == 'RIDE_STATUS_CHANGED') {
        final status = message.data['status']?.toString() ?? '';
        if (status.isNotEmpty) {
          final statusKey = status.toLowerCase();
          // Map backend enum values to translation keys
          if (statusKey == 'en_route_to_pickup') {
            translationKey = 'ride_status_en_route';
          } else {
            translationKey = 'ride_status_$statusKey';
          }
        }
      }

      title = _translate('notif_${translationKey}_title');
      body = _translate('notif_${translationKey}_body');
    }

    // Fallback to _titleForType if translations not loaded
    if (title == 'Moviroo' && notificationType.isNotEmpty) {
      title = _titleForType(notificationType);
    }

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  String _titleForType(String? type) {
    switch (type) {
      case 'RIDE_OFFER':
        return 'New Ride Request';
      case 'RIDE_CANCELLED':
        return 'Ride Cancelled';
      case 'RIDE_ACCEPTED':
        return 'Ride Accepted';
      case 'RIDE_CANCELLED_BY_DRIVER':
        return 'Ride Cancelled';
      case 'RIDE_CANCELLED_BY_PASSENGER':
        return 'Ride Cancelled';
      case 'RIDE_CANCELLED_BY_ADMIN':
        return 'Ride Cancelled by Admin';
      case 'RIDE_STATUS_CHANGED':
        return 'Ride Update';
      case 'CHAT_MESSAGE':
        return 'New Message';
      case 'DRIVER_STATUS_OFFLINE':
        return 'You Went Offline';
      case 'SUPPORT_TICKET_REPLY':
        return 'Support Reply';
      case 'SUPPORT_TICKET_CREATED':
        return 'New Support Ticket';
      case 'TIER_UNLOCKED':
        return 'Tier Unlocked';
      default:
        return 'Moviroo';
    }
  }

  String _channelForType(String? type) {
    switch (type) {
      case 'RIDE_OFFER':
        return _kChannelId;
      case 'RIDE_CANCELLED':
      case 'RIDE_ACCEPTED':
      case 'RIDE_CANCELLED_BY_DRIVER':
      case 'RIDE_CANCELLED_BY_PASSENGER':
      case 'RIDE_CANCELLED_BY_ADMIN':
      case 'RIDE_STATUS_CHANGED':
        return _kRideUpdatesId;
      case 'CHAT_MESSAGE':
        return _kChatId;
      case 'DRIVER_STATUS_OFFLINE':
        return 'driver_status';
      case 'SUPPORT_TICKET_REPLY':
      case 'SUPPORT_TICKET_CREATED':
        return _kSupportId;
      default:
        return _kChannelId;
    }
  }

  ({String id, String name, String desc}) _channelDetails(String channelId) {
    switch (channelId) {
      case _kRideUpdatesId:
        return (
          id: _kRideUpdatesId,
          name: _kRideUpdatesName,
          desc: _kRideUpdatesDesc,
        );
      case _kChatId:
        return (id: _kChatId, name: _kChatName, desc: _kChatDesc);
      case 'driver_status':
        return (
          id: 'driver_status',
          name: 'Driver Status',
          desc: 'Driver online/offline status alerts',
        );
      case _kSupportId:
        return (id: _kSupportId, name: _kSupportName, desc: _kSupportDesc);
      default:
        return (id: _kChannelId, name: _kChannelName, desc: _kChannelDesc);
    }
  }

  // ─── Notification tap (local) ─────────────────────────────────────────────

  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      onNotificationTap?.call(data['type'] as String?);
      onNotificationDataTap?.call(data);
    } catch (_) {
      // Fallback for plain-string payloads
      onNotificationTap?.call(payload);
    }
  }

  // ─── Listeners ───────────────────────────────────────────────────────────

  /// Called when a RIDE_OFFER push arrives while app is in foreground.
  void Function()? onRideOfferReceived;

  /// Called when the backend forces the driver offline (stale heartbeat).
  void Function()? onDriverForcedOffline;

  /// Called when a ride update push arrives (cancel, status change, etc.).
  void Function(String? type, Map<String, dynamic> data)? onRideUpdate;

  /// Called when a chat message push arrives.
  void Function(Map<String, dynamic> data)? onChatMessage;

  /// Called when a tier unlock push arrives.
  void Function(Map<String, dynamic> data)? onTierUnlocked;

  /// Called when user taps a notification — payload is the notification type.
  void Function(String? type)? onNotificationTap;

  /// Called when user taps a notification — receives the full data payload.
  void Function(Map<String, dynamic> data)? onNotificationDataTap;

  void _listenToMessages() {
    // App is open (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 Foreground push: ${message.notification?.title}');
      _showNotification(message);
      _handleData(message.data);
    });

    // App in background, user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
        '🔔 Notification tapped (background): ${message.notification?.title}',
      );
      _handleData(message.data, tapped: true);
    });
  }

  void _handleData(Map<String, dynamic> data, {bool tapped = false}) {
    final type = data['type'] as String?;
    switch (type) {
      case 'RIDE_OFFER':
        onRideOfferReceived?.call();
        break;
      case 'DRIVER_STATUS_OFFLINE':
        onDriverForcedOffline?.call();
        break;
      case 'RIDE_ACCEPTED':
      case 'RIDE_CANCELLED':
      case 'RIDE_CANCELLED_BY_DRIVER':
      case 'RIDE_CANCELLED_BY_PASSENGER':
      case 'RIDE_CANCELLED_BY_ADMIN':
      case 'RIDE_STATUS_CHANGED':
        onRideUpdate?.call(type, data);
        break;
      case 'CHAT_MESSAGE':
        onChatMessage?.call(data);
        break;
      case 'TIER_UNLOCKED':
        onTierUnlocked?.call(data);
        break;
      case 'SUPPORT_TICKET_REPLY':
      case 'SUPPORT_TICKET_CREATED':
        // No special foreground behavior needed; tap routing handles navigation
        break;
    }
    if (tapped) {
      onNotificationTap?.call(type);
      onNotificationDataTap?.call(data);
    }
  }

  // ─── App Launched from Terminated via Notification ───────────────────────

  Future<void> _handleInitialMessage() async {
    final RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        '🚀 App launched from notification: ${initialMessage.notification?.title}',
      );
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
      icon: '@drawable/ic_stat_notification',
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

  /// Register the current FCM token with the backend.
  /// Call this after every successful login (email, OTP, or any auth flow).
  Future<void> registerFcmTokenAfterLogin() async {
    try {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        await DispatchService().registerFcmToken(token);
        debugPrint('✅ FCM token registered after login');
      } else {
        debugPrint('⚠️ FCM token is null after login — skipping registration');
      }
    } catch (e) {
      debugPrint('⚠️ FCM token registration after login failed: $e');
    }
  }
}
