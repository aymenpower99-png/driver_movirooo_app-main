// lib/pages/tracking/completion/ride_cancellation_page.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/pages/tracking/ride_model.dart';
import 'package:moviroo_driver_app/l10n/app_localizations.dart';
import 'widgets/ride_status_header.dart';
import 'widgets/ride_summary_card.dart';
import 'widgets/cancel_earnings_card.dart';
import 'widgets/ride_rating_card.dart';
import 'widgets/driver_cancel_warning.dart';

// Re-export enums so callers only need to import this file.
export 'widgets/cancel_earnings_card.dart' show CancelledBy, PassengerCancelType;

class RideCancellationPage extends StatefulWidget {
  final RideModel ride;

  /// Who cancelled the ride.
  final CancelledBy cancelledBy;

  /// Only relevant when [cancelledBy] == [CancelledBy.passenger].
  final PassengerCancelType passengerCancelType;

  /// Fee charged to the passenger (late cancel).
  final double cancellationFee;

  /// Driver's share of the cancellation fee (late cancel).
  final double driverCancellationEarnings;

  /// Whether the driver had already reached / started with the passenger.
  /// Controls visibility of the rating card.
  final bool driverReachedPassenger;

  const RideCancellationPage({
    super.key,
    required this.ride,
    required this.cancelledBy,
    this.passengerCancelType = PassengerCancelType.early,
    this.cancellationFee = 0,
    this.driverCancellationEarnings = 0,
    this.driverReachedPassenger = false,
  });

  static Route<void> route({
    required RideModel ride,
    required CancelledBy cancelledBy,
    PassengerCancelType passengerCancelType = PassengerCancelType.early,
    double cancellationFee = 0,
    double driverCancellationEarnings = 0,
    bool driverReachedPassenger = false,
  }) =>
      MaterialPageRoute(
        builder: (_) => RideCancellationPage(
          ride: ride,
          cancelledBy: cancelledBy,
          passengerCancelType: passengerCancelType,
          cancellationFee: cancellationFee,
          driverCancellationEarnings: driverCancellationEarnings,
          driverReachedPassenger: driverReachedPassenger,
        ),
      );

  @override
  State<RideCancellationPage> createState() => _RideCancellationPageState();
}

class _RideCancellationPageState extends State<RideCancellationPage>
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

    Future.delayed(const Duration(milliseconds: 1400), () {
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

  void _showRideDetailsDialog(BuildContext context) {
    final ride = widget.ride;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.directions_car_rounded,
                color: AppColors.primaryPurple, size: 20),
            const SizedBox(width: 8),
            const Text('Ride Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailItem(label: 'Pickup',
                value: ride.pickupAddress,
                icon: Icons.radio_button_checked_rounded,
                color: AppColors.primaryPurple),
            const SizedBox(height: 8),
            _DetailItem(label: 'Drop-off',
                value: ride.dropOffAddress,
                icon: Icons.location_on_rounded,
                color: const Color(0xFF7C3AED)),
            const SizedBox(height: 8),
            _DetailItem(label: 'Passenger',
                value: ride.passenger.name,
                icon: Icons.person_outline_rounded,
                color: AppColors.subtext(ctx)),
            const SizedBox(height: 8),
            _DetailItem(label: 'Distance',
                value: '${ride.distanceKm.toStringAsFixed(1)} km',
                icon: Icons.straighten_rounded,
                color: AppColors.subtext(ctx)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  bool get _showRating =>
      widget.cancelledBy == CancelledBy.passenger &&
      widget.driverReachedPassenger;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: _loading ? _buildLoading(context) : _buildContent(context),
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
            AppLocalizations.of(context).translate('cancellation_loading'),
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

  // ── Content ──────────────────────────────────────────────────────
  Widget _buildContent(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ───────────────────────────────────────────
              RideStatusHeader(
                scale: _scale,
                title: AppLocalizations.of(
                  context,
                ).translate('cancellation_title'),
                icon: Icons.close_rounded,
                iconColor: AppColors.error,
                iconBgColor: AppColors.error.withValues(alpha: 0.12),
                badge: _CancelledByBadge(cancelledBy: widget.cancelledBy),
              ),

              // ── Ride info ────────────────────────────────────────
              RideSummaryCard(ride: widget.ride, showMeta: false, pickupOnly: false),
              const SizedBox(height: 10),

              // ── Earnings ─────────────────────────────────────────
              CancelEarningsCard(
                cancelledBy: widget.cancelledBy,
                passengerCancelType: widget.passengerCancelType,
                cancellationFee: widget.cancellationFee,
                driverEarnings: widget.driverCancellationEarnings,
              ),

              // ── Driver warning ───────────────────────────────────
              if (widget.cancelledBy == CancelledBy.driver) ...[
                const SizedBox(height: 10),
                const DriverCancelWarning(),
              ],

              // ── Rating (conditional) ─────────────────────────────
              if (_showRating) ...[
                const SizedBox(height: 10),
                RideRatingCard(
                  selectedStars: _selectedStars,
                  onStarTap: (s) => setState(() => _selectedStars = s),
                ),
              ],

              const Spacer(),

              // ── Primary CTA ───────────────────────────────────────
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
              const SizedBox(height: 8),

              // ── View Details ─────────────────────────────────────
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => _showRideDetailsDialog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryPurple,
                    side: const BorderSide(
                      color: AppColors.primaryPurple,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(
                      context,
                    ).translate('cancellation_view_details'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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

// ── Cancelled-by badge ────────────────────────────────────────────────────────
class _CancelledByBadge extends StatelessWidget {
  final CancelledBy cancelledBy;
  const _CancelledByBadge({required this.cancelledBy});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDriver = cancelledBy == CancelledBy.driver;

    final label = isDriver
        ? AppLocalizations.of(context).translate('cancellation_by_driver')
        : AppLocalizations.of(context).translate('cancellation_by_passenger');

    final bgColor = isDriver
        ? (isDark ? const Color(0xFF2A1F1F) : const Color(0xFFFFF3F3))
        : (isDark ? const Color(0xFF1F1F2A) : const Color(0xFFF3F3FF));

    final textColor = isDriver ? AppColors.error : AppColors.primaryPurple;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// ── Ride detail item ──────────────────────────────────────────────────────────
class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.subtext(context),
                      fontWeight: FontWeight.w500)),
              Text(value,
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.text(context),
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}