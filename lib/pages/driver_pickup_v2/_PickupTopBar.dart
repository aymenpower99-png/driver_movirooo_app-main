import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';

class PickupTopBar extends StatelessWidget {
  const PickupTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // Back button
            GestureDetector(
              onTap: () => Navigator.canPop(context)
                  ? Navigator.pop(context)
                  : null,
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  // ✅ Toujours sombre — on est sur la map
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 16),
              ),
            ),

            const SizedBox(width: 12),

            // Titles — toujours blancs (sur map)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Driver pickup',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      )),
                  const Text('Heading to client',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      )),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bg(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF1C5C35), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.20),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7, height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2ECC71),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Text('Online',
                      style: TextStyle(
                        color: Color(0xFF2ECC71),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}