import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class EarningsHeader extends StatelessWidget {
  final String month;
  final VoidCallback onChangeTap;

  const EarningsHeader({
    super.key,
    required this.month,
    required this.onChangeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.bg(context),
        border: Border(
          bottom: BorderSide(color: AppColors.border(context)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month_outlined,
              color: AppColors.primaryPurple, size: 20),
          const SizedBox(width: 8),
          Text(month,
              style: AppTextStyles.bodyLarge(context).copyWith(
                fontWeight: FontWeight.w700,
              )),
          const Spacer(),
          GestureDetector(
            onTap: onChangeTap,
            child: Row(
              children: [
                Text('Change',
                    style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    )),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primaryPurple, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
