// lib/pages/tracking/completion/ride_completion_page.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/pages/tracking/ride_model.dart';
import 'package:moviroo_driver_app/l10n/app_localizations.dart';
import 'widgets/ride_status_header.dart';
import 'widgets/ride_summary_card.dart';
import 'widgets/ride_earnings_card.dart';
import 'widgets/ride_rating_card.dart';

class RideCompletionPage extends StatefulWidget {
  final RideModel ride;

  const RideCompletionPage({super.key, required this.ride});

  static Route<void> route(RideModel ride) =>
      MaterialPageRoute(builder: (_) => RideCompletionPage(ride: ride));

  @override
  State<RideCompletionPage> createState() => _RideCompletionPageState();
}

class _RideCompletionPageState extends State<RideCompletionPage>
    with TickerProviderStateMixin {
  bool _loading = true;
  int _selectedStars = 5;

  late final AnimationController _fadeCtrl;
  late final AnimationController _scaleCtrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _scale = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() => _loading = false);
      _fadeCtrl.forward();
      Future.delayed(const Duration(milliseconds: 80), () {
        if (!mounted) return;
        _scaleCtrl.forward();
      });
    });
  }

  @override
  void dispose() {
    _fadeCtrl.stop();
    _scaleCtrl.stop();
    _fadeCtrl.dispose();
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _backToOnline() {
    _fadeCtrl.stop();
    _scaleCtrl.stop();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: _loading ? _buildLoading(context) : _buildCompletion(context),
    );
  }

  // ── Loading ─────────────────────────────────────────────────────
  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              color: AppColors.primaryPurple,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).translate('completion_loading'),
            style: TextStyle(
              fontSize: 15,
              color: AppColors.subtext(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Completion ──────────────────────────────────────────────────
  Widget _buildCompletion(BuildContext context) {
    final ride = widget.ride;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reportColor = isDark ? Colors.white : AppColors.subtext(context);

    return FadeTransition(
      opacity: _fade,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RideStatusHeader(
                scale: _scale,
                title: AppLocalizations.of(
                  context,
                ).translate('completion_title'),
                icon: Icons.check_rounded,
                iconColor: AppColors.success,
                iconBgColor: AppColors.success.withValues(alpha: 0.12),
              ),

              RideSummaryCard(ride: ride),
              const SizedBox(height: 10),

              RideEarningsCard(
                ridePrice: ride.earningsAmount / 0.70,
                driverEarnings: ride.earningsAmount,
              ),
              const SizedBox(height: 10),

              RideRatingCard(
                selectedStars: _selectedStars,
                onStarTap: (s) => setState(() => _selectedStars = s),
              ),

              const Spacer(),

              // ── Report Issue ──────────────────────────────────
              Center(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: Image.asset(
                    'images/icons/warning.png',
                    width: 14,
                    height: 14,
                    color: reportColor,
                  ),
                  label: Text(
                    AppLocalizations.of(
                      context,
                    ).translate('completion_report_issue'),
                    style: TextStyle(
                      fontSize: 13,
                      color: reportColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _backToOnline,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(
                      context,
                    ).translate('completion_back_online'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}