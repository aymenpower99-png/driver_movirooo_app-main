import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class DriverCard extends StatelessWidget {
  const DriverCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [

          // ── Avatar ──────────────────────────────────────────
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primaryPurple.withOpacity(0.15),
                backgroundImage: const AssetImage('images/driver_avatar.png'),
                onBackgroundImageError: (_, __) {},
                child: ClipOval(
                  child: Image.asset(
                    'images/driver_avatar.png',
                    width: 52, height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.person_rounded,
                      color: AppColors.primaryPurple,
                      size: 26,
                    ),
                  ),
                ),
              ),
              // Online dot
              Positioned(
                bottom: 1, right: 1,
                child: Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.surface(context), width: 2),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // ── Infos driver ─────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom + étoile + note
                Row(
                  children: [
                    Text(
                      'Alexander Wright',
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Étoile emoji
                    const Text('⭐', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 3),
                    Text(
                      '4.9',
                      style: TextStyle(
                        color: Colors.amber.shade500,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                // Voiture • couleur • plaque
                Text(
                  'Tesla Model S  •  White  •  KRE 9042',
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.subtext(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ── Bouton chat ──────────────────────────────────────
          GestureDetector(
            onTap: () {
              // → Navigator.pushNamed(context, AppRouter.chat)
            },
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.primaryPurple.withOpacity(0.25)),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.primaryPurple,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}