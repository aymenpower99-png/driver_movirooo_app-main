// lib/pages/tracking/widgets/contact/contact_icon_button.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';

class ContactIconBtn extends StatelessWidget {
  final String iconAsset;
  final Color bgColor;
  final VoidCallback onTap;

  const ContactIconBtn(
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
