// lib/pages/tracking/completion/ride_completion_page.dart

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
  int _selectedStars = 5;

  late final AnimationController _fadeCtrl;
  late final AnimationController _scaleCtrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

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
      // Guard: do nothing if widget was already disposed
      if (!mounted) return;
      setState(() => _loading = false);
      _fadeCtrl.forward();
      Future.delayed(const Duration(milliseconds: 80), () {
        if (!mounted) return;
        _scaleCtrl.forward();
      });
    });
  }

  @override
  void dispose() {
    // Stop controllers before disposing so no callbacks fire afterward
    _fadeCtrl.stop();
    _scaleCtrl.stop();
    _fadeCtrl.dispose();
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _backToOnline() {
    // Stop animations immediately before popping to prevent
    // the '_dependents.isEmpty' assertion on navigation
    _fadeCtrl.stop();
    _scaleCtrl.stop();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: _loading ? _buildLoading(context) : _buildCompletion(context),
    );
  }

  // ── Loading ─────────────────────────────────────────────────────
  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
                color: AppColors.primaryPurple, strokeWidth: 3),
          ),
          const SizedBox(height: 16),
          Text(
            'Completing ride...',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.subtext(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Completion ──────────────────────────────────────────────────
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

              // Success icon + title
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
                        child: const Icon(Icons.check_rounded,
                            color: AppColors.success, size: 34),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Ride Completed',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text(context),
                      ),
                    ),
                  ],
                ),
              ),

              _SummaryCard(ride: ride),
              const SizedBox(height: 10),

              _EarningsCard(
                ridePrice: ride.earningsAmount / 0.70,
                driverEarnings: ride.earningsAmount,
              ),
              const SizedBox(height: 10),

              _RatingCard(
                selectedStars: _selectedStars,
                onStarTap: (s) => setState(() => _selectedStars = s),
              ),

              const Spacer(),

              Center(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.flag_outlined,
                      size: 14, color: AppColors.subtext(context)),
                  label: Text('Report Issue',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColors.subtext(context),
                          fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 6),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  // ← uses _backToOnline() which stops animations first
                  onPressed: _backToOnline,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Back to Online',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor   = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder   : const Color(0xFFE5E7EB);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Passenger row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.purpleGradient),
                  child: Center(
                    child: Text(ride.passenger.avatarInitial,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ride.passenger.name,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text(context))),
                      const SizedBox(height: 2),
                      Row(children: [
                        const Icon(Icons.star_rounded,
                            size: 12, color: Color(0xFFFFC107)),
                        const SizedBox(width: 3),
                        Text(ride.passenger.rating.toStringAsFixed(1),
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.subtext(context))),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: borderColor),

          // Route
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 11, height: 11,
                      decoration: const BoxDecoration(
                          color: AppColors.primaryPurple,
                          shape: BoxShape.circle),
                    ),
                    SizedBox(
                      width: 11, height: 26,
                      child: CustomPaint(painter: _DashedLinePainter()),
                    ),
                    Container(
                      width: 11, height: 11,
                      decoration: BoxDecoration(
                        color: cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.primaryPurple, width: 2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 11,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(ride.pickupAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.text(context),
                                  height: 1)),
                        ),
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        height: 11,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(ride.dropOffAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.text(context),
                                  height: 1)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: borderColor),

          // Duration + Distance
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _MetaCell(
                      icon: Icons.schedule_outlined,
                      value: '${ride.etaMinutes} min',
                      label: 'Duration'),
                ),
                VerticalDivider(width: 1, thickness: 1, color: borderColor),
                Expanded(
                  child: _MetaCell(
                      icon: Icons.route_outlined,
                      value: '${ride.distanceKm.toStringAsFixed(1)} km',
                      label: 'Distance'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dashed line ───────────────────────────────────────────────────────────────
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashH = 3.0;
    const gapH  = 3.0;
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
  bool shouldRepaint(_DashedLinePainter _) => false;
}

// ── Meta cell ─────────────────────────────────────────────────────────────────
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
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text(context))),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: AppColors.subtext(context))),
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
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final cardColor   = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder   : const Color(0xFFE5E7EB);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('EARNINGS',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.subtext(context),
                  letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ride price',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.text(context),
                      fontWeight: FontWeight.w500)),
              Text('${ridePrice.toStringAsFixed(0)} TND',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text(context))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('You earn',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColors.text(context),
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 1),
                  Text('After commission',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.subtext(context))),
                ],
              ),
              Text('+${driverEarnings.toStringAsFixed(0)} TND',
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Rating card ───────────────────────────────────────────────────────────────
class _RatingCard extends StatelessWidget {
  final int selectedStars;
  final ValueChanged<int> onStarTap;
  const _RatingCard(
      {required this.selectedStars, required this.onStarTap});

  @override
  Widget build(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final cardColor   = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder   : const Color(0xFFE5E7EB);
    final inactiveStar =
        isDark ? const Color(0xFF2A3345) : const Color(0xFFD1D5DB);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Text('Rate your passenger',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text(context))),
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
                    filled
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 36,
                    color: filled
                        ? const Color(0xFFFFC107)
                        : inactiveStar,
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