// lib/pages/tabs/[driver]/Rides/tracking/tracking_bottom_sheet.dart

import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';
import 'ride_model.dart';
import 'widgets/passenger_info_card.dart';
import 'widgets/confirm_action_modal.dart';

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

  void _handlePrimaryTap() {
    if (_status == RideStatus.assigned) {
      ConfirmActionModal.show(
        context: context,
        title: 'Are you sure?',
        description: 'You are about to start navigating to the passenger pickup.',
        confirmLabel: 'Confirm — Go to Pickup',
        onConfirm: _advance,
      );
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
    final ride = widget.ride;

    return DraggableScrollableSheet(
      initialChildSize: 0.50,
      minChildSize: 0.18,
      maxChildSize: 0.88,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
          children: [
            // ── Drag handle ──────────────────────────────────────
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Passenger card ───────────────────────────────────
            PassengerInfoCard(
              passenger: ride.passenger,
              pickupAddress: ride.pickupAddress,
              dropOffAddress: ride.dropOffAddress,
              distanceKm: ride.distanceKm,
              etaMinutes: ride.etaMinutes,
              showContactButtons: _status.showContactButtons,
              onCall: () {},
              onMessage: () {},
              onCopyAddress: () {},
              onReportIssue: () => _showReportDialog(context),
              onCancelRide: () => _showCancelDialog(context),
            ),

            const SizedBox(height: 16),

            // ── Primary CTA ──────────────────────────────────────
            _status != null
                ? _PrimaryButton(
                    label: _status.primaryButtonLabel,
                    onTap: _handlePrimaryTap,
                  )
                : _CompletedBanner(),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReportIssueSheet(),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _CancelRideSheet(
        onConfirm: () {
          Navigator.of(context).pop(); // close sheet
          Navigator.of(context).pop(); // go back to rides
        },
      ),
    );
  }
}

// ── Primary CTA Button ────────────────────────────────────────────────────────

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
          child: Text(
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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 24),
          const SizedBox(width: 10),
          Text(
            'Ride Completed!',
            style: TextStyle(
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

// ── Report Issue Sheet ────────────────────────────────────────────────────────

class _ReportIssueSheet extends StatelessWidget {
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
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Report an Issue',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'What went wrong?',
            style: TextStyle(fontSize: 13, color: Color(0xFF9AA3AD)),
          ),
          const SizedBox(height: 16),
          ..._issues.map((issue) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.radio_button_unchecked,
                    size: 18, color: Color(0xFF9AA3AD)),
                title: Text(issue,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
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
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEA),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cancel_outlined,
                color: Color(0xFFFF3B30), size: 28),
          ),
          const SizedBox(height: 14),
          const Text(
            'Cancel Ride?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Are you sure you want to cancel this ride? This may affect your rating.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13, color: Color(0xFF9AA3AD), height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3B30),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Yes, Cancel Ride',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep Ride',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9AA3AD))),
            ),
          ),
        ],
      ),
    );
  }
}