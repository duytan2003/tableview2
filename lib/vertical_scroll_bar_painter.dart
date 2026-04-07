import 'package:flutter/material.dart';

class VerticalScrollbarPainter extends CustomPainter {
  const VerticalScrollbarPainter({
    required this.thumbTop,
    required this.thumbExtent,
    required this.thumbColor,
    required this.trackColor,
  });

  final double thumbTop;
  final double thumbExtent;
  final Color thumbColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.fill;
    final thumbPaint = Paint()
      ..color = thumbColor
      ..style = PaintingStyle.fill;

    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 0, size.width - 4, size.height),
      const Radius.circular(999),
    );
    canvas.drawRRect(trackRect, trackPaint);

    final thumbRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, thumbTop, size.width - 4, thumbExtent),
      const Radius.circular(999),
    );
    canvas.drawRRect(thumbRect, thumbPaint);
  }

  @override
  bool shouldRepaint(covariant VerticalScrollbarPainter oldDelegate) {
    return oldDelegate.thumbTop != thumbTop ||
        oldDelegate.thumbExtent != thumbExtent ||
        oldDelegate.thumbColor != thumbColor ||
        oldDelegate.trackColor != trackColor;
  }
}

