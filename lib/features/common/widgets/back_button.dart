import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../theme/colors.dart';

class CustomBackButton extends StatelessWidget {
  final Function()? onTap;
  final Color color;
  final Color backgroundColor;
  final bool isActive;
  final double arrowAngle;
  final Color arrowColor;

  const CustomBackButton(
      {super.key,
      this.onTap,
      this.color = ColorsTheme.primary,
      this.backgroundColor = ColorsTheme.background,
      this.isActive = true,
      this.arrowAngle = 0.0,
      this.arrowColor = ColorsTheme.secondary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isActive) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        height: 64,
        width: 64,
        padding: const EdgeInsets.all(16),
        child: Container(
          height: 24,
          width: 24,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
          color: color,
            borderRadius: BorderRadius.circular(4),

          ),
          child: Transform.rotate(
              angle: arrowAngle * pi / 180,
              child: SvgPicture.asset(
                'assets/svg/arrow_back.svg',
                color: arrowColor,
              )),
        ),
      ),
    );
  }
}
