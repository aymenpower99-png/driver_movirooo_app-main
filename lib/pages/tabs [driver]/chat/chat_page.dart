import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '_ChatMessage.dart';
import '_ChatInput.dart';
import '_TranslationBanner.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _input = TextEditingController();
  bool _autoTranslate = true;

  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      text: 'مرحباً، أنا في طريقي، سأكون هناك خلال 5 دقائق.',
      translatedText: "Hello, I'm on my way. I'll be there in 5 minutes.",
      isMe: false,
      time: '2:41 PM',
      isArabic: true,
    ),
    ChatMessage(
      id: '2',
      text: "Great, thanks! I'm waiting near the main entrance.",
      translatedText: null,
      isMe: true,
      time: '2:43 PM',
      isArabic: false,
    ),
    ChatMessage(
      id: '3',
      text: 'حسناً، أراك قريباً.',
      translatedText: 'Okay, see you soon.',
      isMe: false,
      time: '2:44 PM',
      isArabic: true,
    ),
    ChatMessage(
      id: '4',
      text: 'وصلت إلى المدخل الرئيسي.',
      translatedText: "I'll arrive at the main entrance.",
      isMe: false,
      time: '2:45 PM',
      isArabic: true,
    ),
  ];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        translatedText: null,
        isMe: true,
        time: _formatTime(DateTime.now()),
        isArabic: false,
      ));
    });
    _input.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
    _scroll.dispose();
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [

            // ── TopBar ─────────────────────────────────────────
            _ChatTopBar(),

            // ── Translation banner ─────────────────────────────
            TranslationBanner(
              enabled: _autoTranslate,
              onToggle: (v) => setState(() => _autoTranslate = v),
            ),

            // ── Date separator ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Today, 2:41 PM',
                style: AppTextStyles.bodySmall(context).copyWith(
                  color: AppColors.subtext(context),
                  fontSize: 11,
                ),
              ),
            ),

            // ── Messages ───────────────────────────────────────
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _messages.length,
                itemBuilder: (context, i) => ChatBubble(
                  message: _messages[i],
                  showTranslation: _autoTranslate,
                ),
              ),
            ),

            // ── Input ──────────────────────────────────────────
            ChatInputBar(
              controller: _input,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatTopBar extends StatelessWidget {
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
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryPurple.withOpacity(0.15),
            child: Icon(Icons.person_rounded,
                color: AppColors.primaryPurple, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ahmed H.',
                    style: AppTextStyles.bodyMedium(context)
                        .copyWith(fontWeight: FontWeight.w700)),
                Text('Toyota Camry b7 · 4.9 b7 b7',
                    style: AppTextStyles.bodySmall(context)
                        .copyWith(color: AppColors.subtext(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
