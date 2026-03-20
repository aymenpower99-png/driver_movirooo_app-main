import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class DocumentUpload extends StatefulWidget {
  const DocumentUpload({super.key});

  @override
  State<DocumentUpload> createState() => _DocumentUploadState();
}

class _DocumentUploadState extends State<DocumentUpload> {
  final List<String> _files = [];

  void _pickFile() {
    setState(() => _files.add('screenshot_${_files.length + 1}.png'));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.border(context),
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined,
                    color: AppColors.subtext(context), size: 22),
                const SizedBox(width: 10),
                Text('Attach Screenshot/Photo',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: AppColors.subtext(context),
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
        ),

        if (_files.isNotEmpty) ...[
          const SizedBox(height: 10),
          ..._files.map((f) => _FileChip(
                name: f,
                onRemove: () => setState(() => _files.remove(f)),
              )),
        ],
      ],
    );
  }
}

class _FileChip extends StatelessWidget {
  final String name;
  final VoidCallback onRemove;
  const _FileChip({required this.name, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.primaryPurple.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.image_outlined,
              color: AppColors.primaryPurple, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(name,
                style: TextStyle(
                  color: AppColors.text(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                )),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded,
                color: AppColors.subtext(context), size: 18),
          ),
        ],
      ),
    );
  }
}
