// lib/pages/tracking/completion/widgets/meta_cell.dart

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';

class MetaCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const MetaCell({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Icon(icon, size: 15, color: AppColors.primaryPurple),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text(context),
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: AppColors.subtext(context)),
          ),
        ],
      ),
    );
  }
}
