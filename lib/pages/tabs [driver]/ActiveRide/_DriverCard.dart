import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class DriverCard extends StatelessWidget {
  const DriverCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
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
                radius: 28,
                backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.15),
                backgroundImage:
                    const AssetImage('images/driver_avatar.png'),
                onBackgroundImageError: (_, _) {},
                child: Icon(Icons.person_rounded,
                    color: AppColors.primaryPurple, size: 28),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  width: 14, height: 14,
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

          const SizedBox(width: 14),

          // ── Infos ────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sarah L.',
                    style: AppTextStyles.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 13,
                        color: AppColors.primaryPurple),
                    const SizedBox(width: 3),
                    Text('Airport Terminal 2',
                        style: AppTextStyles.bodySmall(context).copyWith(
                            color: AppColors.subtext(context))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star_rounded,
                        size: 13, color: Colors.amber.shade500),
                    const SizedBox(width: 3),
                    Text('4.9',
                        style: AppTextStyles.bodySmall(context).copyWith(
                            fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Container(
                      width: 4, height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.subtext(context),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('BMW 5 Series',
                        style: AppTextStyles.bodySmall(context).copyWith(
                            color: AppColors.subtext(context))),
                  ],
                ),
              ],
            ),
          ),

          // ── Actions ──────────────────────────────────────────
          Row(
            children: [
              _ActionBtn(
                icon: Icons.phone_outlined,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _ActionBtn(
                icon: Icons.chat_bubble_outline_rounded,
                onTap: () {Navigator.pushNamed(context, '/chat');},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.primaryPurple.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, color: AppColors.primaryPurple, size: 20),
      ),
    );
  }
}