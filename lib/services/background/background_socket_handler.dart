import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/config/app_config.dart';
import '../../core/storage/token_storage.dart';

/// Handles WebSocket/socket logic for background tracking.
class BackgroundSocketHandler {
  /// Calculate exponential backoff delay
  static int calculateBackoff(int attempt) {
    // Exponential backoff: 1s, 2s, 4s, 8s, 16s, 30s max
    const maxDelay = 30;
    final delay = (1 << (attempt - 1)).clamp(1, maxDelay);
    return delay;
  }

  /// Set up socket disconnect handler for reconnection
  static void setupSocketReconnect(
    io.Socket socket,
    String rideId,
    Timer? reconnectTimer,
    int reconnectAttempts,
    void Function(Timer?, int) onDisconnect,
  ) {
    socket.onDisconnect((_) {
      debugPrint('🚗 [BackgroundSocket] WebSocket disconnected');
      onDisconnect(reconnectTimer, reconnectAttempts + 1);
    });

    socket.onError((error) {
      debugPrint('🚗 [BackgroundSocket] WebSocket error: $error');
      onDisconnect(reconnectTimer, reconnectAttempts + 1);
    });
  }

  /// Reconnect socket with current ride
  static Future<void> reconnectSocket(
    String rideId,
    void Function(io.Socket) onSocketReconnected,
  ) async {
    debugPrint('🚗 [BackgroundSocket] Attempting to reconnect socket');

    final token = await TokenStorage.getAccess();
    if (token == null) {
      debugPrint('🚗 [BackgroundSocket] No access token for reconnection');
      return;
    }

    String wsUrl = AppConfig.baseUrl;
    if (wsUrl.endsWith('/api')) {
      wsUrl = wsUrl.substring(0, wsUrl.length - 4);
    }

    final newSocket = io.io(
      '$wsUrl/chat',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({
            'Authorization': 'Bearer $token',
            'ngrok-skip-browser-warning': 'true',
          })
          .disableAutoConnect()
          .build(),
    );

    newSocket.connect();

    newSocket.onConnect((_) {
      debugPrint('🚗 [BackgroundSocket] WebSocket reconnected');
      newSocket.emit('join', {'ride_id': rideId});
      onSocketReconnected(newSocket);
    });

    newSocket.onDisconnect((_) {
      debugPrint('🚗 [BackgroundSocket] Reconnection failed, will retry');
    });
  }

  /// Create a new socket connection
  static io.Socket createSocket(String token) {
    String wsUrl = AppConfig.baseUrl;
    if (wsUrl.endsWith('/api')) {
      wsUrl = wsUrl.substring(0, wsUrl.length - 4);
    }

    return io.io(
      '$wsUrl/chat',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({
            'Authorization': 'Bearer $token',
            'ngrok-skip-browser-warning': 'true',
          })
          .disableAutoConnect()
          .build(),
    );
  }

  /// Create socket with base URL (helper method)
  static String getWebSocketUrl() {
    String wsUrl = AppConfig.baseUrl;
    if (wsUrl.endsWith('/api')) {
      wsUrl = wsUrl.substring(0, wsUrl.length - 4);
    }
    return '$wsUrl/chat';
  }
}
