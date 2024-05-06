import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';

class StartTaskButton extends StatelessWidget {
  final Function() onTap;

  const StartTaskButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          onTap();
        },
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ColorsTheme.secondary,
                  width: 1,
                )),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Task', style: TextStyles.sheetSubTaskTitle),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: ColorsTheme.secondary,
                  )
                ])));
  }
}

class CheckTaskButton extends StatelessWidget {
  final Function() onTap;

  const CheckTaskButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          onTap();
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ColorsTheme.secondary,
                width: 1,
              )),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: const Text('Check', style: TextStyles.sheetSubTaskTitle),
        ));
  }
}

class DoneTaskButton extends StatelessWidget {
  const DoneTaskButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ColorsTheme.value,
              width: 1,
            )),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Done', style: TextStyles.doneTaskButton),
              SizedBox(width: 8),
              Icon(
                Icons.check,
                color: ColorsTheme.value,
              )
            ]));
  }
}
