import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:swopin/utils/analytics_service.dart';
import '../../../data/telegram/telegram_app.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../utils/numbers_converter.dart';

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
      child: Column(children: [
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
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyles.balanceOnRefValue,
            ),
          ],
        )
      ]),
    );
  }
}

class ItemStats extends StatelessWidget {
  final int referrals;
  final int refBalance;
  final int claimBalance;
  final int tasksBalance;

  const ItemStats(
      {super.key,
      required this.referrals,
      required this.refBalance,
      required this.claimBalance,
      required this.tasksBalance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorsTheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Item(
              title: '$referrals Referrals',
              value: '+ ${formatNumber(refBalance)}'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Divider(height: 1, color: ColorsTheme.primary),
          ),
          Item(title: 'Daily claims', value: '+ ${formatNumber(claimBalance)}'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Divider(height: 1, color: ColorsTheme.primary),
          ),
          Item(title: 'In app tasks', value: '+ ${formatNumber(tasksBalance)}'),
        ],
      ),
    );
  }
}

class Item extends StatelessWidget {
  final String title;
  final String value;

  const Item({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height - 32;
    return Container(
      padding:
          EdgeInsets.symmetric(vertical: screenHeight * 0.025, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyles.myStatsTitle,
          ),
          Text(
            value,
            style: TextStyles.myStatsValue,
          )
        ],
      ),
    );
  }
}

class ReferralSystemWidget extends StatelessWidget {
  const ReferralSystemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height - 32;
    return Container(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.025),
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorsTheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text('Referral system',
              style: TextStyles.myStatsRefSysTitle
                  .copyWith(fontSize: screenHeight * 0.03)),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02,
              horizontal: 16,
            ),
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyles.statisticTitle,
                children: <TextSpan>[
                  TextSpan(
                    text:
                        'When your friends first start app\n from your link, you get ',
                  ),
                  TextSpan(
                    text: '100',
                    style: TextStyles.hundred,
                  ),
                  TextSpan(
                    style: TextStyles.statisticTitle,
                    text: ' coins\n each friend',
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: ColorsTheme.gradientDefault,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () async {
                telegram.requestRefLink();
                analytics.logRefRequest();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: screenHeight * 0.02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  shadowColor: Colors.transparent),
              child: const Text(
                'Invite a friend',
                style: TextStyles.textInLightButton,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
