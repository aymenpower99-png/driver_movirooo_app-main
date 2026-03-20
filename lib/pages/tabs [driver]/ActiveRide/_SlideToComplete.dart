import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class SlideToComplete extends StatefulWidget {
  final VoidCallback onCompleted;
  const SlideToComplete({super.key, required this.onCompleted});

  @override
  State<SlideToComplete> createState() => _SlideToCompleteState();
}

class _SlideToCompleteState extends State<SlideToComplete> {
  double _dragPosition = 0;
  static const double _btnSize = 56.0;
  bool _completed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.40),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxDrag = constraints.maxWidth - _btnSize - 8;

          return Stack(
            alignment: Alignment.centerLeft,
            children: [

              // ── Label centré ─────────────────────────────
              Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: _dragPosition < maxDrag * 0.3 ? 1.0 : 0.0,
                  child: Text(
                    'SLIDE TO COMPLETE TRIP',
                    style: AppTextStyles.bodySmall(context).copyWith(
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              // ── Thumb ────────────────────────────────────
              Positioned(
                left: 4 + _dragPosition,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_completed) return;
                    setState(() {
                      _dragPosition =
                          (_dragPosition + details.delta.dx)
                              .clamp(0.0, maxDrag);
                    });
                  },
                  onHorizontalDragEnd: (_) {
                    if (_dragPosition >= maxDrag * 0.85) {
                      setState(() {
                        _dragPosition = maxDrag;
                        _completed = true;
                      });
                      Future.delayed(
                        const Duration(milliseconds: 300),
                        widget.onCompleted,
                      );
                    } else {
                      // Snap back
                      setState(() => _dragPosition = 0);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _btnSize,
                    height: _btnSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _completed
                          ? Icons.check_rounded
                          : Icons.chevron_right_rounded,
                      color: AppColors.primaryPurple,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}