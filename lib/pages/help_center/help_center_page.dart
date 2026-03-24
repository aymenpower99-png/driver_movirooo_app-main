import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import 'article_detail_page.dart';
import 'constants/help_data.dart';
import 'models/help_article.dart';
import 'widgets/article_list_tile.dart';
import 'widgets/category_chip_row.dart';
import 'widgets/contact_support_banner.dart';
import 'widgets/help_search_bar.dart';
import 'widgets/section_header.dart';

class HelpCenterPage extends StatefulWidget {
  /// Optional: provide a callback to navigate to ContactSupportPage.
  final VoidCallback? onContactSupport;

  const HelpCenterPage({super.key, this.onContactSupport});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _selectedCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Filtering ──────────────────────────────────────────────────────────────

  List<HelpArticle> get _filteredArticles {
    return kHelpArticles.where((article) {
      final matchesCategory =
          _selectedCategoryId == null ||
          article.categoryId == _selectedCategoryId;
      final q = _query.trim().toLowerCase();
      final matchesSearch =
          q.isEmpty ||
          article.title.toLowerCase().contains(q) ||
          article.summary.toLowerCase().contains(q);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  bool get _isSearching => _query.trim().isNotEmpty;

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _openArticle(HelpArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ArticleDetailPage(article: article)),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final articles = _filteredArticles;
    final t = AppLocalizations.of(context).translate;

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
                    color: Colors.black.withOpacity(0.06),
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
          t('help_center_title'),
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

            // ── SEARCH ───────────────────────────────────────────────────────
            SectionHeader(label: t('help_section_search')),
            const SizedBox(height: 12),

            HelpSearchBar(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
            ),

            const SizedBox(height: 28),

            // ── CATEGORIES (hidden during active search) ──────────────────
            if (!_isSearching) ...[
              SectionHeader(label: t('help_section_categories')),
              const SizedBox(height: 12),

              CategoryChipRow(
                categories: kHelpCategories,
                selectedId: _selectedCategoryId,
                onSelected: (id) => setState(() => _selectedCategoryId = id),
              ),

              const SizedBox(height: 28),
            ],

            // ── ARTICLES ──────────────────────────────────────────────────
            SectionHeader(
              label: _isSearching
                  ? '${t('help_results_label')} (${articles.length})'
                  : _selectedCategoryId == null
                  ? t('help_section_all_articles')
                  : kHelpCategories
                        .firstWhere((c) => c.id == _selectedCategoryId)
                        .title
                        .toUpperCase(),
            ),
            const SizedBox(height: 12),

            if (articles.isEmpty)
              _EmptyState(query: _query)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: articles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => ArticleListTile(
                  article: articles[i],
                  onTap: () => _openArticle(articles[i]),
                ),
              ),

            const SizedBox(height: 28),

            // ── CONTACT SUPPORT BANNER ────────────────────────────────────
            ContactSupportBanner(
              onTap: widget.onContactSupport ?? () => Navigator.pop(context),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String query;

  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 40,
              color: AppColors.subtext(context),
            ),
            const SizedBox(height: 12),
            Text(
              query.isNotEmpty
                  ? '${AppLocalizations.of(context).translate('help_no_results')} "$query"'
                  : AppLocalizations.of(context).translate('help_no_articles'),
              style: AppTextStyles.settingsItem(
                context,
              ).copyWith(color: AppColors.subtext(context)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
