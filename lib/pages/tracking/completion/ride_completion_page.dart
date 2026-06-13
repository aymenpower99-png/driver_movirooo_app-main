// lib/pages/tracking/completion/ride_completion_page.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/pages/tracking/ride_model.dart';
import 'package:moviroo_driver_app/l10n/app_localizations.dart';
import 'package:moviroo_driver_app/core/widgets/app_toast.dart';
import 'package:moviroo_driver_app/services/trip/trip_service.dart';
import 'package:moviroo_driver_app/services/earnings/earnings_service.dart';
import 'package:moviroo_driver_app/core/models/earnings_model.dart';
import 'widgets/ride_status_header.dart';
import 'widgets/ride_summary_card.dart';
import 'widgets/ride_rating_card.dart';
import 'widgets/commission_tier_card.dart';

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
  bool _submittingRating = false;
  EarningsModel? _earnings;
  bool _earningsLoading = true;

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

    // Fetch earnings/tier data in background (same endpoint as Earnings screen)
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    try {
      final earnings = await EarningsService().getMyEarnings();
      if (mounted) {
        setState(() {
          _earnings = earnings;
          _earningsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _earningsLoading = false);
    }
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

  Future<void> _submitRating() async {
    if (_submittingRating) return;
    setState(() => _submittingRating = true);
    try {
      await TripService().submitRating(widget.ride.id, _selectedStars);
      if (mounted) {
        AppToast.success(
          context,
          AppLocalizations.of(context).translate('rating_submitted'),
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(
          context,
          AppLocalizations.of(context).translate('rating_failed'),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submittingRating = false);
      }
    }
    _backToOnline();
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
    final t = AppLocalizations.of(context).translate;

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
                title: t('completion_title'),
                icon: Icons.check_rounded,
                iconColor: AppColors.success,
                iconBgColor: AppColors.success.withValues(alpha: 0.12),
              ),

              RideSummaryCard(ride: ride),
              const SizedBox(height: 10),

              // Commission Tier card (replaces the removed GAINS card)
              CommissionTierCard(
                earnings: _earningsLoading ? null : _earnings,
              ),
              const SizedBox(height: 10),

              RideRatingCard(
                selectedStars: _selectedStars,
                onStarTap: (s) => setState(() => _selectedStars = s),
              ),

              const Spacer(),

              // ── Bottom buttons ──────────────────────────────────
              Row(
                children: [
                  // Back online (skip rating) — outlined purple
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: _backToOnline,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryPurple,
                          side: const BorderSide(
                            color: AppColors.primaryPurple,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          t('completion_back_online'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Submit rating — filled purple
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _submittingRating ? null : _submitRating,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          side: const BorderSide(
                            color: AppColors.primaryPurple,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _submittingRating
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                t('completion_submit_rating'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
