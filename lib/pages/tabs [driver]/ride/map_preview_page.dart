import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/pages/tabs%20%5Bdriver%5D/ActiveRide/drivercard.dart';
import '_RouteCard.dart';
import '_EtaBottomSheet.dart';

class MapPreviewPage extends StatefulWidget {
  const MapPreviewPage({super.key});

  @override
  State<MapPreviewPage> createState() => _MapPreviewPageState();
}

class _MapPreviewPageState extends State<MapPreviewPage> {
  int _selectedRoute = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          // ── 1. MAP FULLSCREEN ──────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'images/map_preview.png',
              fit: BoxFit.cover,
            ),
          ),

          // ── 2. OVERLAY GRADIENT (bas) ──────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: 280,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          // ── 3. ROUTE CARDS (centre map) ────────────────────
          Positioned(
            top: MediaQuery.of(context).size.height * 0.32,
            left: MediaQuery.of(context).size.width * 0.28,
            child: RouteCard(
              duration: '54 min',
              distance: '72 km',
              isSelected: _selectedRoute == 0,
              onTap: () => setState(() => _selectedRoute = 0),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.42,
            left: MediaQuery.of(context).size.width * 0.35,
            child: RouteCard(
              duration: '53 min',
              distance: '71.4 km',
              isSelected: _selectedRoute == 1,
              onTap: () => setState(() => _selectedRoute = 1),
            ),
          ),

          // ── 4. BACK + LAYERS BUTTONS ───────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _MapBtn(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    _MapBtn(
                      icon: Icons.layers_outlined,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── 5. BOTTOM SHEET (ETA + DriverCard) ────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DriverCard(),
                EtaBottomSheet(
                  selectedRoute: _selectedRoute,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bouton carte ──────────────────────────────────────────────────────────────
class _MapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}