import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/models/ticket_model.dart';
import '../../core/widgets/app_toast.dart';
import '../../providers/auth_provider.dart';
import '../../services/support/support_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class TicketDetailPage extends StatefulWidget {
  const TicketDetailPage({super.key});

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  final SupportService _service = SupportService();
  final TextEditingController _replyCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  TicketModel? _ticket;
  bool _loading = true;
  bool _sending = false;
  String? _error;

  String get _ticketId => ModalRoute.of(context)!.settings.arguments as String;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ticket == null) _loadTicket();
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTicket() async {
    setState(() => _loading = true);
    try {
      final t = await _service.getTicket(_ticketId);
      setState(() {
        _ticket = t;
        _loading = false;
        _error = null;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _error = 'Failed to load ticket';
        _loading = false;
      });
    }
  }

  Future<void> _sendReply() async {
    final text = _replyCtrl.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      await _service.replyToTicket(_ticketId, text);
      _replyCtrl.clear();
      await _loadTicket();
    } catch (_) {
      if (mounted) {
        AppToast.error(context, 'Failed to send reply');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: _appBar(context),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPurple),
            )
          : _error != null
          ? _errorWidget()
          : Column(
              children: [
                Expanded(child: _messageList(context)),
                if (_ticket!.status != TicketStatus.resolved)
                  _replyBar(context),
              ],
            ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bg(context),
      elevation: 0,
      leading: _backButton(context),
      title: _ticket != null
          ? Column(
              children: [
                Text(
                  _ticket!.subject,
                  style: AppTextStyles.pageTitle(
                    context,
                  ).copyWith(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                _StatusBadge(status: _ticket!.status),
              ],
            )
          : Text('Ticket', style: AppTextStyles.pageTitle(context)),
      centerTitle: true,
      toolbarHeight: 64,
    );
  }

  Widget _errorWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.subtext(context),
          ),
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: AppColors.subtext(context))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadTicket,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Message List ──────────────────────────────────────────────────────────

  Widget _messageList(BuildContext context) {
    final userId = context.read<AuthProvider>().user?.id ?? '';
    final messages = _ticket!.messages;

    if (messages.isEmpty) {
      return ListView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _DescriptionBubble(
            description: _ticket!.description,
            createdAt: _ticket!.createdAt,
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, i) {
        final msg = messages[i];
        final isMe = msg.senderId == userId;
        return _MessageBubble(message: msg, isMe: isMe);
      },
    );
  }

  // ── Reply Bar ─────────────────────────────────────────────────────────────

  Widget _replyBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(top: BorderSide(color: AppColors.border(context))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyCtrl,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendReply(),
              decoration: InputDecoration(
                hintText: 'Type your reply...',
                hintStyle: TextStyle(
                  color: AppColors.subtext(context),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: AppColors.bg(context),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          _sending
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: AppColors.primaryPurple,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : IconButton(
                  onPressed: _sendReply,
                  icon: const Icon(
                    Icons.send_rounded,
                    color: AppColors.primaryPurple,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.text(context),
            size: 18,
          ),
        ),
      ),
    );
  }
}

// ── Message Bubble ──────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final TicketMessageModel message;
  final bool isMe;
  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(message.createdAt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.15),
              child: const Icon(
                Icons.support_agent,
                size: 16,
                color: AppColors.primaryPurple,
              ),
            ),
            const SizedBox(width: 8),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            child: IntrinsicWidth(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isMe
                      ? AppColors.primaryPurple
                      : AppColors.surface(context),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                  border: isMe
                      ? null
                      : Border.all(color: AppColors.border(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.body,
                      style: TextStyle(
                        color: isMe ? Colors.white : AppColors.text(context),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: TextStyle(
                            color: isMe
                                ? Colors.white70
                                : AppColors.subtext(context),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Description Bubble (shown when no messages yet) ─────────────────────────

class _DescriptionBubble extends StatelessWidget {
  final String description;
  final DateTime createdAt;
  const _DescriptionBubble({
    required this.description,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('MMM d, yyyy · HH:mm').format(createdAt);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Initial Message',
            style: TextStyle(
              color: AppColors.subtext(context),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: AppColors.text(context),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: TextStyle(color: AppColors.subtext(context), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── Status Badge ────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final TicketStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
