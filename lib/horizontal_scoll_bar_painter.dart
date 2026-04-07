import 'package:flutter/material.dart';

class HorizontalScrollbarPainter extends CustomPainter {
  const HorizontalScrollbarPainter({
    required this.thumbLeft,
    required this.thumbExtent,
  });

  final double thumbLeft;
  final double thumbExtent;

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;
    final thumbPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.20)
      ..style = PaintingStyle.fill;

    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 4, size.width, size.height - 8),
      const Radius.circular(999),
    );
    canvas.drawRRect(trackRect, trackPaint);

    final thumbRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(thumbLeft, 4, thumbExtent, size.height - 8),
      const Radius.circular(999),
    );
    canvas.drawRRect(thumbRect, thumbPaint);
  }

  @override
  bool shouldRepaint(covariant HorizontalScrollbarPainter oldDelegate) {
    return oldDelegate.thumbLeft != thumbLeft ||
        oldDelegate.thumbExtent != thumbExtent;
  }
}
