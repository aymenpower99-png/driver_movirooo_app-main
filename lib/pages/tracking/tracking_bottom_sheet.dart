// lib/pages/tabs/[driver]/Rides/tracking/tracking_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/pages/tracking/ride_model.dart';
import 'package:moviroo_driver_app/pages/tracking/widgets/passenger_info_card.dart';
import 'package:moviroo_driver_app/pages/tracking/widgets/confirm_action_modal.dart';
import 'package:moviroo_driver_app/pages/tracking/completion/ride_completion_page.dart';

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

  void _handlePrimaryTap() {
    if (_status == RideStatus.assigned) {
      ConfirmActionModal.show(
        context: context,
        title: 'Are you sure?',
        description:
            'You are about to start navigating to the passenger pickup.',
        confirmLabel: 'Confirm — Go to Pickup',
        onConfirm: _advance,
      );
    } else if (_status == RideStatus.startRide) {
      Navigator.of(context).push(RideCompletionPage.route(widget.ride));
    } else {
      _advance();
    }
  }

  void _advance() {
    final next = _status.next;
    if (next == null) return;
    setState(() => _status = next);
    widget.onStatusChanged?.call(_status);
  }

  @override
  Widget build(BuildContext context) {
    final ride         = widget.ride;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark       = Theme.of(context).brightness == Brightness.dark;

    final sheetColor  = isDark ? AppColors.darkSurface : Colors.white;
    final handleColor = isDark ? AppColors.darkBorder   : const Color(0xFFE5E7EB);

    const double expandedFraction  = 0.52;
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(alpha: isDark ? 0.4 : 0.08),
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
                        pickupAddress: ride.pickupAddress,
                        dropOffAddress: ride.dropOffAddress,
                        distanceKm: ride.distanceKm,
                        etaMinutes: ride.etaMinutes,
                        showContactButtons: _status != RideStatus.assigned,
                        showMetaTile: _status != RideStatus.assigned,
                        showActions: _status != RideStatus.startRide,
                        onCall: () {},
                        onMessage: () {},
                        onReportIssue: () => _showReportDialog(context),
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
                            16, 14, 16, bottomPadding + 16),
                        child: _status.isTerminal
                            ? const _CompletedBanner()
                            : _PrimaryButton(
                                label: _status.primaryButtonLabel,
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

  void _showReportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ReportIssueSheet(),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _CancelRideSheet(
        onConfirm: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// ── Primary CTA ───────────────────────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: SizedBox(
        key: ValueKey(label),
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700)),
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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 24),
          SizedBox(width: 10),
          Text('Ride Completed!',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success)),
        ],
      ),
    );
  }
}

// ── Report Issue Sheet ────────────────────────────────────────────────────────
class _ReportIssueSheet extends StatelessWidget {
  const _ReportIssueSheet();

  static const _issues = [
    'Passenger no-show',
    'Passenger was rude',
    'Wrong address provided',
    'Safety concern',
    'App issue',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(24)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Text('Report an Issue',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text(context))),
          const SizedBox(height: 4),
          Text('What went wrong?',
              style: TextStyle(
                  fontSize: 13, color: AppColors.subtext(context))),
          const SizedBox(height: 16),
          ..._issues.map((issue) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.radio_button_unchecked,
                    size: 18, color: AppColors.subtext(context)),
                title: Text(issue,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text(context))),
                onTap: () => Navigator.pop(context),
              )),
        ],
      ),
    );
  }
}

// ── Cancel Ride Sheet ─────────────────────────────────────────────────────────
class _CancelRideSheet extends StatelessWidget {
  final VoidCallback onConfirm;
  const _CancelRideSheet({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(24)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.error.withValues(alpha: 0.15)
                  : const Color(0xFFFFEBEA),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cancel_outlined,
                color: AppColors.error, size: 28),
          ),
          const SizedBox(height: 14),
          Text('Cancel Ride?',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text(context))),
          const SizedBox(height: 8),
          Text(
            'Are you sure you want to cancel this ride? This may affect your rating.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                color: AppColors.subtext(context),
                height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Yes, Cancel Ride',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity, height: 46,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Keep Ride',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.subtext(context))),
            ),
          ),
        ],
      ),
    );
  }
}