import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSend;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.bg(context),
        border: Border(
          top: BorderSide(color: AppColors.border(context), width: 1),
        ),
      ),
      child: Row(
        children: [

          // ── Champ texte ────────────────────────────────────
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Row(
                children: [
                  // Location quick reply
                  GestureDetector(
                    onTap: () {
                      controller.text = 'Where exactly are you?';
                    },
                    child: Icon(Icons.location_on_outlined,
                        color: AppColors.subtext(context), size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: AppTextStyles.bodyMedium(context)
                          .copyWith(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Where exactly are you?',
                        hintStyle: AppTextStyles.bodySmall(context).copyWith(
                          color: AppColors.subtext(context),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onSubmitted: onSend,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Attachment
                  Icon(Icons.attach_file_rounded,
                      color: AppColors.subtext(context), size: 20),
                  const SizedBox(width: 8),
                  // Voice
                  Icon(Icons.mic_outlined,
                      color: AppColors.subtext(context), size: 20),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ── Bouton envoyer ─────────────────────────────────
          GestureDetector(
            onTap: () => onSend(controller.text),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.40),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
