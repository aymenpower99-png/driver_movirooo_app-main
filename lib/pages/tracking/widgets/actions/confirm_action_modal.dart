// lib/pages/tracking/widgets/actions/confirm_action_modal.dart
//
// Bottom-sheet confirmation modal.
// Triggered when driver taps "Go to Pickup" from the Assigned state.

import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_colors.dart';

class ConfirmActionModal extends StatelessWidget {
  final String title;
  final String description;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmActionModal({
    super.key,
    required this.title,
    required this.description,
    required this.confirmLabel,
    required this.onConfirm,
    required this.onCancel,
  });

  /// Convenience method to show as a modal bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String description,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ConfirmActionModal(
        title: title,
        description: description,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.iconBg(context),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.navigation_rounded,
              color: AppColors.primaryPurple,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.text(context),
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.subtext(context),
            ),
          ),
          const SizedBox(height: 28),

          // Confirm
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text(
                confirmLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Cancel
          SizedBox(
            width: double.infinity,
            height: 46,
            child: TextButton(
              onPressed: onCancel,
              child: Text(
                AppLocalizations.of(context).translate('cancel'),
                style: TextStyle(
                  fontSize: 15,
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
