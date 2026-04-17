class EarningsModel {
  final double baseSalary;
  final double commission;
  final int missedDays;
  final double deductionAmount;
  final double total;
  final int expectedWorkDays;
  final int attendance;
  final int ridesCompleted;
  final int ridesAccepted;
  final int ridesCancelled;
  final int ridesThreshold;
  final int ridesLeftForCommission;
  final List<WeeklyData> weekly;

  const EarningsModel({
    required this.baseSalary,
    required this.commission,
    required this.missedDays,
    required this.deductionAmount,
    required this.total,
    required this.expectedWorkDays,
    required this.attendance,
    required this.ridesCompleted,
    required this.ridesAccepted,
    required this.ridesCancelled,
    required this.ridesThreshold,
    required this.ridesLeftForCommission,
    required this.weekly,
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    final deductions = json['deductions'] as Map<String, dynamic>? ?? {};
    final stats = json['stats'] as Map<String, dynamic>? ?? {};
    final weeklyList = (json['weekly'] as List<dynamic>? ?? [])
        .map((w) => WeeklyData.fromJson(w as Map<String, dynamic>))
        .toList();

    return EarningsModel(
      baseSalary: (json['baseSalary'] as num?)?.toDouble() ?? 0,
      commission: (json['commission'] as num?)?.toDouble() ?? 0,
      missedDays: (deductions['missedDays'] as num?)?.toInt() ?? 0,
      deductionAmount: (deductions['amount'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      expectedWorkDays: (stats['expectedWorkDays'] as num?)?.toInt() ?? 22,
      attendance: (stats['attendance'] as num?)?.toInt() ?? 0,
      ridesCompleted: (stats['ridesCompleted'] as num?)?.toInt() ?? 0,
      ridesAccepted: (stats['ridesAccepted'] as num?)?.toInt() ?? 0,
      ridesCancelled: (stats['ridesCancelled'] as num?)?.toInt() ?? 0,
      ridesThreshold: (stats['ridesThreshold'] as num?)?.toInt() ?? 100,
      ridesLeftForCommission:
          (stats['ridesLeftForCommission'] as num?)?.toInt() ?? 0,
      weekly: weeklyList,
    );
  }
}

class WeeklyData {
  final int week;
  final double salary;
  final double commission;
  final int rides;

  const WeeklyData({
    required this.week,
    required this.salary,
    required this.commission,
    required this.rides,
  });

  factory WeeklyData.fromJson(Map<String, dynamic> json) => WeeklyData(
        week: (json['week'] as num?)?.toInt() ?? 0,
        salary: (json['salary'] as num?)?.toDouble() ?? 0,
        commission: (json['commission'] as num?)?.toDouble() ?? 0,
        rides: (json['rides'] as num?)?.toInt() ?? 0,
      );
}
