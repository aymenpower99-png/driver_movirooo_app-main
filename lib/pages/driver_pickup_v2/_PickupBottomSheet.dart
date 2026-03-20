import 'package:flutter/material.dart';
import 'package:moviroo_driver_app/routing/router.dart';
import 'package:moviroo_driver_app/theme/app_colors.dart';

class PickupBottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  const PickupBottomSheet({super.key, required this.scrollController});

  void _cancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('Cancel Ride?',
            style: TextStyle(
                color: AppColors.text(context),
                fontWeight: FontWeight.w800)),
        content: Text(
          'Are you sure? Cancelling may affect your rating.',
          style: TextStyle(color: AppColors.subtext(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep',
                style: TextStyle(color: AppColors.primaryPurple)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AppRouter.clearAndGo(context, AppRouter.driverDashboard);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel Ride',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      controller: scrollController,
      slivers: [

        // ── Handle ────────────────────────────────────────
        SliverToBoxAdapter(
          child: Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // ── ETA + badge ──────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('5 mins away',
                            style: TextStyle(
                              color: AppColors.text(context),
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            )),
                        const SizedBox(height: 4),
                        Text('Pickup at 14:20  •  1.4 km',
                            style: TextStyle(
                              color: AppColors.subtext(context),
                              fontSize: 13,
                            )),
                      ],
                    ),
                  ),
                  _OnTimeBadge(),
                ],
              ),

              const SizedBox(height: 16),

              // ── Client card ──────────────────────────────
              _ThemedCard(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'images/driver_avatar.png',
                        width: 52, height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(Icons.person_rounded,
                              color: AppColors.primaryPurple, size: 26),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sarah Ben Ali',
                              style: TextStyle(
                                color: AppColors.text(context),
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              )),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Text('⭐',
                                  style: TextStyle(fontSize: 11)),
                              const SizedBox(width: 4),
                              Text('4.8  •  12 rides',
                                  style: TextStyle(
                                    color: AppColors.subtext(context),
                                    fontSize: 13,
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _Tag(label: 'Client'),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ── Pickup location ──────────────────────────
              _ThemedCard(
                child: Row(
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.location_on_rounded,
                          color: AppColors.primaryPurple, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pickup location',
                            style: TextStyle(
                              color: AppColors.subtext(context),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            )),
                        const SizedBox(height: 3),
                        Text('Avenue Habib Bourguiba',
                            style: TextStyle(
                              color: AppColors.text(context),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            )),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Action buttons ───────────────────────────
              Row(
                children: [
                  _ActionBtn(
                    icon: Icons.call_outlined,
                    label: 'Call Client',
                    onTap: () {},
                  ),
                  _ActionBtn(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Chat',
                    onTap: () => AppRouter.push(context, AppRouter.chat),
                  ),
                  _ActionBtn(
                    icon: Icons.warning_amber_rounded,
                    label: 'Report Issue',
                    onTap: () {},
                  ),
                  _ActionBtn(
                    icon: Icons.cancel_outlined,
                    label: 'Cancel Ride',
                    isRed: true,
                    onTap: () => _cancelDialog(context),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () =>
                        AppRouter.push(context, AppRouter.driverDone),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('ARRIVED',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 1.5,
                        )),
                  ),
                ),
              ),

              SizedBox(height: bottomPad + 20),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _OnTimeBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded,
              color: AppColors.subtext(context), size: 14),
          const SizedBox(width: 6),
          Text('On time',
              style: TextStyle(
                color: AppColors.text(context),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              )),
        ],
      ),
    );
  }
}

class _ThemedCard extends StatelessWidget {
  final Widget child;
  const _ThemedCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: child,
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Text(label,
          style: TextStyle(
            color: AppColors.text(context),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          )),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isRed;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isRed = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isRed ? AppColors.error : AppColors.text(context);
    final bg    = isRed
        ? AppColors.error.withOpacity(0.10)
        : AppColors.surface(context);
    final border = isRed
        ? AppColors.error.withOpacity(0.25)
        : AppColors.border(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 54, height: 54,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
                border: Border.all(color: border),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                )),
          ],
        ),
      ),
    );
  }
}