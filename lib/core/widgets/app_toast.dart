import 'package:flutter/material.dart';

/// Centralized toast utility for the driver app.
/// Shows a themed floating SnackBar at the bottom of the screen.
class AppToast {
  AppToast._();

  static void success(BuildContext context, String message) {
    _show(context, message, const Color(0xFF10B981), Icons.check_circle_rounded);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, const Color(0xFFEF4444), Icons.error_rounded);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, const Color(0xFFA855F7), Icons.info_rounded);
  }

  static void _show(BuildContext context, String message, Color bg, IconData icon) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: bg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          duration: const Duration(seconds: 3),
          elevation: 4,
        ),
      );
  }
}
