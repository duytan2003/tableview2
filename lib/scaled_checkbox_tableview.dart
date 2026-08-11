import 'package:flutter/material.dart';

class ScaledCheckboxTableView extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;
  final Color? activeColor;
  final Color? checkColor;
  final Color? focusColor;
  final Color? hoverColor;
  final WidgetStateProperty<Color?>? fillColor;
  final WidgetStateProperty<Color?>? overlayColor;
  final double? splashRadius;
  final FocusNode? focusNode;
  final bool autofocus;
  final OutlinedBorder? shape;
  final BorderSide? side;
  final MouseCursor? mouseCursor;
  final VisualDensity? visualDensity;
  final MaterialTapTargetSize? materialTapTargetSize;
  final Color? disabledColor;
  final double scale;
  final bool enabled;
  final Color disabledBorderColor;

  const ScaledCheckboxTableView({
    super.key,
    required this.value,
    this.onChanged,
    this.tristate = false,
    this.activeColor,
    this.checkColor,
    this.focusColor,
    this.hoverColor,
    this.fillColor,
    this.overlayColor,
    this.splashRadius = 16.0,
    this.focusNode,
    this.autofocus = false,
    this.shape,
    this.side,
    this.mouseCursor,
    this.visualDensity = VisualDensity.compact,
    this.materialTapTargetSize = MaterialTapTargetSize.shrinkWrap,
    this.disabledColor,
    this.scale = 1.0,
    this.enabled = true,
    this.disabledBorderColor = const Color(0xFFCECECE),
  });

  bool get _isChecked => value == true;
  bool get _isIndeterminate => tristate && value == null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color effectiveActiveColor =
        activeColor ?? theme.colorScheme.primary.withValues(alpha: 0.9);
    final BorderSide effectiveSide = !enabled
        ? BorderSide(color: disabledBorderColor, width: side?.width ?? 1.0)
        : (side ?? const BorderSide(color: Color(0xFFC0C2CA), width: 1.0));

    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: 20,
        height: 20,
        child: CheckboxTheme(
          data: theme.checkboxTheme.copyWith(
            shape:
                shape ??
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: WidgetStateBorderSide.resolveWith((states) {
              if (!enabled || states.contains(WidgetState.disabled)) {
                return BorderSide(
                  color: disabledBorderColor,
                  width: effectiveSide.width,
                );
              }
              if (states.contains(WidgetState.selected)) {
                return BorderSide(
                  color: effectiveActiveColor,
                  width: effectiveSide.width,
                );
              }
              return effectiveSide;
            }),
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (!enabled || states.contains(WidgetState.disabled)) {
                return disabledColor ?? const Color(0xFFF5F5F5);
              }
              if (states.contains(WidgetState.selected)) {
                return fillColor?.resolve(states) ?? effectiveActiveColor;
              }
              return fillColor?.resolve(states) ?? Colors.transparent;
            }),
            checkColor: WidgetStatePropertyAll(checkColor ?? Colors.white),
            overlayColor: overlayColor,
            splashRadius: splashRadius,
            materialTapTargetSize:
                materialTapTargetSize ?? MaterialTapTargetSize.shrinkWrap,
            visualDensity: visualDensity ?? VisualDensity.compact,
          ),
          child: Semantics(
            checked: _isChecked,
            mixed: _isIndeterminate,
            enabled: enabled,
            child: Checkbox(
              value: value,
              onChanged: enabled ? onChanged : null,
              tristate: tristate,
              activeColor: effectiveActiveColor,
              checkColor: checkColor ?? Colors.white,
              focusColor: focusColor,
              hoverColor: hoverColor,
              focusNode: focusNode,
              autofocus: autofocus,
              mouseCursor: mouseCursor,
            ),
          ),
        ),
      ),
    );
  }
}
