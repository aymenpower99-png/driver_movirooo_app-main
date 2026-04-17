class HelpArticle {
  final String id;
  final String title;
  final String summary;
  final String body;
  final String categoryId;
  final String categoryLabel;

  const HelpArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.categoryId,
    this.categoryLabel = '',
  });

  /// Parse from backend response (already language-resolved).
  factory HelpArticle.fromJson(Map<String, dynamic> json) {
    final desc = (json['description'] ?? '') as String;
    // Split: first sentence = summary, rest = body
    final dotIdx = desc.indexOf('. ');
    final summary = dotIdx > 0 ? desc.substring(0, dotIdx + 1) : desc;
    final body = dotIdx > 0 ? desc.substring(dotIdx + 2) : desc;

    return HelpArticle(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: summary,
      body: body.isNotEmpty ? body : desc,
      categoryId: json['categoryKey'] as String? ?? '',
      categoryLabel: json['categoryLabel'] as String? ?? '',
    );
  }
}