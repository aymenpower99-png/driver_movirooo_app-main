import 'package:flutter/material.dart';
import '../../../../../theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String label;

  const SectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(label, style: AppTextStyles.sectionLabel(context)),
      );
}