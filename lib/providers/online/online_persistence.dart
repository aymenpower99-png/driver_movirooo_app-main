import 'package:shared_preferences/shared_preferences.dart';
import 'online_time_tracking.dart';

/// Persistence logic for OnlineProvider.
/// Handles loading/saving time data from SharedPreferences.
class OnlinePersistence {
  final OnlineTimeTracking _timeTracking;

  OnlinePersistence(this._timeTracking);

  static const _kTodayMs = 'online_today_ms';
  static const _kAllTimeMs = 'online_alltime_ms';
  static const _kDate = 'online_date';
  // Legacy keys — read once for migration, then cleared
  static const _kLegacyMonthMs = 'online_month_ms';
  static const _kLegacyMonth = 'online_month';

  Future<void> loadPersistedTime() async {
    final prefs = await SharedPreferences.getInstance();
    _timeTracking.allTimeOnlineMs = prefs.getInt(_kAllTimeMs) ?? 0;
    _timeTracking.storedDate = prefs.getString(_kDate) ?? '';

    final today = _timeTracking.todayStr;
    if (_timeTracking.storedDate != today) {
      _timeTracking.todayOnlineMs = 0;
      await prefs.setInt(_kTodayMs, 0);
      await prefs.setString(_kDate, today);
      _timeTracking.storedDate = today;
    } else {
      _timeTracking.todayOnlineMs = prefs.getInt(_kTodayMs) ?? 0;
    }

    // Read legacy monthly keys for one-time migration
    _timeTracking.legacyMonthMs = prefs.getInt(_kLegacyMonthMs) ?? 0;
    _timeTracking.legacyMonth = prefs.getString(_kLegacyMonth) ?? '';
  }

  Future<void> persistTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTodayMs, _timeTracking.todayOnlineMs);
    await prefs.setInt(_kAllTimeMs, _timeTracking.allTimeOnlineMs);
    await prefs.setString(_kDate, _timeTracking.todayStr);
  }

  /// Clear legacy migration keys after successful migration
  Future<void> clearLegacyKeys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLegacyMonthMs);
    await prefs.remove(_kLegacyMonth);
    _timeTracking.legacyMonthMs = 0;
    _timeTracking.legacyMonth = '';
  }
}
