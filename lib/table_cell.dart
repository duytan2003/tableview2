import 'package:flutter/material.dart';

class TableCellWrapper extends StatelessWidget {
  const TableCellWrapper({
    super.key,
    required this.child,
    required this.isCenter,
  });
  final Widget child;
  final bool isCenter;
  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.black,
        overflow: TextOverflow.ellipsis,
        fontFamily: 'Montserrat',
      ),
      child: isCenter ? Center(child: child) : child,
    );
  }
}
