// lib/pages/tracking/widgets/contact_buttons.dart
//
// Call / Message secondary action buttons.
// Appear from On the Way state onward (hidden during Assigned).

import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class ContactButtons extends StatelessWidget {
  final VoidCallback onCall;
  final VoidCallback onMessage;

  const ContactButtons({
    super.key,
    required this.onCall,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ContactBtn(
            icon: Icons.phone_rounded,
            label: 'Call',
            onTap: onCall,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ContactBtn(
            icon: Icons.chat_bubble_rounded,
            label: 'Message',
            onTap: onMessage,
          ),
        ),
      ],
    );
  }
}

class _ContactBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.iconBg(context),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.primaryPurple),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}