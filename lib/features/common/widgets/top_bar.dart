import 'package:flutter/material.dart';
import '../../../theme/text_styles.dart';
import 'back_button.dart';

class CustomTopBar extends StatelessWidget {
  final String title;

  const CustomTopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 32),
        Text(title, style: TextStyles.topBarTitle),
        const SizedBox(width: 32),
      ],
    );
  }
}

class CustomTopBarWithBack extends StatelessWidget {

  final String title;

  const CustomTopBarWithBack({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const CustomBackButton(),
        Text(title, style: TextStyles.topBarTitle),
        const SizedBox(width: 64),
      ],
    );
  }
}