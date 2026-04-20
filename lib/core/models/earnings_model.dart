class TierProgress {
  final String tierId;
  final String tierName;
  final int requiredRides;
  final double bonusAmount;
  final bool reached;

  const TierProgress({
    required this.tierId,
    required this.tierName,
    required this.requiredRides,
    required this.bonusAmount,
    required this.reached,
  });

  factory TierProgress.fromJson(Map<String, dynamic> json) => TierProgress(
        tierId: json['tierId'] as String? ?? '',
        tierName: json['tierName'] as String? ?? '',
        requiredRides: (json['requiredRides'] as num?)?.toInt() ?? 0,
        bonusAmount: (json['bonusAmount'] as num?)?.toDouble() ?? 0,
        reached: json['reached'] as bool? ?? false,
      );
}

class DailyRides {
  final String day;
  final int rides;

  const DailyRides({required this.day, required this.rides});

  factory DailyRides.fromJson(Map<String, dynamic> json) => DailyRides(
        day: json['day'] as String? ?? '',
        rides: (json['rides'] as num?)?.toInt() ?? 0,
      );
}

class EarningsModel {
  final double salary;
  final double commission;
  final double netEarnings;
  final int ridesCompleted;
  final List<TierProgress> tiers;
  final String? nextTierName;
  final int? nextTierRidesNeeded;
  final List<DailyRides> dailyRides;

  const EarningsModel({
    required this.salary,
    required this.commission,
    required this.netEarnings,
    required this.ridesCompleted,
    this.tiers = const [],
    this.nextTierName,
    this.nextTierRidesNeeded,
    this.dailyRides = const [],
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    final tiersList = (json['tiers'] as List<dynamic>? ?? [])
        .map((t) => TierProgress.fromJson(t as Map<String, dynamic>))
        .toList();
    final dailyList = (json['dailyRides'] as List<dynamic>? ?? [])
        .map((d) => DailyRides.fromJson(d as Map<String, dynamic>))
        .toList();
    final nextTier = json['nextTier'] as Map<String, dynamic>?;

    return EarningsModel(
      salary: (json['salary'] as num?)?.toDouble() ?? 0,
      commission: (json['commission'] as num?)?.toDouble() ?? 0,
      netEarnings: (json['netEarnings'] as num?)?.toDouble() ?? 0,
      ridesCompleted: (json['ridesCompleted'] as num?)?.toInt() ?? 0,
      tiers: tiersList,
      nextTierName: nextTier?['name'] as String?,
      nextTierRidesNeeded: (nextTier?['ridesNeeded'] as num?)?.toInt(),
      dailyRides: dailyList,
    );
  }
}
