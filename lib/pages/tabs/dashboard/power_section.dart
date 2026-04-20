import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// POWER SECTION
// ─────────────────────────────────────────────────────────────────────────────
class PowerSection extends StatefulWidget {
  final bool isOnline;
  final Animation<double> bounceScale;
  final VoidCallback onToggle;

  const PowerSection({
    super.key,
    required this.isOnline,
    required this.bounceScale,
    required this.onToggle,
  });

  @override
  State<PowerSection> createState() => _PowerSectionState();
}

class _PowerSectionState extends State<PowerSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  static const Color _offlineColor = Color(0xFFB0B7C3);

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseScale = Tween<double>(
      begin: 1.0,
      end: 1.35,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));
    _pulseOpacity = Tween<double>(
      begin: 0.45,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));

    if (widget.isOnline) _pulseCtrl.repeat();
  }

  @override
  void didUpdateWidget(PowerSection old) {
    super.didUpdateWidget(old);
    if (widget.isOnline && !old.isOnline) {
      _pulseCtrl.repeat();
    } else if (!widget.isOnline && old.isOnline) {
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.isOnline ? AppColors.success : _offlineColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: widget.onToggle,
          child: ScaleTransition(
            scale: widget.bounceScale,
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.isOnline)
                    AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (_, _) => Transform.scale(
                        scale: _pulseScale.value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.success.withValues(
                              alpha: _pulseOpacity.value,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (widget.isOnline)
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success.withValues(alpha: 0.13),
                      ),
                    ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeInOut,
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeColor,
                      boxShadow: widget.isOnline
                          ? [
                              BoxShadow(
                                color: AppColors.success.withValues(
                                  alpha: 0.38,
                                ),
                                blurRadius: 28,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : [],
                    ),
                    child: const Icon(
                      Icons.power_settings_new_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 22),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                  ),
              child: child,
            ),
          ),
          child: Text(
            widget.isOnline
                ? AppLocalizations.of(
                    context,
                  ).translate('dashboard_you_are_online')
                : AppLocalizations.of(
                    context,
                  ).translate('dashboard_you_are_offline'),
            key: ValueKey(widget.isOnline),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.text(context),
            ),
          ),
        ),

        const SizedBox(height: 6),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: Text(
            widget.isOnline
                ? AppLocalizations.of(
                    context,
                  ).translate('dashboard_available_for_rides')
                : AppLocalizations.of(
                    context,
                  ).translate('dashboard_tap_to_go_online'),
            key: ValueKey('sub_${widget.isOnline}'),
            style: TextStyle(fontSize: 13, color: AppColors.subtext(context)),
          ),
        ),
      ],
    );
  }
}
