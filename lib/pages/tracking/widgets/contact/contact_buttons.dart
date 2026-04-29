// lib/pages/tracking/widgets/contact/contact_buttons.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'contact_icon_button.dart';

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
        ContactIconBtn(
          iconAsset: 'images/icons/telephone.png',
          bgColor: btnBg,
          onTap: onCall ?? () {},
        ),
        const SizedBox(width: 8),
        ContactIconBtn(
          iconAsset: 'images/icons/messenger.png',
          bgColor: btnBg,
          onTap: onMessage ?? () {},
        ),
      ],
    );
  }
}
