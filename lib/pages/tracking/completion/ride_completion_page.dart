// lib/pages/tracking/completion/ride_completion_page.dart
//
// Flow:
//   1. Brief loading screen (~1.5s) with purple spinner
//   2. Animated completion screen (no scroll — fits one screen, no overflow):
//      • Green success circle + "Ride Completed"
//      • Ride summary card:
//          - Passenger row (avatar, name, rating)
//          - Route: filled purple circle (pickup) → dashed line → empty purple circle (dropoff)
//          - Duration / Distance cells
//      • Earnings card (ride price, driver earnings, commission note)
//      • Rate passenger (5 stars only — no note, no tags)
//      • Report Issue link
//      • "Back to Online" purple button

import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';
import 'package:moviroo_driver_app/pages/tracking/ride_model.dart';

class RideCompletionPage extends StatefulWidget {
  final RideModel ride;

  const RideCompletionPage({super.key, required this.ride});

  static Route<void> route(RideModel ride) => MaterialPageRoute(
        builder: (_) => RideCompletionPage(ride: ride),
      );

  @override
  State<RideCompletionPage> createState() => _RideCompletionPageState();
}

class _RideCompletionPageState extends State<RideCompletionPage>
    with TickerProviderStateMixin {
  bool _loading = true;

  late AnimationController _fadeCtrl;
  late Animation<double> _fade;
  late AnimationController _scaleCtrl;
  late Animation<double> _scale;

  int _selectedStars = 5;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    _scaleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _scale = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() => _loading = false);
      _fadeCtrl.forward();
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) _scaleCtrl.forward();
      });
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _loading ? _buildLoading() : _buildCompletion(context),
    );
  }

  // ── Loading screen ──────────────────────────────────────────────
  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              color: AppColors.primaryPurple,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Completing ride...',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF9AA3AD),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Completion screen (no scroll, no overflow) ──────────────────
  Widget _buildCompletion(BuildContext context) {
    final ride = widget.ride;

    return FadeTransition(
      opacity: _fade,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ── Top breathing room + success icon + title ─────
              Padding(
                padding: const EdgeInsets.only(top: 28, bottom: 16),
                child: Column(
                  children: [
                    ScaleTransition(
                      scale: _scale,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.success,
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Ride Completed',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF141414),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Ride summary card ─────────────────────────────
              _SummaryCard(ride: ride),

              const SizedBox(height: 10),

              // ── Earnings card ─────────────────────────────────
              _EarningsCard(
                ridePrice: ride.earningsAmount / 0.70,
                driverEarnings: ride.earningsAmount,
              ),

              const SizedBox(height: 10),

              // ── Rate passenger (stars only) ───────────────────
              _RatingCard(
                selectedStars: _selectedStars,
                onStarTap: (s) => setState(() => _selectedStars = s),
              ),

              const Spacer(),

              // ── Report issue ──────────────────────────────────
              Center(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.flag_outlined,
                      size: 14, color: Color(0xFF9AA3AD)),
                  label: const Text(
                    'Report Issue',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9AA3AD),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // ── Back to Online ────────────────────────────────
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Back to Online',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final RideModel ride;
  const _SummaryCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // ── Passenger row ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.purpleGradient,
                  ),
                  child: Center(
                    child: Text(
                      ride.passenger.avatarInitial,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.passenger.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF141414),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 12, color: Color(0xFFFFC107)),
                          const SizedBox(width: 3),
                          Text(
                            ride.passenger.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9AA3AD),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // ── Route: purple circles + dashed connector ──────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon column
                Column(
                  children: [
                    // Pickup — filled purple circle
                    Container(
                      width: 11,
                      height: 11,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryPurple,
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Dashed connector
                    SizedBox(
                      width: 11,
                      height: 26,
                      child: CustomPaint(
                        painter: _DashedLinePainter(),
                      ),
                    ),
                    // Dropoff — empty circle with purple border
                    Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryPurple,
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                // Address column — vertically aligned with icons
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pickup address — vertically centred on the filled circle
                      SizedBox(
                        height: 11,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            ride.pickupAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF141414),
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      // Dropoff address — vertically centred on the empty circle
                      SizedBox(
                        height: 11,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            ride.dropOffAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF141414),
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // ── Duration + Distance ───────────────────────────────
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _MetaCell(
                    icon: Icons.schedule_outlined,
                    value: '${ride.etaMinutes} min',
                    label: 'Duration',
                  ),
                ),
                const VerticalDivider(
                    width: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                Expanded(
                  child: _MetaCell(
                    icon: Icons.route_outlined,
                    value: '${ride.distanceKm.toStringAsFixed(1)} km',
                    label: 'Distance',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dashed vertical line between route stops ──────────────────────────────────
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashH = 3.0;
    const gapH = 3.0;
    final paint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    double y = 0;
    final cx = size.width / 2;
    while (y < size.height) {
      canvas.drawLine(Offset(cx, y), Offset(cx, y + dashH), paint);
      y += dashH + gapH;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => false;
}

// ── Shared meta cell (duration / distance) ───────────────────────────────────
class _MetaCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _MetaCell(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Icon(icon, size: 15, color: AppColors.primaryPurple),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF141414))),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFF9AA3AD))),
        ],
      ),
    );
  }
}

// ── Earnings card ─────────────────────────────────────────────────────────────
class _EarningsCard extends StatelessWidget {
  final double ridePrice;
  final double driverEarnings;
  const _EarningsCard(
      {required this.ridePrice, required this.driverEarnings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EARNINGS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9AA3AD),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ride price',
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF141414),
                      fontWeight: FontWeight.w500)),
              Text(
                '${ridePrice.toStringAsFixed(0)} TND',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF141414)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('You earn',
                      style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF141414),
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: 1),
                  Text('After commission',
                      style: TextStyle(
                          fontSize: 10, color: Color(0xFF9AA3AD))),
                ],
              ),
              Text(
                '+${driverEarnings.toStringAsFixed(0)} TND',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Rating card (stars only) ──────────────────────────────────────────────────
class _RatingCard extends StatelessWidget {
  final int selectedStars;
  final ValueChanged<int> onStarTap;

  const _RatingCard({
    required this.selectedStars,
    required this.onStarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          const Text(
            'Rate your passenger',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF141414),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < selectedStars;
              return GestureDetector(
                onTap: () => onStarTap(i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 36,
                    color: filled
                        ? const Color(0xFFFFC107)
                        : const Color(0xFFD1D5DB),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}