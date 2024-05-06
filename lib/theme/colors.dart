import 'dart:ui';

import 'package:flutter/material.dart';

class ColorsTheme {
  static const Color primary = Color(0xFF042236);
  static const Color secondary = Color(0xFFE9F1F7);
  static const Color accent = Color(0xB5FFEBD2);
  static const Color background = Color(0xFF06324F);
  static const Color value = Color(0xFF1EFFBC);

  static const Color balanceStatsColor = Color(0xB6E9F1F7);
  static const Color subTitleComColor = Color(0xB5E9F1F7);
  static const Color startGradientColor = Color(0xFFF7D357);
  static const Color endGradientColor = Color(0xFFE09528);

  static const Color startGradientForDialogColor = Color(0xFF063656);
  static const Color endGradientForDialogColor = Color(0xFF02111B);

  static const LinearGradient gradientDefault = LinearGradient(
    colors: [startGradientColor, endGradientColor]);

  static const LinearGradient gradientBottomToTop = LinearGradient(
    colors: [startGradientColor, endGradientColor],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static const LinearGradient gradientForDialog = LinearGradient(
    colors: [startGradientForDialogColor, endGradientForDialogColor],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.52],
  );

  static const LinearGradient gradientForComButton = LinearGradient(
    colors: [startGradientForDialogColor, endGradientForDialogColor],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

}