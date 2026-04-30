// lib/pages/tracking/widgets/shared/section_label.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';

class SectionLabel extends StatelessWidget {
  final String label;
  const SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.subtext(context),
        letterSpacing: 0.3,
      ),
    );
  }
}
