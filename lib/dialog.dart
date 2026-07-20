import 'package:flutter/material.dart';

class IDialog {
  static void showErrorMessage({
    required BuildContext context,
    String title = 'Lỗi',
    required String message,
    String labelButton = 'Đóng',
    bool dismissible = false,
    VoidCallback? onAction,
  }) {
    showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFCC0534),
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Color(0xFF324F6A),
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width / 2.5,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10.0),
                  Text(
                    message,
                    textAlign: TextAlign.start,
                    maxLines: 15,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: Color(0xFF324F6A),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                labelButton,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: Color(0xFF324F6A),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              onPressed: () {
                if (onAction != null) onAction();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  /// COMMON DIALOG
  static Future<T?> showCommonAnimationDialog<T>({
    required BuildContext context,
    required Widget content,
    bool barrierDismissible = false,
    Color? backgroundColor,
    ShapeBorder? shape,
    Clip? clipBehavior,
    EdgeInsets? insetPadding,
    Duration transitionDuration = const Duration(milliseconds: 300),
    Curve transitionCurve = Curves.easeInOut,
    Offset beginOffset = const Offset(0, 1), // Slide from bottom
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Builder(
            builder: (context) => Dialog(
              backgroundColor: backgroundColor,
              shape: shape,
              clipBehavior: clipBehavior ?? Clip.none,
              insetPadding:
                  insetPadding ??
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
              child: content,
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: transitionCurve,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );
      },
    );
  }
}
