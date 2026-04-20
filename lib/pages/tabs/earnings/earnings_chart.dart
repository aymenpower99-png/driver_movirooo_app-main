import 'package:flutter/material.dart';
import '../../../../core/models/earnings_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

class EarningsChart extends StatelessWidget {
  final List<DailyRides> dailyRides;
  const EarningsChart({super.key, required this.dailyRides});

  static const double _chartH = 130.0;

  /// Aggregate dailyRides by ISO weekday (Mon=0 … Sun=6)
  List<int> _weekData() {
    final data = List<int>.filled(7, 0);
    for (final d in dailyRides) {
      try {
        final dt = DateTime.parse(d.day);
        data[dt.weekday - 1] += d.rides;
      } catch (_) {}
    }
    return data;
  }

  int _niceMax(int max) {
    if (max <= 0) return 6;
    if (max <= 4) return 4;
    if (max <= 6) return 6;
    if (max <= 8) return 8;
    if (max <= 10) return 10;
    return ((max / 5).ceil() * 5);
  }

  @override
  Widget build(BuildContext context) {
    final weekData = _weekData();
    final rawMax = weekData.reduce((a, b) => a > b ? a : b);
    final yMax = _niceMax(rawMax);
    const steps = 4; // divides chart into 4 equal sections
    final yLabels = List.generate(steps + 1, (i) => yMax - (yMax * i ~/ steps));

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('earnings_weekly_rides'),
            style: AppTextStyles.bodyLarge(
              context,
            ).copyWith(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          const SizedBox(height: 2),
          Text(
            AppLocalizations.of(context).translate('earnings_rides_per_day'),
            style: AppTextStyles.bodySmall(
              context,
            ).copyWith(color: AppColors.subtext(context), fontSize: 11),
          ),
          const SizedBox(height: 18),

          // Chart body
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Y-axis labels aligned with _chartH
              SizedBox(
                width: 22,
                height: _chartH,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: yLabels
                      .map(
                        (v) => Text(
                          '$v',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: AppColors.subtext(context),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(width: 6),

              // Bars + grid
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: _chartH,
                      child: Stack(
                        children: [
                          // Horizontal grid lines (spaceBetween = aligns with Y labels)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              steps + 1,
                              (_) => Container(
                                height: 1,
                                color: AppColors.border(
                                  context,
                                ).withValues(alpha: 0.6),
                              ),
                            ),
                          ),

                          // Bars
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(7, (i) {
                              final rides = weekData[i];
                              final barH = yMax > 0
                                  ? (rides / yMax) * _chartH
                                  : 0.0;
                              return SizedBox(
                                height: _chartH,
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    // Bar
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        height: barH > 0 ? barH : 2,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          color: rides > 0
                                              ? AppColors.primaryPurple
                                              : AppColors.border(context),
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(5),
                                              ),
                                        ),
                                      ),
                                    ),
                                    // Count label above bar
                                    if (rides > 0)
                                      Positioned(
                                        bottom: barH + 3,
                                        child: Text(
                                          '$rides',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primaryPurple,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 7),

                    // X-axis labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children:
                          [
                                'earnings_day_mon',
                                'earnings_day_tue',
                                'earnings_day_wed',
                                'earnings_day_thu',
                                'earnings_day_fri',
                                'earnings_day_sat',
                                'earnings_day_sun',
                              ]
                              .map(
                                (key) => Text(
                                  AppLocalizations.of(context).translate(key),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.subtext(context),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
