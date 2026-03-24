import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class EtaBottomSheet extends StatelessWidget {
  final int selectedRoute;

  const EtaBottomSheet({super.key, required this.selectedRoute});

  static const List<Map<String, String>> _routes = [
    {
      'eta': '7 mins away',
      'badge': 'PREMIUM',
      'duration': '54 min',
      'distance': '72 km',
    },
    {
      'eta': '5 mins away',
      'badge': 'STANDARD',
      'duration': '53 min',
      'distance': '71.4 km',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final route = _routes[selectedRoute];

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ─────────────────────────────────────────
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── ETA + Badge ────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    route['eta']!,
                    key: ValueKey(route['eta']),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
              // Infos route
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _InfoChip(
                    icon: Icons.access_time_rounded,
                    label: route['duration']!,
                  ),
                  const SizedBox(height: 4),
                  _InfoChip(
                    icon: Icons.straighten_rounded,
                    label: route['distance']!,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Badge type ─────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Container(
              key: ValueKey(route['badge']),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                route['badge']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Progress bar ───────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: selectedRoute == 0 ? 0.15 : 0.10,
              minHeight: 4,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF7C3AED),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Bouton démarrer ────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: const Color(0xFF7C3AED).withOpacity(0.50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.navigation_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context).translate('start_navigation'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white54),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
