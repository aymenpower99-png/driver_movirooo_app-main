import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/l10n/app_localizations.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';

class AddPhotoButton extends StatelessWidget {
  final VoidCallback onTap;
  const AddPhotoButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border(context), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: 22,
              color: AppColors.subtext(context),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context).translate('photo_add'),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.subtext(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
