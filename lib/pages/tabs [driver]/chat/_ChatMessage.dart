import 'package:flutter/material.dart';

class ChatMessage {
  final String id;
  final String text;
  final String? translatedText;
  final bool isMe;
  final String time;
  final bool isArabic;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.translatedText,
    required this.isMe,
    required this.time,
    required this.isArabic,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showTranslation;

  const ChatBubble({
    super.key,
    required this.message,
    required this.showTranslation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [

          // ── Bubble principale ──────────────────────────────
          Row(
            mainAxisAlignment: message.isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Avatar (seulement pour les autres)
              if (!message.isMe) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF7C3AED).withOpacity(0.15),
                  child: const Icon(Icons.person_rounded,
                      color: Color(0xFF7C3AED), size: 18),
                ),
                const SizedBox(width: 8),
              ],

              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: message.isMe
                        ? const Color(0xFF7C3AED)
                        : isDark
                            ? const Color(0xFF1E1E2E)
                            : const Color(0xFFF1F0F5),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(message.isMe ? 18 : 4),
                      bottomRight: Radius.circular(message.isMe ? 4 : 18),
                    ),
                  ),
                  child: Text(
                    message.text,
                    textAlign: message.isArabic
                        ? TextAlign.right
                        : TextAlign.left,
                    textDirection: message.isArabic
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    style: TextStyle(
                      color: message.isMe
                          ? Colors.white
                          : isDark
                              ? Colors.white
                              : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Traduction AI ──────────────────────────────────
          if (!message.isMe &&
              showTranslation &&
              message.translatedText != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRANSLATED BY AI',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message.translatedText!,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Heure ──────────────────────────────────────────
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(
              left: message.isMe ? 0 : 40,
            ),
            child: Text(
              message.time,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
