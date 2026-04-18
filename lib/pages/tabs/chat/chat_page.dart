import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/chat_service.dart';
import 'chat_message.dart';
import 'chat_input.dart';
import 'translation_banner.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _input = TextEditingController();
  final ChatService _chatService = ChatService();
  bool _autoTranslate = true;
  bool _loading = true;

  final List<ChatMessage> _messages = [];

  String? _rideId;
  String? _myUserId;
  String? _passengerName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_rideId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _rideId = args['rideId']?.toString();
        _passengerName = args['passengerName']?.toString();
      }
      _myUserId = context.read<AuthProvider>().user?.id;
      if (_rideId != null) _initChat();
    }
  }

  Future<void> _initChat() async {
    // Wire socket callbacks
    _chatService.onMessage = _onNewMessage;
    _chatService.onEdited = _onMessageEdited;
    _chatService.onDeleted = _onMessageDeleted;

    // Connect WebSocket
    await _chatService.connect(_rideId!);

    // Load history
    try {
      final history = await _chatService.fetchHistory(_rideId!);
      if (mounted) {
        setState(() {
          _messages.clear();
          for (final m in history) {
            _messages.add(_chatMsgToUI(m));
          }
          _loading = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  ChatMessage _chatMsgToUI(ChatMsg m) {
    return ChatMessage(
      id: m.id,
      text: m.text,
      isMe: m.senderId == _myUserId,
      time: _formatTime(m.createdAt),
      isVoice: m.isVoice,
      isEdited: m.isEdited,
    );
  }

  void _onNewMessage(ChatMsg msg) {
    // Avoid duplicates (we already added optimistic local messages)
    if (_messages.any((m) => m.id == msg.id)) return;
    // Remove optimistic placeholder if this is our own message
    if (msg.senderId == _myUserId) {
      _messages.removeWhere(
        (m) => m.id.startsWith('local_') && m.text == msg.text,
      );
    }
    if (mounted) {
      setState(() => _messages.add(_chatMsgToUI(msg)));
      _scrollToBottom();
    }
  }

  void _onMessageEdited(String messageId, String text) {
    if (!mounted) return;
    setState(() {
      final idx = _messages.indexWhere((m) => m.id == messageId);
      if (idx != -1) {
        _messages[idx] = _messages[idx].copyWith(text: text, isEdited: true);
      }
    });
  }

  void _onMessageDeleted(String messageId) {
    if (!mounted) return;
    setState(() => _messages.removeWhere((m) => m.id == messageId));
  }

  // ── Delete ──────────────────────────────────────────────
  void _deleteMessage(String id) {
    _chatService.deleteMessage(rideId: _rideId!, messageId: id);
    setState(() => _messages.removeWhere((m) => m.id == id));
  }

  // ── Edit ────────────────────────────────────────────────
  void _editMessage(String id, String newText) {
    _chatService.editMessage(rideId: _rideId!, messageId: id, text: newText);
    setState(() {
      final index = _messages.indexWhere((m) => m.id == id);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(
          text: newText,
          isEdited: true,
        );
      }
    });
  }

  // ── Send text ───────────────────────────────────────────
  void _sendMessage(String text) {
    if (text.trim().isEmpty || _rideId == null || _myUserId == null) return;

    _chatService.sendMessage(
      rideId: _rideId!,
      senderId: _myUserId!,
      senderRole: 'driver',
      text: text.trim(),
    );

    _input.clear();
    _scrollToBottom();
  }

  // ── Send voice ──────────────────────────────────────────
  void _sendVoice(String audioPath) {
    if (_rideId == null || _myUserId == null) return;

    _chatService.sendMessage(
      rideId: _rideId!,
      senderId: _myUserId!,
      senderRole: 'driver',
      text: '🎤 Voice message',
      isVoice: true,
    );

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:$m $period';
  }

  @override
  void dispose() {
    _chatService.disconnect();
    _scroll.dispose();
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).translate;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            _ChatTopBar(passengerName: _passengerName ?? t('chat_passenger')),
            TranslationBanner(
              enabled: _autoTranslate,
              onToggle: (v) => setState(() => _autoTranslate = v),
            ),
            if (_loading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                        child: Text(
                          t('chat_no_messages'),
                          style: AppTextStyles.bodySmall(
                            context,
                          ).copyWith(color: AppColors.subtext(context)),
                        ),
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _messages.length,
                        itemBuilder: (context, i) {
                          final msg = _messages[i];
                          return ChatBubble(
                            message: msg,
                            showTranslation: _autoTranslate,
                            onDelete: () => _deleteMessage(msg.id),
                            onEdit: (newText) => _editMessage(msg.id, newText),
                          );
                        },
                      ),
              ),
            ChatInputBar(
              controller: _input,
              onSend: _sendMessage,
              onVoiceSend: _sendVoice,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatTopBar extends StatelessWidget {
  final String passengerName;
  const _ChatTopBar({required this.passengerName});

  String get _initials {
    final parts = passengerName.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              passengerName,
              style: AppTextStyles.bodyMedium(
                context,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
