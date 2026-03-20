import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moviroo_driver_app/pages/driver_pickup_v2/driver_pickup_page.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import '_PickupTopBar.dart';
import '_PickupBottomSheet.dart';

class DriverDone extends StatefulWidget {
  const DriverDone({super.key});

  @override
  _DriverDoneState createState() => _DriverDoneState();
}

class _DriverDoneState extends State<DriverDone>
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
      backgroundColor:AppColors.bg(context),
      body: Stack(
        children: [

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

          const Positioned(
            top: 0, left: 0, right: 0,
            child: PickupTopBar(),
          ),

          Positioned(
            top: sh * 0.18,
            right: 16,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: _RouteInfoBadge(),
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: _initSize,
            minChildSize: _minSize,
            maxChildSize: _maxSize,
            snap: true,
            snapSizes: const [_minSize, _initSize, _maxSize],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
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

class _RouteInfoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
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