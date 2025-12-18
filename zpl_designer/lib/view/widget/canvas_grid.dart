import 'package:flutter/material.dart';

class CanvasGrid extends StatelessWidget {
  final double width;
  final double height;
  final int widthMm;
  final int heightMm;

  const CanvasGrid({
    super.key,
    required this.width,
    required this.height,
    required this.widthMm,
    required this.heightMm,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _GridPainter(
        widthMm: widthMm,
        heightMm: heightMm,
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final int widthMm;
  final int heightMm;

  _GridPainter({
    required this.widthMm,
    required this.heightMm,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pixelsPerMmX = size.width / widthMm;
    final pixelsPerMmY = size.height / heightMm;

    // Fine grid (1mm interval) - very subtle
    final finePaint = Paint()
      ..color = const Color(0xFFE8E8E8)
      ..strokeWidth = 0.3;

    // Minor grid (5mm interval) - subtle
    final minorPaint = Paint()
      ..color = const Color(0xFFD0D0D0)
      ..strokeWidth = 0.5;

    // Major grid (10mm interval) - visible but not dominant
    final majorPaint = Paint()
      ..color = const Color(0xFFB0B0B0)
      ..strokeWidth = 0.8;

    // Draw vertical lines
    for (int mm = 0; mm <= widthMm; mm++) {
      final x = mm * pixelsPerMmX;
      Paint paint;
      if (mm % 10 == 0) {
        paint = majorPaint;
      } else if (mm % 5 == 0) {
        paint = minorPaint;
      } else {
        paint = finePaint;
      }
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (int mm = 0; mm <= heightMm; mm++) {
      final y = mm * pixelsPerMmY;
      Paint paint;
      if (mm % 10 == 0) {
        paint = majorPaint;
      } else if (mm % 5 == 0) {
        paint = minorPaint;
      } else {
        paint = finePaint;
      }
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw ruler labels (10mm intervals)
    const textStyle = TextStyle(
      color: Color(0xFF888888),
      fontSize: 9,
      fontWeight: FontWeight.w400,
    );

    // X-axis labels (top)
    for (int mm = 10; mm <= widthMm; mm += 10) {
      final x = mm * pixelsPerMmX;
      final textPainter = TextPainter(
        text: TextSpan(text: '$mm', style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, 3));
    }

    // Y-axis labels (left)
    for (int mm = 10; mm <= heightMm; mm += 10) {
      final y = mm * pixelsPerMmY;
      final textPainter = TextPainter(
        text: TextSpan(text: '$mm', style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(3, y - textPainter.height / 2));
    }

    // Origin marker
    final originPaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 1.5;

    canvas.drawLine(const Offset(0, 0), Offset(12 * pixelsPerMmX.clamp(0.5, 2.0), 0), originPaint);
    canvas.drawLine(const Offset(0, 0), Offset(0, 12 * pixelsPerMmY.clamp(0.5, 2.0)), originPaint);
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.widthMm != widthMm || oldDelegate.heightMm != heightMm;
  }
}
