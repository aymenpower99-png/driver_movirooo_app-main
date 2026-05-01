import 'package:flutter/material.dart';
import '../core/models/earnings_model.dart';
import '../services/earnings/earnings_service.dart';

class EarningsProvider extends ChangeNotifier {
  final _service = EarningsService();

  EarningsModel? _earnings;
  bool _loading = false;
  String? _error;

  String _selectedMonth = _currentMonth();

  EarningsModel? get earnings => _earnings;
  bool get loading => _loading;
  String? get error => _error;
  String get selectedMonth => _selectedMonth;

  static String _currentMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  String get displayMonth {
    final parts = _selectedMonth.split('-');
    if (parts.length != 2) return _selectedMonth;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = int.tryParse(parts[1]) ?? 1;
    return '${months[m - 1]} ${parts[0]}';
  }

  Future<void> loadEarnings() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _earnings = await _service.getMyEarnings(month: _selectedMonth);
    } catch (e) {
      _error = 'Failed to load earnings: ${e.toString()}';
      debugPrint('❌ [EarningsProvider] Error loading earnings: $e');
    }
    _loading = false;
    notifyListeners();
  }

  void changeMonth(String month) {
    _selectedMonth = month;
    loadEarnings();
  }

  void previousMonth() {
    final parts = _selectedMonth.split('-');
    var year = int.parse(parts[0]);
    var month = int.parse(parts[1]) - 1;
    if (month < 1) {
      month = 12;
      year--;
    }
    changeMonth('$year-${month.toString().padLeft(2, '0')}');
  }

  void nextMonth() {
    final parts = _selectedMonth.split('-');
    var year = int.parse(parts[0]);
    var month = int.parse(parts[1]) + 1;
    if (month > 12) {
      month = 1;
      year++;
    }
    changeMonth('$year-${month.toString().padLeft(2, '0')}');
  }
}
