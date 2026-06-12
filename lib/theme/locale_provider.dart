import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/notifications/notification_service.dart';

class LocaleProvider extends ChangeNotifier {
  static const _key = 'app_locale';
  Locale _locale = const Locale('en');
  bool _isLoaded = false;

  Locale get locale => _locale;
  bool get isLoaded => _isLoaded;

  LocaleProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null && _isSupported(code)) {
      _locale = Locale(code);
    }
    _isLoaded = true;
    // Update notification service with loaded language
    await NotificationService.instance.setLanguage(_locale.languageCode);
    notifyListeners();
  }

  bool _isSupported(String code) => ['en', 'fr', 'ar'].contains(code);

  Future<void> setLocale(Locale locale) async {
    if (!_isSupported(locale.languageCode)) return;
    _locale = locale;
    // Update notification service with new language
    await NotificationService.instance.setLanguage(locale.languageCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }

  Future<void> setLocaleByCode(String code) => setLocale(Locale(code));
}
