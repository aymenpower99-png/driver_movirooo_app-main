/// Time tracking logic for OnlineProvider.
/// Handles session time, monthly time, and formatting.
class OnlineTimeTracking {
  // ── Session tracking ──────────────────────────────────────────────────────
  DateTime? _lastOnlineAt;

  // ── Monthly time: SOURCE OF TRUTH is the backend DB ──────────────────────
  /// Accumulated ms from past sessions this month (loaded from backend).
  int _backendMonthlyMs = 0;

  // ── Persisted time counters (today + all-time only, milliseconds) ─────────
  int _todayOnlineMs = 0;
  int _allTimeOnlineMs = 0;
  String _storedDate = ''; // 'YYYY-MM-DD'

  // ── Legacy migration (old SharedPreferences monthly data) ─────────────────
  int _legacyMonthMs = 0;
  String _legacyMonth = '';

  // Getters
  DateTime? get lastOnlineAt => _lastOnlineAt;
  int get backendMonthlyMs => _backendMonthlyMs;
  int get todayOnlineMs => _todayOnlineMs;
  int get allTimeOnlineMs => _allTimeOnlineMs;
  String get storedDate => _storedDate;
  int get legacyMonthMs => _legacyMonthMs;
  String get legacyMonth => _legacyMonth;

  // Setters
  set lastOnlineAt(DateTime? value) => _lastOnlineAt = value;
  set backendMonthlyMs(int value) => _backendMonthlyMs = value;
  set todayOnlineMs(int value) => _todayOnlineMs = value;
  set allTimeOnlineMs(int value) => _allTimeOnlineMs = value;
  set storedDate(String value) => _storedDate = value;
  set legacyMonthMs(int value) => _legacyMonthMs = value;
  set legacyMonth(String value) => _legacyMonth = value;

  /// Milliseconds elapsed in the current online session (0 if offline).
  int getSessionMs(bool isOnline) {
    if (!isOnline || _lastOnlineAt == null) return 0;
    return DateTime.now().difference(_lastOnlineAt!).inMilliseconds;
  }

  /// Today's total online time including current live session.
  String getTodayFormatted(int sessionMs) => _fmtMs(_todayOnlineMs + sessionMs);

  /// Monthly total online time including current live session.
  /// Uses backend-persisted value as the base — survives reinstalls/cache clears.
  String getMonthFormatted(int sessionMs) =>
      _fmtMs(_backendMonthlyMs + sessionMs);

  /// All-time total online time including current live session.
  String getAllTimeFormatted(int sessionMs) =>
      _fmtMs(_allTimeOnlineMs + sessionMs);

  String _fmtMs(int ms) {
    final d = Duration(milliseconds: ms);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  String get todayStr {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  String get monthStr {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}';
  }

  /// Add session time to counters when going offline
  void addSessionTime(int sessionMs) {
    _todayOnlineMs += sessionMs;
    _allTimeOnlineMs += sessionMs;
    _lastOnlineAt = null;
  }
}
