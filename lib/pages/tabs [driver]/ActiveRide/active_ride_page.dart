import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '_NavigationBar.dart';
import '_DriverCard.dart';
import '_SlideToComplete.dart';

class ActiveRidePage extends StatefulWidget {
  const ActiveRidePage({super.key});

  @override
  State<ActiveRidePage> createState() => _ActiveRidePageState();
}

class _ActiveRidePageState extends State<ActiveRidePage> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  // 0.18 = collapsed (juste driver card visible)
  // 1.0  = expanded (map visible en scrollant vers le haut)
  static const double _minSize = 0.18;
  static const double _maxSize = 1.0;

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          // ── 1. MAP FULLSCREEN (fond) ───────────────────────
          Positioned.fill(
            child: Image.asset(
              'images/map_preview.png',
              fit: BoxFit.cover,
            ),
          ),

          // ── 2. NAVIGATION INSTRUCTION (haut) ──────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: NavigationInstructionBar(),
              ),
            ),
          ),

          // ── 3. BOUTONS CARTE (droite) ──────────────────────
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 100,
            child: Column(
              children: [
                _MapBtn(icon: Icons.add, onTap: () {}),
                const SizedBox(height: 8),
                _MapBtn(icon: Icons.remove, onTap: () {}),
                const SizedBox(height: 8),
                _MapBtn(icon: Icons.my_location_rounded, onTap: () {}),
              ],
            ),
          ),

          // ── 4. DRAGGABLE BOTTOM SHEET ──────────────────────
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: _minSize,
            minChildSize: _minSize,
            maxChildSize: _maxSize,
            snap: true,
            snapSizes: const [_minSize, 0.45, _maxSize],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.bg(context),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 24,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [

                    // ── Handle ─────────────────────────────
                    SliverToBoxAdapter(
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 10, bottom: 6),
                          width: 36, height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border(context),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),

                    // ── Driver Card ────────────────────────
                    SliverToBoxAdapter(
                      child: DriverCard(),
                    ),

                    // ── Slide to complete ──────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        child: SlideToComplete(
                          onCompleted: () {
                            // → page confirmation
                          },
                        ),
                      ),
                    ),

                    // ── Divider ────────────────────────────
                    SliverToBoxAdapter(
                      child: Divider(
                        color: AppColors.border(context),
                        height: 1,
                      ),
                    ),

                    // ── Trip Details (quand expanded) ──────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Trip Details',
                                style: AppTextStyles.bodyLarge(context)
                                    .copyWith(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 16),
                            _TripDetailRow(
                              icon: Icons.location_on_rounded,
                              iconColor: AppColors.primaryPurple,
                              label: 'Pickup',
                              value: 'Tunis Carthage Airport (TUN)',
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.only(left: 11),
                              child: Container(
                                width: 1.5, height: 20,
                                color: AppColors.border(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            _TripDetailRow(
                              icon: Icons.flag_rounded,
                              iconColor: Colors.green,
                              label: 'Dropoff',
                              value: 'Enfidha Hammamet Airport (NBE)',
                            ),
                            const SizedBox(height: 20),
                            Divider(color: AppColors.border(context)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _StatCard(
                                    label: 'ETA',
                                    value: '54 min',
                                    icon: Icons.access_time_rounded),
                                const SizedBox(width: 10),
                                _StatCard(
                                    label: 'Distance',
                                    value: '72 km',
                                    icon: Icons.straighten_rounded),
                                const SizedBox(width: 10),
                                _StatCard(
                                    label: 'Speed',
                                    value: '87 km/h',
                                    icon: Icons.speed_rounded),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _MapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.text(context)),
      ),
    );
  }
}

class _TripDetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  const _TripDetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.subtext(context), fontSize: 11)),
            Text(value,
                style: AppTextStyles.bodyMedium(context)
                    .copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryPurple, size: 18),
            const SizedBox(height: 6),
            Text(value,
                style: AppTextStyles.bodyMedium(context)
                    .copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.subtext(context), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}