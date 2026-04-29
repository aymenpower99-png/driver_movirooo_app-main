import 'dart:io';
import 'package:flutter/material.dart';
import 'photo_thumb.dart';
import 'add_photo_button.dart';

class PhotoGrid extends StatelessWidget {
  final List<File> photos;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  const PhotoGrid({
    super.key,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  static const int _maxPhotos = 4;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...photos.asMap().entries.map(
          (e) => PhotoThumb(file: e.value, onRemove: () => onRemove(e.key)),
        ),
        if (photos.length < _maxPhotos) AddPhotoButton(onTap: onAdd),
      ],
    );
  }
}
