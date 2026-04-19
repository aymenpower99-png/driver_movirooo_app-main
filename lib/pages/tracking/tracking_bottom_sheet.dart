// lib/pages/tracking/tracking_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:moviroo_driver_app/l10n/app_localizations.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/pages/tracking/ride_model.dart';
import 'package:moviroo_driver_app/pages/tracking/widgets/passenger_info_card.dart';
import 'package:moviroo_driver_app/pages/tracking/widgets/confirm_action_modal.dart';
import 'package:moviroo_driver_app/pages/tracking/completion/ride_completion_page.dart';
import 'package:moviroo_driver_app/pages/tracking/completion/ride_cancellation_page.dart';
import 'package:moviroo_driver_app/services/trip_service.dart';
import 'package:moviroo_driver_app/core/widgets/app_toast.dart';

class TrackingBottomSheet extends StatefulWidget {
  final RideModel ride;
  final ValueChanged<RideStatus>? onStatusChanged;

  const TrackingBottomSheet({
    super.key,
    required this.ride,
    this.onStatusChanged,
  });

  @override
  State<TrackingBottomSheet> createState() => _TrackingBottomSheetState();
}

class _TrackingBottomSheetState extends State<TrackingBottomSheet> {
  RideStatus _status = RideStatus.assigned;
  bool _isCollapsed = false;
  bool _apiLoading  = false;

  final TripService _tripService = TripService();

  void _handlePrimaryTap() {
    if (_apiLoading) return;
    final t = AppLocalizations.of(context).translate;
    if (_status == RideStatus.assigned) {
      ConfirmActionModal.show(
        context: context,
        title: t('tracking_confirm_title'),
        description: t('tracking_confirm_description'),
        confirmLabel: t('tracking_confirm_go_pickup'),
        onConfirm: _advance,
      );
    } else if (_status == RideStatus.startRide) {
      _completeRide();
    } else {
      _advance();
    }
  }

  /// Calls the correct backend endpoint then advances local state.
  Future<void> _advance() async {
    final next = _status.next;
    if (next == null) return;

    setState(() => _apiLoading = true);
    try {
      switch (_status) {
        case RideStatus.assigned:
          await _tripService.startEnroute(widget.ride.id);
          break;
        case RideStatus.onTheWay:
          await _tripService.arrived(widget.ride.id);
          break;
        case RideStatus.arrived:
          await _tripService.startTrip(widget.ride.id);
          break;
        default:
          break;
      }
      setState(() {
        _status     = next;
        _apiLoading = false;
      });
      widget.onStatusChanged?.call(_status);
    } catch (e) {
      setState(() => _apiLoading = false);
      if (mounted) {
        AppToast.error(context, 'Failed: $e');
      }
    }
  }

  /// Calls endTrip on backend then navigates to completion page.
  Future<void> _completeRide() async {
    setState(() => _apiLoading = true);
    try {
      await _tripService.endTrip(widget.ride.id);
      setState(() => _apiLoading = false);
      if (mounted) {
        AppToast.success(context, 'Ride completed');
        Navigator.of(context).push(RideCompletionPage.route(widget.ride));
      }
    } catch (e) {
      setState(() => _apiLoading = false);
      if (mounted) {
        AppToast.error(context, 'Failed to complete ride: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sheetColor = isDark ? AppColors.darkSurface : Colors.white;
    final handleColor = isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB);

    const double expandedFraction = 0.52;
    const double collapsedFraction = 0.13;

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (n) {
        final collapsed = n.extent <= collapsedFraction + 0.02;
        if (collapsed != _isCollapsed) setState(() => _isCollapsed = collapsed);
        return false;
      },
      child: DraggableScrollableSheet(
        initialChildSize: expandedFraction,
        minChildSize: collapsedFraction,
        maxChildSize: expandedFraction,
        snap: true,
        snapSizes: const [collapsedFraction, expandedFraction],
        builder: (_, scrollController) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: sheetColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: CustomScrollView(
              controller: scrollController,
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Drag handle + passenger header always at TOP ──
                      // This means when collapsed the user sees the handle
                      // pill immediately followed by the passenger row —
                      // nothing is pushed to the bottom of the card.
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 10, bottom: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: handleColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // ── Passenger card ────────────────────────────────
                      PassengerInfoCard(
                        passenger: ride.passenger,
                        rideId: ride.id,
                        pickupAddress: ride.pickupAddress,
                        dropOffAddress: ride.dropOffAddress,
                        distanceKm: ride.distanceKm,
                        etaMinutes: ride.etaMinutes,
                        showContactButtons: _status != RideStatus.assigned,
                        showMetaTile: _status != RideStatus.assigned,
                        showActions: _status != RideStatus.startRide,
                        onCall: _callPassenger,
                        onMessage: _openChat,
                        onCancelRide: () => _showCancelDialog(context),
                      ),
                    ],
                  ),
                ),

                // ── CTA button — only when expanded ──────────────────
                if (!_isCollapsed)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          14,
                          16,
                          bottomPadding + 16,
                        ),
                        child: _status.isTerminal
                            ? const _CompletedBanner()
                            : _PrimaryButton(
                                label: _status.primaryButtonLabel,
                                loading: _apiLoading,
                                onTap: _handlePrimaryTap,
                              ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CancelReasonSheet(
        onConfirm: (String reason) {
          Navigator.of(context).pop(); // close modal
          _cancelRide(reason);
        },
      ),
    );
  }

