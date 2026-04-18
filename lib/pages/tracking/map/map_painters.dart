import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Static bitmap renderers for custom map markers.
abstract final class MapPainters {
  // ─── PICKUP MARKER ───────────────────────────────────────────────
  // Canvas size: 160x160
  // Filled circle diameter: 80px (radius 40)
  // White center dot diameter: 22px (radius 11)
  static Future<Uint8List> renderPickupBitmap() async {
    const sz = 160.0;
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);

    canvas.drawCircle(
      const Offset(sz / 2, sz / 2),
      40,
      Paint()..color = const Color(0xFFA855F7),
    );
    canvas.drawCircle(
      const Offset(sz / 2, sz / 2),
      11,
      Paint()..color = Colors.white,
    );

    final img = await rec.endRecording().toImage(sz.toInt(), sz.toInt());
    return (await img.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  // ─── DROP-OFF MARKER ─────────────────────────────────────────────
  // Canvas size: 80x100
  // Pin width: 80px, height: 100px
  // White center dot radius: 16px
  static Future<Uint8List> renderDropoffBitmap() async {
    const w = 80.0, h = 100.0;
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);

    final path = Path()
      ..moveTo(w / 2, h)
      ..cubicTo(w / 2, h, 0, h * 0.6, 0, h * 0.38)
      ..arcToPoint(Offset(w, h * 0.38), radius: Radius.circular(w / 2))
      ..cubicTo(w, h * 0.6, w / 2, h, w / 2, h)
      ..close();

    canvas.drawPath(path, Paint()..color = const Color(0xFFA855F7));
    canvas.drawCircle(
      Offset(w / 2, h * 0.38),
      16,
      Paint()..color = Colors.white,
    );

    final img = await rec.endRecording().toImage(w.toInt(), h.toInt());
    return (await img.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  // ─── DRIVER MARKER — Google Maps style navigation arrow ──────────
  // A teardrop-shaped chevron pointing in the direction of travel,
  // exactly like the Google Maps blue navigation puck.
  //
  // Canvas:  200 × 200
  // Outer puck radius:  48
  // Inner white ring:   38
  // Arrow triangle:     sharp chevron pointing up (north = 0°)
  // The caller must rotate the PointAnnotation by the driver bearing.
  static Future<Uint8List> renderCarBitmap() async {
    const sz = 200.0;
    const cx = sz / 2;
    const cy = sz / 2;

    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec);

    // 1. Outer filled circle (primaryPurple)
    canvas.drawCircle(
      const Offset(cx, cy),
      48,
      Paint()..color = const Color(0xFFA855F7),
    );

    // 2. White ring between outer and inner
    canvas.drawCircle(
      const Offset(cx, cy),
      38,
      Paint()..color = Colors.white,
    );

    // 3. Inner filled circle (secondaryPurple)
    canvas.drawCircle(
      const Offset(cx, cy),
      32,
      Paint()..color = const Color(0xFF7C3AED),
    );

    // 4. Navigation chevron arrow — white, pointing UP (north)
    //    Tip at top, two base corners at bottom-left and bottom-right.
    //    Hollow chevron made of two triangles (outer minus inner).
    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Outer arrow shape
    final outer = Path()
      ..moveTo(cx, cy - 26)        // tip (top)
      ..lineTo(cx - 18, cy + 16)   // bottom-left
      ..lineTo(cx, cy + 6)         // inner bottom-center notch
      ..lineTo(cx + 18, cy + 16)   // bottom-right
      ..close();

    canvas.drawPath(outer, arrowPaint);

    final img = await rec.endRecording().toImage(sz.toInt(), sz.toInt());
    return (await img.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
}