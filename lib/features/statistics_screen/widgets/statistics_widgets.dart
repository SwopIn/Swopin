import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';

class ItemBalance extends StatelessWidget {
  final String title;
  final String value;

  const ItemBalance({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorsTheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyles.balanceTitle,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/coin.svg',
                width: 28,
                height: 28,
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyles.balanceValue,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ItemStatistics extends StatelessWidget {
  final String title;
  final String value;

  const ItemStatistics({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorsTheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyles.statisticTitle,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyles.statisticValue,
          )
        ],
      ),
    );
  }
}

class Statistics {
  final String totalBalance;
  final String totalPlayers;
  final String dailyUsers;
  final String onlineUsers;

  Statistics(
      {required this.totalBalance,
      required this.totalPlayers,
      required this.dailyUsers,
      required this.onlineUsers});
}

class StatisticButton extends StatelessWidget {
  final String title;
  final Function() onTap;

  const StatisticButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: ColorsTheme.gradientDefault,
        border: Border.all(
          color: Colors.transparent,
          width: 2,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: ColorsTheme.gradientForComButton,
        ),
        child: ElevatedButton(
          onPressed: () {
            onTap();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            padding:
                const EdgeInsets.only(bottom: 4, top: 4, left: 14, right: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        ColorsTheme.gradientBottomToTop.createShader(bounds),
                    child: Text(
                      title,
                      style: TextStyles.myStatsRefSysTitle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
