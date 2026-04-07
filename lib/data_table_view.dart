import 'package:flutter/material.dart';

class DataColumnTableView extends DataColumn {
  const DataColumnTableView({
    required super.label,
    super.tooltip,
    super.numeric = false,
    super.onSort,
    super.headingRowAlignment,
    this.fixedWidth,
  });
  final double? fixedWidth;
}

class DataRowTableView {
  const DataRowTableView({
    this.index,
    this.selected = false,
    this.onSelectChanged,
    this.onLongPress,
    this.onHover,
    this.color,
    this.mouseCursor,
    this.specificRowHeight,
    this.onTap,
    this.onSecondaryTap,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onDoubleTap,
    this.isChecked = false,
    required this.cells,
    this.enableCheckbox = true,
  });
  final int? index;
  final bool selected;
  final void Function(bool?)? onSelectChanged;
  final void Function()? onLongPress;
  final void Function(bool)? onHover;
  final WidgetStateProperty<Color?>? color;
  final WidgetStateProperty<MouseCursor?>? mouseCursor;
  final double? specificRowHeight;
  final List<Widget> cells;
  final bool enableCheckbox;

  /// Row tap handler, won't be called if tapped cell has any tap event handlers
  final GestureTapCallback? onTap;

  /// Row right click handler, won't be called if tapped cell has any tap event handlers
  final GestureTapCallback? onSecondaryTap;

  /// Row right mouse down handler, won't be called if tapped cell has any tap event handlers
  final GestureTapDownCallback? onSecondaryTapDown;

  /// Row right mouse up handler, won't be called if tapped cell has any tap event handlers
  final GestureTapUpCallback? onSecondaryTapUp;

  /// Row double tap handler, won't be called if tapped cell has any tap event handlers
  final GestureTapCallback? onDoubleTap;

  final bool isChecked;
}
