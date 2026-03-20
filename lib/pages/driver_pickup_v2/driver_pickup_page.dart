import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import '_PickupTopBar.dart';
import '_PickupBottomSheet.dart';

class DriverPickupPage extends StatefulWidget {
  const DriverPickupPage({super.key});

  @override
  State<DriverPickupPage> createState() => _DriverPickupPageState();
}

class _DriverPickupPageState extends State<DriverPickupPage>
    with SingleTickerProviderStateMixin {

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  static const double _minSize  = 0.12;
  static const double _initSize = 0.55;
  static const double _maxSize  = 1.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      // ✅ Toujours noir — fond de la map
      backgroundColor:AppColors.bg(context),
      body: Stack(
        children: [

          // ── 1. MAP fullscreen ──────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'images/map_preview.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF0D0D1A),
                child: const Center(
                  child: Icon(Icons.map_outlined,
                      color: Colors.white12, size: 64),
                ),
              ),
            ),
          ),

          // ── 2. Top gradient ────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: 180,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.80),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── 3. TopBar ─────────────────────────────────────
          const Positioned(
            top: 0, left: 0, right: 0,
            child: PickupTopBar(),
          ),

          // ── 4. Route badge ─────────────────────────────────
          Positioned(
            top: sh * 0.18,
            right: 16,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: _RouteInfoBadge(),
            ),
          ),

          // ── 5. DraggableScrollableSheet ────────────────────
          DraggableScrollableSheet(
            initialChildSize: _initSize,
            minChildSize: _minSize,
            maxChildSize: _maxSize,
            snap: true,
            snapSizes: const [_minSize, _initSize, _maxSize],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  // ✅ Surface du thème pour le sheet
                  color: AppColors.surface(context),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 30,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: PickupBottomSheet(
                  scrollController: scrollController,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Route badge — toujours dark (sur map) ────────────────────────────────────
class _RouteInfoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        // ✅ Hardcodé sombre — toujours sur la map
        color:AppColors.bg(context).withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children:  [
              Icon(Icons.navigation_rounded,
                  color: Color(0xFF9B59FF), size: 13),
              SizedBox(width: 5),
              Text('Current route',
                  style: TextStyle(
                    color: AppColors.text(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
          const SizedBox(height: 4),
          Text('1.4 km to pickup',
              style: TextStyle(
                color: AppColors.text(context),
                fontWeight: FontWeight.w800,
                fontSize: 14,
              )),
        ],
      ),
    );
  }
}