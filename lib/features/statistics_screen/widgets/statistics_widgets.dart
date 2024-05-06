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