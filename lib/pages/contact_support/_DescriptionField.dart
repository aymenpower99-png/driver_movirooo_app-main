import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  const DescriptionField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 5,
      style: AppTextStyles.bodyMedium(context),
      cursorColor: AppColors.primaryPurple,
      decoration: InputDecoration(
        hintText:
            'Please describe your issue in detail so our\nsupport team can assist you better...',
        hintStyle: AppTextStyles.bodyMedium(context).copyWith(
          color: AppColors.subtext(context),
          fontSize: 13,
        ),
        filled: true,
        fillColor: AppColors.surface(context),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: AppColors.primaryPurple, width: 1.5),
        ),
      ),
    );
  }
}
