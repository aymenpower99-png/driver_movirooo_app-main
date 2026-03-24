import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

class EarningsChart extends StatelessWidget {
  const EarningsChart({super.key});

  static const double _maxBarHeight = 120.0;

  static const List<Map<String, dynamic>> _data = [
    {'week': 'W1', 'gross': 0.55, 'comm': 0.72},
    {'week': 'W2', 'gross': 0.65, 'comm': 0.78},
    {'week': 'W3', 'gross': 0.85, 'comm': 0.95},
    {'week': 'W4', 'gross': 0.90, 'comm': 1.00},
    {'week': 'W5', 'gross': 0.30, 'comm': 0.38},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title + legend ─────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).translate('earnings_chart_title'),
                  style: AppTextStyles.bodyLarge(
                    context,
                  ).copyWith(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
              _LegendDot(
                color: AppColors.primaryPurple,
                label: AppLocalizations.of(
                  context,
                ).translate('earnings_chart_gross'),
              ),
              const SizedBox(width: 14),
              _LegendDot(
                color: AppColors.primaryPurple.withOpacity(0.30),
                label: AppLocalizations.of(
                  context,
                ).translate('earnings_chart_comm'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Bars — hauteur fixe, pas de FractionallySizedBox ──
          SizedBox(
            height: _maxBarHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _data.map((d) {
                final grossH = (d['gross'] as double) * _maxBarHeight;
                final commH = (d['comm'] as double) * _maxBarHeight;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Commission bar (lighter, taller)
                        Container(
                          height: commH,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withOpacity(0.25),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ),
                        // Gross bar (darker, shorter)
                        Container(
                          height: grossH,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // ── Week labels ────────────────────────────────
          Row(
            children: _data.map((d) {
              return Expanded(
                child: Text(
                  d['week'] as String,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall(
                    context,
                  ).copyWith(color: AppColors.subtext(context), fontSize: 11),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: AppColors.subtext(context),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
