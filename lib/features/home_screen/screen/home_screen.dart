import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swopin/data/user/user_repository.dart';
import 'package:swopin/dependency/user_module.dart';
import 'package:swopin/features/referals_screen/screen/referrals_screen.dart';
import 'package:swopin/features/statistics_screen/screen/statistics_screen.dart';
import '../../../theme/text_styles.dart';
import '../widgets/get_coins_buttons.dart';
import '../widgets/home_screen_widgets.dart';
import '../widgets/tasks_pages_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 1;
  List<Widget> _pages = <Widget>[];
  late PageController _pageController;

  final ReferralsScreen _page1 = const ReferralsScreen();
  final MainScreen _page2 = const MainScreen();
  final StatisticsScreen _page3 = const StatisticsScreen();


  @override
  void initState() {
    _pages = <Widget>[_page1, _page2, _page3];
    _pageController = PageController(initialPage: _currentPage);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomButtons(
        onTap: (page) {
          setState(() {
            _currentPage = page;
            _pageController.jumpToPage(page);
          });
        },
        currentIndex: _currentPage,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final UserRepository _repository = UserModule.userRepository();
  int _balance = 0;
  int _claimBalance = 0;

  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _repository.user.listen((value) {
      setState(() {
        _balance = value.balance;
        _claimBalance = value.claimBalance;
      });
    });
  }

  @override
  void dispose() {
    _repository.user.close();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TopBar(balance: _balance, claims: _claimBalance),
            const SizedBox(height: 16),
            const GetCoinsButtons(),
            const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 16),
              child: Align(
                alignment: Alignment.center,
                child: Text('Daily Task', style: TextStyles.statisticValue),
              ),
            ),
            const Pages(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
