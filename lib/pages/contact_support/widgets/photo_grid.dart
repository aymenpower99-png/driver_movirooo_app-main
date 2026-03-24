import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

/// Displays a grid of selected photo thumbnails plus an "Add photo" button.
class PhotoGrid extends StatelessWidget {
  final List<File> photos;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  static const int _maxPhotos = 4;

  const PhotoGrid({
    super.key,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...photos.asMap().entries.map(
          (e) => _PhotoThumb(file: e.value, onRemove: () => onRemove(e.key)),
        ),
        if (photos.length < _maxPhotos) _AddPhotoButton(onTap: onAdd),
      ],
    );
  }
}

// ── Thumbnail ──────────────────────────────────────────────────────────────────

class _PhotoThumb extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;

  const _PhotoThumb({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(file, width: 80, height: 80, fit: BoxFit.cover),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 13,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Add button ─────────────────────────────────────────────────────────────────

class _AddPhotoButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPhotoButton({required this.onTap});

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
