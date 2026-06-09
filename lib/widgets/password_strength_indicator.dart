import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Password Strength Level
// ─────────────────────────────────────────────────────────────────────────────

enum PasswordStrength { none, weak, medium, strong }

PasswordStrength evaluateStrength(String password) {
  if (password.isEmpty) return PasswordStrength.none;

  int score = 0;
  if (password.length >= 8) score++;
  if (RegExp(r'[A-Z]').hasMatch(password)) score++;
  if (RegExp(r'[0-9]').hasMatch(password)) score++;
  if (RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:,.<>?/\\|`~]').hasMatch(password)) score++;

  if (score <= 1) return PasswordStrength.weak;
  if (score <= 2) return PasswordStrength.medium;
  return PasswordStrength.strong;
}

// ─────────────────────────────────────────────────────────────────────────────
// Strength Bar
// ─────────────────────────────────────────────────────────────────────────────

class PasswordStrengthBar extends StatelessWidget {
  final String password;

  const PasswordStrengthBar({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final strength = evaluateStrength(password);
    if (strength == PasswordStrength.none) return const SizedBox.shrink();

    final (label, color, segments) = switch (strength) {
      PasswordStrength.weak => ('Weak', AppColors.error, 1),
      PasswordStrength.medium => ('Medium', const Color(0xFFF59E0B), 2),
      PasswordStrength.strong => ('Strong', const Color(0xFF22C55E), 3),
      PasswordStrength.none => ('', Colors.transparent, 0),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          children: List.generate(3, (i) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                decoration: BoxDecoration(
                  color: i < segments
                      ? color
                      : AppColors.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall(context).copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
