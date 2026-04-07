import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'vertical_scroll_bar_painter.dart';

class FixedAwareVerticalScrollbar extends StatefulWidget {
  const FixedAwareVerticalScrollbar({
    super.key,
    required this.controller,
    required this.metricsListenable,
    this.minThumbExtent = 72,
  });

  final ScrollController controller;
  final ValueListenable<ScrollMetrics?> metricsListenable;
  final double minThumbExtent;

  @override
  State<FixedAwareVerticalScrollbar> createState() =>
      FixedAwareVerticalScrollbarState();
}

class FixedAwareVerticalScrollbarState
    extends State<FixedAwareVerticalScrollbar> {
  double? _dragThumbStartDy;
  double? _dragScrollStartOffset;
  bool _draggingThumb = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final thumbColor = colorScheme.onSurface.withValues(alpha: 0.30);
    final trackColor = colorScheme.onSurface.withValues(alpha: 0.06);

    return ValueListenableBuilder<ScrollMetrics?>(
      valueListenable: widget.metricsListenable,
      builder: (context, metrics, _) {
        final maxScroll = metrics?.maxScrollExtent ?? 0.0;
        final viewport = metrics?.viewportDimension ?? 0.0;
        final bool canScroll = maxScroll > 0 && viewport > 0;
        if (metrics == null || !canScroll) {
          return const SizedBox.shrink();
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final trackExtent = constraints.maxHeight;
            final pixels = metrics.pixels;
            final double thumbExtent;
            final double thumbTravel;
            final double thumbTop;

            final totalContent = viewport + maxScroll;
            final rawThumbExtent = trackExtent * (viewport / totalContent);
            final minThumb = math.min(widget.minThumbExtent, trackExtent);
            thumbExtent = rawThumbExtent.clamp(minThumb, trackExtent);
            thumbTravel = (trackExtent - thumbExtent).clamp(0.0, trackExtent);
            final scrollFraction = (pixels / maxScroll).clamp(0.0, 1.0);
            thumbTop = thumbTravel * scrollFraction;

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (details) {
                final localY = details.localPosition.dy;
                final targetThumbTop = (localY - thumbExtent / 2).clamp(
                  0.0,
                  thumbTravel,
                );
                final targetFraction = thumbTravel == 0
                    ? 0.0
                    : (targetThumbTop / thumbTravel);
                widget.controller.jumpTo(targetFraction * maxScroll);
              },
              onVerticalDragStart: (details) {
                final localY = details.localPosition.dy;
                final thumbBottom = thumbTop + thumbExtent;
                _draggingThumb = localY >= thumbTop && localY <= thumbBottom;
                if (_draggingThumb) {
                  _dragThumbStartDy = localY;
                  _dragScrollStartOffset = pixels;
                } else {
                  final targetThumbTop = (localY - thumbExtent / 2).clamp(
                    0.0,
                    thumbTravel,
                  );
                  final targetFraction = thumbTravel == 0
                      ? 0.0
                      : (targetThumbTop / thumbTravel);
                  widget.controller.jumpTo(targetFraction * maxScroll);
                }
              },
              onVerticalDragUpdate: (details) {
                if (!_draggingThumb ||
                    _dragThumbStartDy == null ||
                    _dragScrollStartOffset == null) {
                  return;
                }
                final deltaThumb =
                    details.localPosition.dy - _dragThumbStartDy!;
                final deltaFraction = thumbTravel == 0
                    ? 0.0
                    : (deltaThumb / thumbTravel);
                final target =
                    (_dragScrollStartOffset! + deltaFraction * maxScroll).clamp(
                      0.0,
                      maxScroll,
                    );
                widget.controller.jumpTo(target);
              },
              onVerticalDragEnd: (_) {
                _draggingThumb = false;
                _dragThumbStartDy = null;
                _dragScrollStartOffset = null;
              },
              onVerticalDragCancel: () {
                _draggingThumb = false;
                _dragThumbStartDy = null;
                _dragScrollStartOffset = null;
              },
              child: CustomPaint(
                painter: VerticalScrollbarPainter(
                  thumbTop: thumbTop,
                  thumbExtent: thumbExtent,
                  thumbColor: thumbColor,
                  trackColor: trackColor,
                ),
                child: const SizedBox.expand(),
              ),
            );
          },
        );
      },
    );
  }
}
