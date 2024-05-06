import 'package:flutter/material.dart';

import 'colors.dart';

class ButtonsTheme {
  static ButtonStyle claimButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    disabledBackgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
  static ButtonStyle nextButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: ColorsTheme.background,
    disabledBackgroundColor: ColorsTheme.background,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static ButtonStyle claimTaskButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    disabledBackgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

}
