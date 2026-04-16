import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/ticket_model.dart';
import '../../routing/router.dart';
import '../../services/support_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  final SupportService _service = SupportService();
  final List<TicketModel> _tickets = [];
  bool _loading = true;
  bool _hasMore = true;
  int _page = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final result = await _service.listMyTickets(page: _page);
      setState(() {
        _tickets.addAll(result.tickets);
        _hasMore = _tickets.length < result.total;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load tickets';
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    _tickets.clear();
    _page = 1;
    _hasMore = true;
    await _load();
  }

  void _loadMore() {
    if (!_loading && _hasMore) {
      _page++;
      _load();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        leading: _backButton(context),
        title: Text('My Tickets', style: AppTextStyles.pageTitle(context)),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _tickets.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple));
    }
    if (_error != null && _tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.subtext(context)),
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: AppColors.subtext(context))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refresh,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
    if (_tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.confirmation_num_outlined, size: 56, color: AppColors.subtext(context)),
            const SizedBox(height: 12),
            Text('No tickets yet', style: TextStyle(color: AppColors.subtext(context), fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryPurple,
      onRefresh: _refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll.metrics.pixels > scroll.metrics.maxScrollExtent - 200) {
            _loadMore();
          }
          return false;
        },
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _tickets.length + (_hasMore ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            if (i >= _tickets.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator(color: AppColors.primaryPurple, strokeWidth: 2)),
              );
            }
            return _TicketCard(
              ticket: _tickets[i],
              onTap: () async {
                await AppRouter.push(context, AppRouter.ticketDetail, args: _tickets[i].id);
                _refresh(); // refresh status after returning
              },
            );
          },
        ),
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
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text(context), size: 18),
        ),
      ),
    );
  }
}

// ── Ticket Card ──────────────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;
  const _TicketCard({required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ts = DateFormat('MMM d, yyyy · HH:mm').format(ticket.updatedAt);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: subject + status badge ──
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket.subject,
                    style: AppTextStyles.settingsItem(context).copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(status: ticket.status),
              ],
            ),
            const SizedBox(height: 8),

            // ── Preview ──
            Text(
              ticket.lastMessagePreview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.subtext(context), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 10),

            // ── Timestamp ──
            Row(
              children: [
                Icon(Icons.access_time, size: 13, color: AppColors.subtext(context)),
                const SizedBox(width: 4),
                Text(ts, style: TextStyle(color: AppColors.subtext(context), fontSize: 11)),
              ],
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: status.color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
