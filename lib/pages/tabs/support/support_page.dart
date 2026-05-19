import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/models/ticket_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/auth_provider.dart';
import '../../../routing/router.dart';
import '../../../services/support/support_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../widgets/tab_bar.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  late Future<TicketListResult> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = SupportService().listMyTickets();
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('MMM d').format(dateTime);
  }

  Future<void> _refreshTickets() async {
    setState(() {
      _ticketsFuture = SupportService().listMyTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).translate;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context, t),
            const SizedBox(height: 24),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshTickets,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel(t('quick_actions')),
                      const SizedBox(height: 8),
                      _buildQuickActionsCard(context, t),
                      const SizedBox(height: 24),
                      _buildSectionLabel(t('messages')),
                      const SizedBox(height: 8),
                      _buildMessagesSection(context, t),
                      const SizedBox(height: 8),
                      _buildViewAllLink(t),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            const DriverTabBar(currentIndex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          t('support_title'),
          style: AppTextStyles.pageTitle(context),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.sectionLabel(context),
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context, dynamic t) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          _QuickActionRow(
            icon: Icons.auto_awesome_rounded,
            title: t('ai_assistant'),
            subtitle: t('ai_assistant_subtitle'),
            onTap: () => Navigator.pushNamed(context, AppRouter.aiChatbot),
          ),
          Divider(height: 1, color: AppColors.border(context), indent: 50),
          _QuickActionRow(
            icon: Icons.confirmation_number_outlined,
            title: t('submit_ticket'),
            subtitle: t('submit_ticket_subtitle'),
            onTap: () => Navigator.pushNamed(context, AppRouter.contactSupport),
          ),
          Divider(height: 1, color: AppColors.border(context), indent: 50),
          _QuickActionRow(
            icon: Icons.help_outline_rounded,
            title: t('help_center'),
            subtitle: t('help_center_subtitle'),
            onTap: () => Navigator.pushNamed(context, AppRouter.helpCenter),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesSection(BuildContext context, dynamic t) {
    return FutureBuilder<TicketListResult>(
      future: _ticketsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _buildMessagesError(context, t, snapshot.error.toString());
        }

        final tickets = snapshot.data?.tickets ?? [];
        if (tickets.isEmpty) {
          return _buildMessagesEmpty(context, t);
        }

        return _buildMessagesCard(context, t, tickets);
      },
    );
  }

  Widget _buildMessagesCard(BuildContext context, dynamic t, List<TicketModel> tickets) {
    final currentUserId = context.read<AuthProvider>().user?.id;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: tickets.asMap().entries.map((entry) {
          final i = entry.key;
          final ticket = entry.value;
          final isLast = i == tickets.length - 1;

          final lastMsg = ticket.messages.isNotEmpty ? ticket.messages.last : null;
          final senderName = lastMsg?.senderName ?? 'Moviroo Support';
          final preview = ticket.lastMessagePreview;
          final time = _formatRelativeTime(ticket.updatedAt);

          // Unread dot only when the last message was sent by support (not by the driver)
          final unread = lastMsg != null && lastMsg.senderId != currentUserId && currentUserId != null;

          return Column(
            children: [
              _MessageRow(
                name: senderName,
                preview: preview,
                time: time,
                unread: unread,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRouter.ticketDetail,
                  arguments: ticket.id,
                ),
              ),
              if (!isLast) Divider(height: 1, color: AppColors.border(context), indent: 50),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessagesEmpty(BuildContext context, dynamic t) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      height: 120,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mark_chat_read_outlined,
              size: 28,
              color: AppColors.subtext(context),
            ),
            const SizedBox(height: 8),
            Text(
              t('chat_no_messages'),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.subtext(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesError(BuildContext context, dynamic t, String error) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 28,
              color: AppColors.subtext(context),
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load tickets',
              style: AppTextStyles.settingsItem(context),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _refreshTickets,
              child: Text(
                'Retry',
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAllLink(dynamic t) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRouter.myTickets),
        child: Text(
          t('view_all_messages'),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryPurple,
          ),
        ),
      ),
    );
  }
}

class _QuickActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryPurple, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.settingsItem(context),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.subtext(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.subtext(context),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  final String name;
  final String preview;
  final String time;
  final bool unread;
  final VoidCallback onTap;

  const _MessageRow({
    required this.name,
    required this.preview,
    required this.time,
    required this.unread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.primaryPurple,
                size: 20,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.settingsItem(context),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.subtext(context),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.subtext(context),
                    ),
                  ),
                  if (unread) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryPurple,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
