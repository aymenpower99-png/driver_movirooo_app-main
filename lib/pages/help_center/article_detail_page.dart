import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import 'models/help_article.dart';

class ArticleDetailPage extends StatelessWidget {
  final HelpArticle article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        leading: Padding(
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
        ),
        title: Text(
          AppLocalizations.of(context).translate('help_article_title'),
          style: AppTextStyles.pageTitle(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Title
            Text(
              article.title,
              style: AppTextStyles.pageTitle(context).copyWith(fontSize: 20),
            ),

            const SizedBox(height: 8),

            // Summary
            Text(
              article.summary,
              style: AppTextStyles.settingsItem(
                context,
              ).copyWith(color: AppColors.subtext(context), fontSize: 13),
            ),

            const SizedBox(height: 20),

            Divider(color: AppColors.border(context), height: 1),

            const SizedBox(height: 20),

            // Body
            Text(
              article.body,
              style: AppTextStyles.settingsItem(context).copyWith(height: 1.6),
            ),

            const SizedBox(height: 40),

            // Was this helpful?
            _HelpfulFeedback(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Was this helpful? ──────────────────────────────────────────────────────────

class _HelpfulFeedback extends StatefulWidget {
  @override
  State<_HelpfulFeedback> createState() => _HelpfulFeedbackState();
}

class _HelpfulFeedbackState extends State<_HelpfulFeedback> {
  bool? _voted; // true = yes, false = no

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('help_article_helpful'),
            style: AppTextStyles.settingsItem(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (_voted == null)
            Row(
              children: [
                _VoteButton(
                  label: AppLocalizations.of(
                    context,
                  ).translate('help_vote_yes'),
                  icon: Icons.thumb_up_outlined,
                  onTap: () => setState(() => _voted = true),
                ),
                const SizedBox(width: 10),
                _VoteButton(
                  label: AppLocalizations.of(context).translate('help_vote_no'),
                  icon: Icons.thumb_down_outlined,
                  onTap: () => setState(() => _voted = false),
                ),
              ],
            )
          else
            Text(
              _voted!
                  ? AppLocalizations.of(context).translate('help_vote_thanks')
                  : AppLocalizations.of(context).translate('help_vote_improve'),
              style: AppTextStyles.settingsItem(
                context,
              ).copyWith(color: AppColors.subtext(context), fontSize: 13),
            ),
        ],
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _VoteButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bg(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border(context), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.subtext(context)),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.settingsItem(
                context,
              ).copyWith(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
