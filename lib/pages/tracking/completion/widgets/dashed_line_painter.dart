// lib/pages/tracking/completion/widgets/dashed_line_painter.dart

import 'package:flutter/material.dart';

class DashedLinePainter extends CustomPainter {
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
  bool shouldRepaint(DashedLinePainter _) => false;
}
