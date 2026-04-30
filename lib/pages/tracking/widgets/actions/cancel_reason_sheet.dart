// lib/pages/tracking/widgets/actions/cancel_reason_sheet.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/l10n/app_localizations.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';

const _kCancelReasons = [
  'Passenger no-show',
  'Passenger behavior',
  'Safety concern',
  'Wrong pickup location',
  'Route issue',
  'Other',
];

class CancelReasonSheet extends StatefulWidget {
  final void Function(String reason) onConfirm;
  const CancelReasonSheet({super.key, required this.onConfirm});

  @override
  State<CancelReasonSheet> createState() => _CancelReasonSheetState();
}

class _CancelReasonSheetState extends State<CancelReasonSheet> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
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
              width: 40,
              height: 4,
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
            child: const Icon(
              Icons.cancel_outlined,
              color: AppColors.error,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppLocalizations.of(context).translate('tracking_cancel_title'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
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
                padding: const EdgeInsets.symmetric(
                  vertical: 11,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.error.withValues(alpha: 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected
                        ? AppColors.error
                        : (isDark
                              ? AppColors.darkBorder
                              : const Color(0xFFE5E7EB)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 18,
                      color: selected
                          ? AppColors.error
                          : AppColors.subtext(context),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      reason,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: selected
                            ? AppColors.error
                            : AppColors.text(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          // Confirm
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _selected == null
                  ? null
                  : () => widget.onConfirm(_selected!),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                disabledBackgroundColor: AppColors.error.withValues(
                  alpha: 0.35,
                ),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel Ride',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context).translate('tracking_keep_ride'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
