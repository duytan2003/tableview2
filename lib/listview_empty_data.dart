import 'package:flutter/material.dart';

class ListviewEmptyData extends StatelessWidget {
  const ListviewEmptyData({
    super.key,
    this.icon,
    required this.size,
    required this.message,
    this.alignment = Alignment.center,
  });

  final Size size;
  final Widget? icon;
  final String message;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      alignment: alignment,
      child: FittedBox(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon ?? Icon(Icons.data_usage, size: 50),
            Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
