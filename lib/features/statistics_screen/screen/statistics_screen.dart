import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:swopin/data/telegram/telegram_app.dart';
import 'package:swopin/utils/analytics_service.dart';
import 'package:swopin/utils/numbers_converter.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

import '../../../data/remote/remote_config.dart';
import '../../../theme/button_style.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../common/widgets/gradient_with_state.dart';
import '../../common/widgets/top_bar.dart';
import '../widgets/statistics_widgets.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final RemoteConfigService _remoteConfigService = RemoteConfigService();

  Statistics get _statistics => Statistics(
        totalBalance: formatNumber(_remoteConfigService.totalBalance),
        totalPlayers: formatNumber(_remoteConfigService.totalPlayers),
        dailyUsers: formatNumber(_remoteConfigService.dailyUsers),
        onlineUsers: formatNumber(_remoteConfigService.onlineUsers),
      );

  @override
  void initState() {
    super.initState();
    analytics.logStatScreenOpen();
  }

  Widget _claimButton() {
    return GradientWithState(
      isActive: true,
      activeGradient: ColorsTheme.gradientDefault,
      inactiveGradient: const LinearGradient(
          colors: [ColorsTheme.subTitleComColor, ColorsTheme.subTitleComColor]),
      borderRadius: BorderRadius.circular(8),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/referrals_chart');
        },
        style: ButtonsTheme.claimTaskButtonStyle,
        child: const Text('Top referrals', style: TextStyles.claimButton),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const CustomTopBar(title: 'Global statistics'),
            const SizedBox(height: 24),
            Column(
              children: [
                ItemBalance(
                    title: 'Total balance', value: _statistics.totalBalance),
                const SizedBox(height: 20),
                ItemStatistics(
                    title: 'Total players', value: _statistics.totalPlayers),
                const SizedBox(height: 20),
                ItemStatistics(
                    title: 'Daily users', value: _statistics.dailyUsers),
                const SizedBox(height: 20),
                ItemStatistics(
                    title: 'Online users', value: _statistics.onlineUsers),
                const SizedBox(height: 20),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Expanded(
                          child: StatisticButton(
                        title: 'Community',
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/community',
                          );
                        },
                      )),
                      const SizedBox(width: 20),
                      Expanded(
                          child: StatisticButton(
                        title: 'Top referrals',
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/referrals_chart',
                          );
                        },
                      )),
                    ])
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
