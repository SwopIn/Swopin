import 'package:flutter/cupertino.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
class ToastHelper {
  static void showSnackBar({required String text, required BuildContext context}) {
    showToast(text,
        context: context,
        animation: StyledToastAnimation.slideFromTopFade,
        reverseAnimation: StyledToastAnimation.slideToTopFade,
        position:
        const StyledToastPosition(align: Alignment.topCenter, offset: 20.0),
        startOffset: const Offset(0.0, -3.0),
        reverseEndOffset: const Offset(0.0, -3.0),
        duration: const Duration(seconds: 4),
        animDuration: const Duration(seconds: 1),
        curve: Curves.fastLinearToSlowEaseIn,
        reverseCurve: Curves.fastOutSlowIn);
  }
}
