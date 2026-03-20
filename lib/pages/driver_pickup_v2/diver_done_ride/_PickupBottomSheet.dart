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

    return CustomScrollView(
      controller: scrollController,
      slivers: [

        // ── Handle ────────────────────────────────────────
        SliverToBoxAdapter(
          child: Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // ── Section 1: Heading + ETA ─────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Heading to destination',
                            style: TextStyle(
                              color: AppColors.text(context),
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            )),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text('8 mins left',
                                style: TextStyle(
                                  color: AppColors.primaryPurple,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                )),
                            Text('  •  2.4 km',
                                style: TextStyle(
                                  color: AppColors.subtext(context),
                                  fontSize: 14,
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrival time box
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Arrival',
                          style: TextStyle(
                            color: AppColors.subtext(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          )),
                      const SizedBox(height: 2),
                      Text('14:24',
                          style: TextStyle(
                            color: AppColors.text(context),
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          )),
                    ],
                  ),
                ],
              ),

              Divider(
                height: 28,
                color: AppColors.border(context),
              ),

              // ── Section 2: Passenger ─────────────────────
              Row(
                children: [
                  // Avatar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      'images/driver_avatar.png',
                      width: 58, height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 58, height: 58,
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(Icons.person_rounded,
                            color: AppColors.primaryPurple, size: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PASSENGER',
                          style: TextStyle(
                            color: AppColors.subtext(context),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          )),
                      const SizedBox(height: 4),
                      Text('Sarah Jenkins',
                          style: TextStyle(
                            color: AppColors.text(context),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          )),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Section 3: Destination card ───────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: AppColors.primaryPurple, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('next destination',
                              style: TextStyle(
                                color: AppColors.subtext(context),
                                fontSize: 12,
                              )),
                          const SizedBox(height: 3),
                          Text('Hammamet, Tunisia',
                              style: TextStyle(
                                color: AppColors.text(context),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Finish Trip button ────────────────────────
              SizedBox(
                width: double.infinity,
                height: 58,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B2FFF), Color(0xFFE040FB)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
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
                        AppRouter.push(context, AppRouter.ratePassenger),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('Finish Trip',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        )),
                  ),
                ),
              ),

              const SizedBox(height: 12),

           

              SizedBox(height: bottomPad + 8),
            ]),
          ),
        ),
      ],
    );
  }
}