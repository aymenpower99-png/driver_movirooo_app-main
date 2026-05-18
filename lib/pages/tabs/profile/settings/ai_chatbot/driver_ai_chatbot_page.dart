import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_text_styles.dart';
import '../../../../../services/ai_chatbot/moviroo_api_service.dart';
import 'driver_ai_chatbot_widgets.dart';

// ═══════════════════════════════════════════════════════════════════════════
// DRIVER AI CHATBOT PAGE
// Same logic as passenger chatbot, professional dashboard-style UI.
// ═══════════════════════════════════════════════════════════════════════════

enum MessageSender { user, bot }

class ChatMessage {
  final String text;
  final MessageSender sender;
  final double? confidence;
  final bool suggestTicket;
  final String? ticketId;
  final String source;

  const ChatMessage({
    required this.text,
    required this.sender,
    this.confidence,
    this.suggestTicket = false,
    this.ticketId,
    this.source = '',
  });
}

class DriverAiChatbotPage extends StatefulWidget {
  const DriverAiChatbotPage({super.key});

  @override
  State<DriverAiChatbotPage> createState() => _DriverAiChatbotPageState();
}

class _DriverAiChatbotPageState extends State<DriverAiChatbotPage>
    with TickerProviderStateMixin {
  // ── Controllers ─────────────────────────────────────────────
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final MovirooApi _api = MovirooApi();

  // ── State ────────────────────────────────────────────────────
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _showChat = false; // false = home screen, true = chat screen
  String? _lastTicketId;

  // ── Animation ────────────────────────────────────────────────
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;

  // ── Lifecycle ────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ── Handlers ─────────────────────────────────────────────────

  void _handleQuickActionTap(String query) {
    _controller.text = query;
    _focusNode.requestFocus();
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isTyping) return;

    _controller.clear();
    _focusNode.unfocus();

    if (!_showChat) {
      setState(() => _showChat = true);
    }

    setState(() {
      _messages.add(ChatMessage(text: text, sender: MessageSender.user));
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final res = await _api.chat(text);
      if (!mounted) return;

      if (res.ticketId != null) _lastTicketId = res.ticketId;

      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: res.answer,
          sender: MessageSender.bot,
          confidence: res.confidence,
          suggestTicket: res.suggestTicket,
          ticketId: res.ticketId,
          source: res.source,
        ));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(const ChatMessage(
          text: 'Connection error. Please check your network and try again.',
          sender: MessageSender.bot,
          source: 'error',
        ));
      });
    }
    _scrollToBottom();
  }

  Future<void> _handleCreateTicket(String question) async {
    try {
      final ticket = await _api.createTicket(question: question);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ticket created: ${ticket.ticketId}'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Failed to create ticket. Try again.'),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  Future<void> _handleFeedback(int rating) async {
    try {
      await _api.submitFeedback(
        rating: rating,
        ticketId: _lastTicketId,
        helpful: rating >= 4,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Thank you for your feedback!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ));
    } catch (_) {}
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showFeedbackDialog() {
    int selected = 0;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppColors.surface(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Rate this conversation',
            style: AppTextStyles.bodyLarge(context)
                .copyWith(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How helpful was the support?',
                  style: AppTextStyles.bodySmall(context)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => GestureDetector(
                    onTap: () => setS(() => selected = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        i < selected ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: AppTextStyles.bodySmall(context)
                      .copyWith(color: AppColors.subtext(context))),
            ),
            ElevatedButton(
              onPressed: selected > 0
                  ? () {
                      Navigator.pop(ctx);
                      _handleFeedback(selected);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            // Header
            DriverAiHeader(
              showFeedback: _showChat,
              onBack: () {
                if (_showChat) {
                  setState(() => _showChat = false);
                } else {
                  Navigator.maybePop(context);
                }
              },
              onFeedback: _showFeedbackDialog,
            ),

            // Body
            Expanded(
              child: _showChat
                  ? _buildChatView(context)
                  : _buildHomeView(context),
            ),

            // Input
            DriverAiInputBar(
              controller: _controller,
              focusNode: _focusNode,
              onSend: _handleSend,
            ),
          ],
        ),
      ),
    );
  }

  // ── Home view ─────────────────────────────────────────────────

  Widget _buildHomeView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DriverAiHero(),
          const SizedBox(height: 24),
          DriverAiQuickActions(onTap: _handleQuickActionTap),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Chat view ─────────────────────────────────────────────────

  Widget _buildChatView(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == _messages.length) return const DriverTypingIndicator();
        final msg = _messages[i];
        return DriverMessageBubble(
          text: msg.text,
          isUser: msg.sender == MessageSender.user,
          confidence: msg.confidence,
          suggestTicket: msg.suggestTicket,
          onCreateTicket: msg.suggestTicket
              ? () => _handleCreateTicket(msg.text)
              : null,
        );
      },
    );
  }
}
