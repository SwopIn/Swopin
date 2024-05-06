import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swopin/utils/numbers_converter.dart';
import '../../../data/telegram/telegram_app.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';

class BottomButtons extends StatelessWidget {
  final Function(int) onTap;
  final int currentIndex;

  const BottomButtons(
      {super.key, required this.onTap, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
        child: BottomAppBar(
            notchMargin: 0,
            color: Colors.transparent,
            elevation: 0,
            padding: EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                    flex: 2,
                    child: NavigationButton(
                        icon: 'assets/svg/icon_referrals.svg',
                        isSelected: currentIndex == 0,
                        position: 0,
                        label: 'Referrals',
                        onTap: onTap)),
                const SizedBox(width: 8),
                Expanded(
                    flex: 3,
                    child: NavigationButton(
                        icon: 'assets/svg/icon_home.svg',
                        isSelected: currentIndex == 1,
                        position: 1,
                        label: 'Home',
                        onTap: onTap)),
                const SizedBox(width: 8),
                Expanded(
                    flex: 2,
                    child: NavigationButton(
                        icon: 'assets/svg/icon_stats.svg',
                        isSelected: currentIndex == 2,
                        position: 2,
                        label: 'Statistics',
                        onTap: onTap)),
              ],
            )));
  }
}

class NavigationButton extends StatelessWidget {
  final String icon;
  final String label;
  final int position;
  final bool isSelected;
  final Function(int) onTap;

  const NavigationButton(
      {super.key,
      required this.icon,
      required this.label,
      required this.onTap,
      required this.isSelected,
      required this.position});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: isSelected
            ? ColorsTheme.gradientDefault
            : const LinearGradient(
                colors: [Colors.transparent, Colors.transparent]),
        border: Border.all(
          color: isSelected ? ColorsTheme.accent : Colors.transparent,
          width: 2,
        ),
      ),
      child: ElevatedButton(
        onPressed: () {
          onTap(position);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsTheme.background,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 4,
            ),
            ShaderMask(
              shaderCallback: (bounds) => isSelected
                  ? ColorsTheme.gradientBottomToTop.createShader(bounds)
                  : const LinearGradient(
                      colors: [Color(0xFF909599), Color(0xFF909599)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ).createShader(bounds),
              child: SvgPicture.asset(
                icon,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            ShaderMask(
              shaderCallback: (bounds) => isSelected
                  ? ColorsTheme.gradientBottomToTop.createShader(bounds)
                  : const LinearGradient(
                      colors: [Color(0xFF909599), Color(0xFF909599)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ).createShader(bounds),
              child: Text(
                label,
                style: isSelected
                    ? TextStyles.activeTitleItem
                    : TextStyles.inactiveTitleItem,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  final int balance;
  final int claims;

  const TopBar({super.key, required this.balance, required this.claims});

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text(telegram.firstName ?? 'user',
              style: TextStyles.myStatsRefSysTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text('$claims claims',
                style: TextStyles.statisticTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(width: 8),
            SvgPicture.asset(
              'assets/svg/claim_fire.svg',
              width: 20,
              height: 20,
            ),
          ])
        ])
      ]),
      Expanded(child: Container()),
      SvgPicture.asset(
        'assets/svg/coin.svg',
        width: 36,
        height: 36,
      ),
      const SizedBox(width: 8),
      Text(
        formatNumberToK(balance),
        style: TextStyles.countCoinOnMain,
        textAlign: TextAlign.end,
      ),
    ]);
  }
}

class Task {
  final String name;
  final String description;

  Task({required this.name, required this.description});

  @override
  String toString() {
    return 'Task{name: $name, description: $description}';
  }
}
