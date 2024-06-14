import 'package:swopin/features/community_screen/screen/community_screen.dart';
import 'package:swopin/features/referals_screen/screen/referrals_screen.dart';
import 'package:swopin/features/statistics_screen/screen/statistics_screen.dart';

import '../features/home_screen/screen/home_screen.dart';
import '../features/referals_chart_screen/screen/referals_chart_screen.dart';

final routes = {
  '/': (context) => const HomeScreen(),
  '/referrals': (context) => const ReferralsScreen(),
  '/statistics': (context) => const StatisticsScreen(),
  '/community': (context) => const CommunityScreen(),
  '/referrals_chart': (context) => const ReferralsChartScreen(),
};