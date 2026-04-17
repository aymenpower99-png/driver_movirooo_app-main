import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';
import '../pages/help_center/models/help_article.dart';

class HelpCenterService {
  final _dio = ApiClient.instance.dio;

  /// Fetches help center articles from the backend for the given language.
  /// Falls back to 'en' on the server side if the language isn't available.
  Future<List<HelpArticle>> getArticles({String lang = 'en'}) async {
    final res = await _dio.get(
      Endpoints.helpCenter,
      queryParameters: {'lang': lang},
    );
    final list = res.data as List<dynamic>;
    return list
        .map((e) => HelpArticle.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
