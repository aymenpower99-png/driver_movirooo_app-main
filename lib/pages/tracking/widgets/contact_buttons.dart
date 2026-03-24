// lib/pages/tracking/widgets/contact_buttons.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';

class ContactButtons extends StatelessWidget {
  final VoidCallback? onCall;
  final VoidCallback? onMessage;

  const ContactButtons({super.key, this.onCall, this.onMessage});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final btnBg = isDark ? AppColors.darkBorder : const Color(0xFFF1F3F5);

    return Row(
      children: [
        _ContactIconBtn(
            iconAsset: 'images/icons/telephone.png',
            bgColor: btnBg,
            onTap: onCall ?? () {}),
        const SizedBox(width: 8),
        _ContactIconBtn(
            iconAsset: 'images/icons/messenger.png',
            bgColor: btnBg,
            onTap: onMessage ?? () {}),
      ],
    );
  }
}

class _ContactIconBtn extends StatelessWidget {
  final String iconAsset;
  final Color bgColor;
  final VoidCallback onTap;

  const _ContactIconBtn(
      {required this.iconAsset, required this.bgColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Center(
            child: Image.asset(
              iconAsset,
              width: 20,
              height: 20,
              color: AppColors.primaryPurple,
            ),
          ),
        ),
      ),
    );
  }
}