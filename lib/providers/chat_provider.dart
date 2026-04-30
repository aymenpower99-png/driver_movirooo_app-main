import 'package:flutter/foundation.dart';
import '../pages/tabs/chat/chat_message.dart';
import '../services/chat/chat_service.dart';

/// Provider for chat message caching.
/// Stores messages by rideId to prevent unnecessary API calls.
class ChatProvider extends ChangeNotifier {
  // Cache messages by rideId
  final Map<String, List<ChatMessage>> _chatsByRideId = {};

  // Get messages for a ride (from cache)
  List<ChatMessage> getMessages(String rideId) {
    return _chatsByRideId[rideId] ?? [];
  }

  // Check if messages are already cached for a ride
  bool isCached(String rideId) {
    return _chatsByRideId.containsKey(rideId);
  }

  // Fetch messages only if not cached
  Future<void> fetchMessages(String rideId) async {
    if (_chatsByRideId.containsKey(rideId)) {
      debugPrint('💬 [ChatProvider] Messages already cached for ride: $rideId');
      return;
    }

    debugPrint('💬 [ChatProvider] Fetching messages for ride: $rideId');
    final chatService = ChatService();
    final history = await chatService.fetchHistory(rideId);

    final messages = history.map((msg) => _chatMsgToUI(msg)).toList();
    _chatsByRideId[rideId] = messages;
    notifyListeners();
    debugPrint(
      '💬 [ChatProvider] Cached ${messages.length} messages for ride: $rideId',
    );
  }

  // Add new message to cache
  void addMessage(String rideId, ChatMessage message) {
    if (!_chatsByRideId.containsKey(rideId)) {
      _chatsByRideId[rideId] = [];
    }
    _chatsByRideId[rideId]!.add(message);
    notifyListeners();
    debugPrint('💬 [ChatProvider] Added message to cache for ride: $rideId');
  }

  // Update message in cache
  void updateMessage(String rideId, String messageId, String text) {
    if (!_chatsByRideId.containsKey(rideId)) return;

    final messages = _chatsByRideId[rideId]!;
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      messages[index] = messages[index].copyWith(text: text, isEdited: true);
      notifyListeners();
      debugPrint(
        '💬 [ChatProvider] Updated message in cache for ride: $rideId',
      );
    }
  }

  // Delete message from cache
  void deleteMessage(String rideId, String messageId) {
    if (!_chatsByRideId.containsKey(rideId)) return;

    _chatsByRideId[rideId]!.removeWhere((m) => m.id == messageId);
    notifyListeners();
    debugPrint(
      '💬 [ChatProvider] Deleted message from cache for ride: $rideId',
    );
  }

  // Clear cache for a specific ride (useful when ride ends)
  void clearRide(String rideId) {
    _chatsByRideId.remove(rideId);
    notifyListeners();
    debugPrint('💬 [ChatProvider] Cleared cache for ride: $rideId');
  }

  // Clear all cache (useful for logout)
  void clearAll() {
    _chatsByRideId.clear();
    notifyListeners();
    debugPrint('💬 [ChatProvider] Cleared all chat cache');
  }

  // Convert ChatMsg to ChatMessage (UI model)
  ChatMessage _chatMsgToUI(ChatMsg m) {
    return ChatMessage(
      id: m.id,
      text: m.text,
      isMe: m.senderRole == 'driver',
      time: _formatTime(m.createdAt),
      isEdited: m.isEdited,
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:$m $period';
  }
}
