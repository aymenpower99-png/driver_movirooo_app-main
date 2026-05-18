import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_text_styles.dart';
import '../../../../../l10n/app_localizations.dart';

// ═══════════════════════════════════════════════════════════════════════════
// DRIVER AI CHATBOT — PROFESSIONAL WIDGETS
// Dashboard-style UI adapted for drivers
// ═══════════════════════════════════════════════════════════════════════════

// ── Quick Action Data ─────────────────────────────────────────────────────

class _QuickAction {
  final IconData icon;
  final String title;
  final String query;
  final Color color;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.query,
    required this.color,
  });
}

// ── Compact Header ────────────────────────────────────────────────────────

class DriverAiHeader extends StatelessWidget {
  final bool showFeedback;
  final VoidCallback? onBack;
  final VoidCallback? onFeedback;

  const DriverAiHeader({
    super.key,
    this.showFeedback = false,
    this.onBack,
    this.onFeedback,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).translate;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(
          bottom: BorderSide(color: AppColors.border(context), width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Back button — compact square
            GestureDetector(
              onTap: onBack ?? () => Navigator.maybePop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.bg(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: AppColors.text(context),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Bot badge — square, flat, professional
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.support_agent_rounded,
                color: AppColors.primaryPurple,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Title + status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('ai_page_title'),
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        t('ai_online'),
                        style: AppTextStyles.bodySmall(context).copyWith(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Feedback button
            if (showFeedback)
              GestureDetector(
                onTap: onFeedback,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.bg(context),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: Icon(
                    Icons.star_outline_rounded,
                    size: 18,
                    color: AppColors.text(context),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Actions Grid (2×2) ──────────────────────────────────────────────

class DriverAiQuickActions extends StatelessWidget {
  final Function(String query) onTap;

  const DriverAiQuickActions({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).translate;

    final actions = [
      _QuickAction(
        icon: Icons.local_taxi_outlined,
        title: t('ai_quick_trip'),
        query: t('ai_query_trip'),
        color: const Color(0xFF3B82F6), // blue
      ),
      _QuickAction(
        icon: Icons.account_balance_wallet_outlined,
        title: t('ai_quick_payment'),
        query: t('ai_query_payment'),
        color: const Color(0xFF10B981), // emerald
      ),
      _QuickAction(
        icon: Icons.build_outlined,
        title: t('ai_quick_vehicle'),
        query: t('ai_query_vehicle'),
        color: const Color(0xFFF59E0B), // amber
      ),
      _QuickAction(
        icon: Icons.badge_outlined,
        title: t('ai_quick_account'),
        query: t('ai_query_account'),
        color: const Color(0xFF8B5CF6), // violet
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('ai_quick_actions'),
            style: AppTextStyles.sectionLabel(context).copyWith(
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.4,
            children: actions.map((a) => _buildChip(context, a)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, _QuickAction action) {
    return InkWell(
      onTap: () => onTap(action.query),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(action.icon, color: action.color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                action.title,
                style: AppTextStyles.bodySmall(context).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero Text (compact, no image) ─────────────────────────────────────────

class DriverAiHero extends StatelessWidget {
  const DriverAiHero({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).translate;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('ai_hero_title'),
            style: AppTextStyles.pageTitle(context).copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t('ai_hero_subtitle'),
            style: AppTextStyles.bodySmall(context).copyWith(
              fontSize: 13,
              height: 1.4,
              color: AppColors.subtext(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Professional Input Bar ────────────────────────────────────────────────

class DriverAiInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;

  const DriverAiInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).translate;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(
          top: BorderSide(color: AppColors.border(context), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.bg(context),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: AppTextStyles.bodyMedium(context).copyWith(fontSize: 14),
                  cursorColor: AppColors.primaryPurple,
                  decoration: InputDecoration(
                    hintText: t('ai_input_hint'),
                    hintStyle: AppTextStyles.bodyMedium(context).copyWith(
                      color: AppColors.subtext(context),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: onSend,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Message Bubble (driver style, sharper corners) ────────────────────────

class DriverMessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final double? confidence;
  final bool suggestTicket;
  final VoidCallback? onCreateTicket;

  const DriverMessageBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.confidence,
    this.suggestTicket = false,
    this.onCreateTicket,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                _buildBotAvatar(),
                const SizedBox(width: 8),
              ],
              Flexible(child: _buildBubble(context)),
            ],
          ),
          if (!isUser && confidence != null)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 4),
              child: _buildConfidenceBar(context, confidence!),
            ),
          if (!isUser && suggestTicket)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 8),
              child: _buildTicketChip(context),
            ),
        ],
      ),
    );
  }

  Widget _buildBotAvatar() => Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.support_agent_rounded,
          color: AppColors.primaryPurple,
          size: 16,
        ),
      );

  Widget _buildBubble(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isUser ? AppColors.primaryPurple : AppColors.surface(context),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: Radius.circular(isUser ? 12 : 3),
          bottomRight: Radius.circular(isUser ? 3 : 12),
        ),
        border: isUser
            ? null
            : Border.all(color: AppColors.border(context), width: 1),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium(context).copyWith(
          color: isUser ? Colors.white : AppColors.text(context),
          height: 1.45,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildConfidenceBar(BuildContext context, double confidence) {
    final Color color;
    final String label;
    if (confidence >= 0.82) {
      color = AppColors.success;
      label = 'High confidence';
    } else if (confidence >= 0.55) {
      color = Colors.orange;
      label = 'Medium';
    } else {
      color = Colors.red.shade400;
      label = 'Low confidence';
    }
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            width: 60,
            height: 3,
            child: LinearProgressIndicator(
              value: confidence.clamp(0.0, 1.0),
              backgroundColor: AppColors.border(context),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall(context).copyWith(
            fontSize: 10,
            color: AppColors.subtext(context),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketChip(BuildContext context) {
    return GestureDetector(
      onTap: onCreateTicket,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.bg(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.headset_mic_outlined,
              size: 14,
              color: AppColors.primaryPurple,
            ),
            const SizedBox(width: 6),
            Text(
              'Contact a support agent',
              style: AppTextStyles.bodySmall(context).copyWith(
                fontSize: 12,
                color: AppColors.primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Typing Indicator (compact, driver style) ──────────────────────────────

class DriverTypingIndicator extends StatelessWidget {
  const DriverTypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.support_agent_rounded,
              color: AppColors.primaryPurple,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
                bottomLeft: Radius.circular(3),
              ),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => _DriverTypingDot(delay: Duration(milliseconds: i * 160)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverTypingDot extends StatefulWidget {
  final Duration delay;
  const _DriverTypingDot({required this.delay});

  @override
  State<_DriverTypingDot> createState() => _DriverTypingDotState();
}

class _DriverTypingDotState extends State<_DriverTypingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Color.lerp(
              AppColors.border(context),
              AppColors.primaryPurple,
              _anim.value,
            ),
            shape: BoxShape.circle,
          ),
        ),
      );
}
