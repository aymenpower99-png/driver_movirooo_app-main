// lib/pages/tracking/widgets/skeleton/tracking_skeleton.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';

/// Skeleton loading animation for the tracking page.
/// Displays placeholder blocks that mimic the real layout with a shimmer effect.
class TrackingSkeleton extends StatelessWidget {
  const TrackingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2A2A2E) : const Color(0xFFE0E0E0);
    final highlightColor = isDark ? const Color(0xFF3A3A3E) : const Color(0xFFF5F5F5);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1500),
      child: Column(
        children: [
          // Status bar skeleton
          _StatusBarSkeleton(delay: 0),
          // Map area skeleton
          Expanded(child: _MapSkeleton(delay: 100)),
          // Bottom sheet skeleton
          _BottomSheetSkeleton(delay: 200),
        ],
      ),
    );
  }
}

/// Skeleton for the status step indicator at the top
class _StatusBarSkeleton extends StatelessWidget {
  final int delay;
  const _StatusBarSkeleton({required this.delay});

  @override
  Widget build(BuildContext context) {
    return DelayedAnimation(
      delay: Duration(milliseconds: delay),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) => _PulsingDot(delay: delay + (index * 50))),
        ),
      ),
    );
  }
}

/// Pulsing dot for status steps
class _PulsingDot extends StatefulWidget {
  final int delay;
  const _PulsingDot({required this.delay});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DelayedAnimation(
      delay: Duration(milliseconds: widget.delay),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton for the map area
class _MapSkeleton extends StatelessWidget {
  final int delay;
  const _MapSkeleton({required this.delay});

  @override
  Widget build(BuildContext context) {
    return DelayedAnimation(
      delay: Duration(milliseconds: delay),
      child: Container(
        color: Colors.grey,
        child: const Center(
          child: Icon(Icons.map_outlined, size: 64, color: Colors.grey),
        ),
      ),
    );
  }
}

/// Skeleton for the bottom sheet (passenger info card)
class _BottomSheetSkeleton extends StatelessWidget {
  final int delay;
  const _BottomSheetSkeleton({required this.delay});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DelayedAnimation(
      delay: Duration(milliseconds: delay),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            _buildDragHandle(),
            // Passenger header
            _buildPassengerHeader(),
            const Divider(height: 1),
            // Route section
            _buildRouteSection(),
            const Divider(height: 1),
            // Action buttons
            _buildActionButtons(),
            // CTA button
            const SizedBox(height: 16),
            _buildCTAButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildPassengerHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Name and rating placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          // Contact button placeholders
          Row(
            children: List.generate(2, (index) {
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pickup
          _buildRouteItem(),
          // Connector
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Container(
              width: 2,
              height: 22,
              color: Colors.grey,
            ),
          ),
          // Drop-off
          _buildRouteItem(),
        ],
      ),
    );
  }

  Widget _buildRouteItem() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.only(top: 3),
          decoration: BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 50,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 44,
            color: Colors.grey,
          ),
          Expanded(
            child: Container(
              height: 44,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

/// Helper widget to add staggered delay to animations
class DelayedAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const DelayedAnimation({
    super.key,
    required this.child,
    required this.delay,
  });

  @override
  State<DelayedAnimation> createState() => _DelayedAnimationState();
}

class _DelayedAnimationState extends State<DelayedAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
