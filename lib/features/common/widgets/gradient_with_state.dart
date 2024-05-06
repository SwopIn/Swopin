import 'package:flutter/cupertino.dart';

class GradientWithState extends StatelessWidget {
  const GradientWithState(
      {super.key,
      required this.isActive,
      required this.activeGradient,
      this.inactiveGradient,
      required this.borderRadius,
      required this.child});

  final bool isActive;
  final Gradient activeGradient;
  final Gradient? inactiveGradient;
  final BorderRadiusGeometry borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            isActive ? activeGradient : inactiveGradient ?? activeGradient,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}