  Future<void> _cancelRide(String reason) async {
    setState(() => _apiLoading = true);
    bool success = false;
    try {
      await _tripService.cancelTrip(widget.ride.id, reason: reason);
      success = true;
    } catch (_) {
      // proceed to cancellation page even if API call fails
    } finally {
      if (mounted) setState(() => _apiLoading = false);
    }
    if (mounted) {
      if (success) {
        AppToast.success(context, 'Ride cancelled');
      } else {
        AppToast.error(context, 'Failed to cancel ride');
      }
      Navigator.of(context).push(
        RideCancellationPage.route(
          ride: widget.ride,
          cancelledBy: CancelledBy.driver,
        ),
      );
    }
  }

  Future<void> _callPassenger() async {
    final phone = widget.ride.passenger.phone;
    if (phone == null || phone.isEmpty) {
      if (mounted) {
        AppToast.info(context, 'No phone number available');
      }
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openChat() {
    Navigator.of(context).pushNamed('/chat', arguments: {
      'rideId': widget.ride.id,
      'passengerName': widget.ride.passenger.name,
    });
  }
}

// ── Primary CTA ───────────────────────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;
  const _PrimaryButton({required this.label, required this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: SizedBox(
        key: ValueKey(label),
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: loading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
        ),
      ),
    );
  }
}

// ── Completed Banner ──────────────────────────────────────────────────────────
class _CompletedBanner extends StatelessWidget {
  const _CompletedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 24,
          ),
          const SizedBox(width: 10),
          Text(
            AppLocalizations.of(context).translate('ride_completed'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cancel Reason Sheet ───────────────────────────────────────────────────────

const _kCancelReasons = [
  'Passenger no-show',
  'Passenger behavior',
  'Safety concern',
  'Wrong pickup location',
  'Route issue',
  'Other',
];

class _CancelReasonSheet extends StatefulWidget {
  final void Function(String reason) onConfirm;
  const _CancelReasonSheet({required this.onConfirm});

  @override
  State<_CancelReasonSheet> createState() => _CancelReasonSheetState();
}

class _CancelReasonSheetState extends State<_CancelReasonSheet> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Icon
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: isDark ? 0.15 : 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cancel_outlined, color: AppColors.error, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            AppLocalizations.of(context).translate('tracking_cancel_title'),
            style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: AppColors.text(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Please select a reason for cancelling:',
            style: TextStyle(fontSize: 13, color: AppColors.subtext(context)),
          ),
          const SizedBox(height: 12),
          // Reason list
          ..._kCancelReasons.map((reason) {
            final selected = _selected == reason;
            return GestureDetector(
              onTap: () => setState(() => _selected = reason),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(vertical: 3),
                padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.error.withValues(alpha: 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? AppColors.error : (isDark
                        ? AppColors.darkBorder
                        : const Color(0xFFE5E7EB)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      size: 18,
                      color: selected ? AppColors.error : AppColors.subtext(context),
                    ),
                    const SizedBox(width: 10),
                    Text(reason,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          color: selected ? AppColors.error : AppColors.text(context),
                        )),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          // Confirm
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: _selected == null
                  ? null
                  : () => widget.onConfirm(_selected!),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                disabledBackgroundColor: AppColors.error.withValues(alpha: 0.35),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancel Ride',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity, height: 44,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context).translate('tracking_keep_ride'),
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: AppColors.subtext(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
