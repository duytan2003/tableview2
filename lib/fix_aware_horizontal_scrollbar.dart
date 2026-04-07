import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'horizontal_scoll_bar_painter.dart';

class FixedAwareHorizontalScrollbar extends StatefulWidget {
  const FixedAwareHorizontalScrollbar({
    super.key,
    required this.controller,
    required this.metricsListenable,
  });

  final ScrollController controller;
  final ValueListenable<ScrollMetrics?> metricsListenable;

  @override
  State<FixedAwareHorizontalScrollbar> createState() =>
      FixedAwareHorizontalScrollbarState();
}

class FixedAwareHorizontalScrollbarState
    extends State<FixedAwareHorizontalScrollbar> {
  static const double _minThumbExtent = 48;
  double? _dragThumbStartDx;
  double? _dragScrollStartOffset;
  bool _draggingThumb = false;

  @override
  Widget build(BuildContext context) {
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
            final trackExtent = constraints.maxWidth;
            final pixels = metrics.pixels;
            final double thumbExtent;
            final double thumbTravel;
            final double thumbLeft;

            final totalContent = viewport + maxScroll;
            final rawThumbExtent = trackExtent * (viewport / totalContent);
            // clamp(lower, upper) requires lower <= upper; track can be narrower than _minThumbExtent.
            final minThumb = math.min(_minThumbExtent, trackExtent);
            thumbExtent = rawThumbExtent.clamp(minThumb, trackExtent);
            thumbTravel = (trackExtent - thumbExtent).clamp(0.0, trackExtent);
            final scrollFraction = (pixels / maxScroll).clamp(0.0, 1.0);
            thumbLeft = thumbTravel * scrollFraction;

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (details) {
                final localX = details.localPosition.dx;
                final targetThumbLeft = (localX - thumbExtent / 2).clamp(
                  0.0,
                  thumbTravel,
                );
                final targetFraction = thumbTravel == 0
                    ? 0.0
                    : (targetThumbLeft / thumbTravel);
                widget.controller.jumpTo(targetFraction * maxScroll);
              },
              onHorizontalDragStart: (details) {
                final localX = details.localPosition.dx;
                final thumbRight = thumbLeft + thumbExtent;
                _draggingThumb = localX >= thumbLeft && localX <= thumbRight;
                if (_draggingThumb) {
                  _dragThumbStartDx = localX;
                  _dragScrollStartOffset = pixels;
                } else {
                  final targetThumbLeft = (localX - thumbExtent / 2).clamp(
                    0.0,
                    thumbTravel,
                  );
                  final targetFraction = thumbTravel == 0
                      ? 0.0
                      : (targetThumbLeft / thumbTravel);
                  widget.controller.jumpTo(targetFraction * maxScroll);
                }
              },
              onHorizontalDragUpdate: (details) {
                if (!_draggingThumb ||
                    _dragThumbStartDx == null ||
                    _dragScrollStartOffset == null) {
                  return;
                }
                final deltaThumb =
                    details.localPosition.dx - _dragThumbStartDx!;
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
              onHorizontalDragEnd: (_) {
                _draggingThumb = false;
                _dragThumbStartDx = null;
                _dragScrollStartOffset = null;
              },
              onHorizontalDragCancel: () {
                _draggingThumb = false;
                _dragThumbStartDx = null;
                _dragScrollStartOffset = null;
              },
              child: CustomPaint(
                painter: HorizontalScrollbarPainter(
                  thumbLeft: thumbLeft,
                  thumbExtent: thumbExtent,
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
