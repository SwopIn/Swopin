import 'package:flutter/material.dart';
import 'package:swopin/utils/analytics_service.dart';
import 'package:swopin/utils/numbers_converter.dart';

import '../../../data/remote/remote_config.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
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
                Container(
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
                        Navigator.of(context).pushNamed(
                          '/community',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.only(
                            bottom: 4, top: 4, left: 48, right: 48),
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
                                shaderCallback: (bounds) => ColorsTheme
                                    .gradientBottomToTop
                                    .createShader(bounds),
                                child: const Text(
                                  'Community',
                                  style: TextStyles.myStatsRefSysTitle,
                                  maxLines: 1,
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
