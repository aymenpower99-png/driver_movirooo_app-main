import 'package:flutter/material.dart';
import 'dart:async';
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
  // Tracks when the driver last opened a ticket to compute unread state locally
  final Map<String, DateTime> _lastReadAt = {};
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = SupportService().listMyTickets();
    // Rebuild periodically so relative timestamps update automatically
    _ticker = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    Duration diff = now.difference(dateTime);
    if (diff.isNegative)
      diff = Duration.zero; // guard against clock skew / future timestamps
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) {
      final m = diff.inMinutes;
      return m == 1 ? '1 min ago' : '$m min ago';
    }
    if (diff.inDays < 1) {
      final h = diff.inHours;
      return h == 1 ? '1 hour ago' : '$h hours ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(dateTime);
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

  Widget _buildMessagesCard(
    BuildContext context,
    dynamic t,
    List<TicketModel> tickets,
  ) {
    final currentUserId = context.read<AuthProvider>().user?.id;

    // Show only the 3 most recent tickets
    final recentTickets = tickets.take(3).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: recentTickets.asMap().entries.map((entry) {
          final i = entry.key;
          final ticket = entry.value;
          final isLast = i == recentTickets.length - 1;

          // Ensure we truly get the latest message by createdAt (backend order may vary)
          final lastMsg = ticket.messages.isNotEmpty
              ? (List<TicketMessageModel>.from(
                  ticket.messages,
                )..sort((a, b) => a.createdAt.compareTo(b.createdAt))).last
              : null;

          // Extract first name from sender name and add role label
          String senderName = lastMsg?.senderName?.trim() ?? '';
          // Filter out "Moviroo" if it appears in the name
          if (senderName.toLowerCase().contains('moviroo')) {
            senderName = '';
          }
          if (senderName.isEmpty) {
            // Fallback if no sender name available
            senderName = t('customer_support');
          } else if (senderName.contains(' ')) {
            final parts = senderName.split(' ');
            senderName = '${parts[0]} (${t('customer_support')})';
          } else {
            senderName = '$senderName (${t('customer_support')})';
          }

          final preview = ticket.lastMessagePreview;
          final time = _formatRelativeTime(ticket.updatedAt);

          // Localized status label for closed tickets (shown on the right side)
          final String? statusLabel = ticket.status == TicketStatus.resolved
              ? t('ticket_closed')
              : null;

          // Prefer backend status to infer unread; fall back to local last-read time.
          final lastRead = _lastReadAt[ticket.id];
          final unread =
              currentUserId != null &&
              ticket.status == TicketStatus.waitingForUser &&
              (lastRead == null || ticket.updatedAt.isAfter(lastRead));

          // Debug: verify unread flag at render time
          // ignore: avoid_print
          print(
            'SupportPage unread? ticket=${ticket.id} status=${ticket.status} '
            'updatedAt=${ticket.updatedAt.toIso8601String()} currentUser=$currentUserId '
            'lastRead=$lastRead computedUnread=$unread (messagesPresent=${ticket.messages.isNotEmpty})',
          );

          return Column(
            children: [
              _MessageRow(
                name: senderName,
                preview: preview,
                time: time,
                unread: unread,
                statusLabel: statusLabel,
                updatedAt: ticket.updatedAt,
                onTap: () async {
                  // Capture the moment the conversation was opened.
                  final openedAt = DateTime.now();
                  await Navigator.pushNamed(
                    context,
                    AppRouter.ticketDetail,
                    arguments: ticket.id,
                  );
                  // Mark as read using the open time to avoid race conditions.
                  if (mounted) {
                    setState(() {
                      _lastReadAt[ticket.id] = openedAt;
                    });
                    // Refresh tickets to reflect any server-side updates too
                    _refreshTickets();
                  }
                },
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: AppColors.border(context),
                  indent: 50,
                ),
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
                    Text(title, style: AppTextStyles.settingsItem(context)),
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
  final String? statusLabel;
  final DateTime updatedAt;
  final VoidCallback onTap;

  const _MessageRow({
    required this.name,
    required this.preview,
    required this.time,
    required this.unread,
    this.statusLabel,
    required this.updatedAt,
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
              if (unread) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryPurple,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
              ],
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
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.settingsItem(context).copyWith(
                        fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
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
                  if (statusLabel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border(context)),
                      ),
                      child: Text(
                        statusLabel!,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: AppColors.subtext(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    _RelativeTimeText(updatedAt: updatedAt),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RelativeTimeText extends StatefulWidget {
  final DateTime updatedAt;
  const _RelativeTimeText({required this.updatedAt});

  @override
  State<_RelativeTimeText> createState() => _RelativeTimeTextState();
}

class _RelativeTimeTextState extends State<_RelativeTimeText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(DateTime dt) {
    final base = dt.isUtc ? dt.toLocal() : dt;
    final now = DateTime.now();
    final diff = now.difference(base);
    final absSeconds = diff.inSeconds.abs();
    if (absSeconds < 60) return 'Just now';
    if (absSeconds < 3600) {
      final m = diff.inMinutes.abs();
      return m == 1 ? '1 min ago' : '$m min ago';
    }
    if (absSeconds < 86400) {
      final h = diff.inHours.abs();
      return h == 1 ? '1 hour ago' : '$h hours ago';
    }
    final d = diff.inDays.abs();
    if (d == 1) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(base);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _format(widget.updatedAt),
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.subtext(context),
      ),
    );
  }
}
