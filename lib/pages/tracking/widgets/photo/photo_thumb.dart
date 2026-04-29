import 'dart:io';
import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';

class PhotoThumb extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;
  const PhotoThumb({required this.file, required this.onRemove});

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
