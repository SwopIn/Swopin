import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swopin/data/user/user_repository.dart';
import 'package:swopin/dependency/user_module.dart';
import 'package:swopin/utils/analytics_service.dart';

import '../../../utils/numbers_converter.dart';
import '../../common/widgets/top_bar.dart';
import '../widgets/referrals_widgets.dart';

class ReferralsScreen extends StatefulWidget {
  const ReferralsScreen({super.key});

  @override
  State<ReferralsScreen> createState() => _ReferralsScreenState();
}

class _ReferralsScreenState extends State<ReferralsScreen> {
  final UserRepository _repository = UserModule.userRepository();

  int _balance = 0;
  int _referrals = 0;
  int _refBalance = 0;
  int _claimBalance = 0;
  int _tasksBalance = 0;

  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    analytics.logRefScreenOpen();
    _subscription = _repository.user.listen((value) {
      setState(() {
        _balance = value.balance;
        _referrals = value.refCount;
        _refBalance = value.refBalance;
        _claimBalance = value.calculateReward();
        _tasksBalance = value.taskBalance;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height - 32;
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16,
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const CustomTopBar(title: 'Your stats'),
              SizedBox(height: screenHeight * 0.03),
              ItemBalance(title: 'Balance', value: formatNumber(_balance)),
              SizedBox(height: screenHeight * 0.025),
              ItemStats(
                referrals: _referrals,
                refBalance: _refBalance,
                claimBalance: _claimBalance,
                tasksBalance: _tasksBalance,
              ),
              SizedBox(height: screenHeight * 0.025),
              const ReferralSystemWidget()
            ]),
      ),
    ));
  }
}
