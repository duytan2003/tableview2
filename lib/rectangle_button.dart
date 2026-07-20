import 'package:flutter/material.dart';

class IRectangleButton extends StatelessWidget {
  const IRectangleButton({
    super.key,
    required this.leading,
    required this.title,
    this.height = 40.0,
    this.width,
    this.radius = 6.0,
    this.fontSize = 12.0,
    this.borderSize = 0.75,
    this.backgroundColor = Colors.transparent,
    this.outlineColor = const Color(0xFFC0C2CA),
    this.textColor = const Color(0xFF324F6A),
    this.fontWeight = FontWeight.normal,
    this.fontStyle = FontStyle.normal,
    this.showDivider = true,
    this.padding = const EdgeInsets.all(0.0),
    required this.onPressed,
    this.enable = true,
    this.hasPermission = true,
    this.disabledTextColor = const Color(0xFF9e9e9e),
  });

  final Widget leading;
  final String title;
  final double height;
  final double? width;
  final double radius;
  final double fontSize;
  final double borderSize;
  final Color backgroundColor;
  final Color outlineColor;
  final Color textColor;
  final Color disabledTextColor;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final bool showDivider;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onPressed;
  final bool enable;
  final bool hasPermission;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        height: height,
        width: width,
        child: hasPermission
            ? OutlinedButton(
                onPressed: enable ? () => onPressed?.call() : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 4.0,
                  ),
                  side: BorderSide(color: outlineColor, width: borderSize),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 16.0, height: 16.0, child: leading),
                    const VerticalDivider(
                      color: Color(0xFFC0C2CA),
                      width: 16,
                      thickness: 1,
                      indent: 12.0,
                      endIndent: 12.0,
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        fontStyle: fontStyle,
                        color: enable
                            ? textColor
                            : disabledTextColor.withValues(alpha: .7),
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}
