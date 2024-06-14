import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swopin/data/claim/daily_claim_repository.dart';
import 'package:swopin/data/news/news_notification.dart';
import 'package:swopin/data/user/user_repository.dart';
import 'package:swopin/dependency/claim_module.dart';
import 'package:swopin/dependency/user_module.dart';
import 'package:swopin/utils/analytics_service.dart';
import 'package:swopin/utils/toast_helper.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

import '../../../data/telegram/telegram_app.dart';
import '../../../dependency/news_module.dart';
import '../../../theme/colors.dart';
import '../../common/widgets/gradient_with_state.dart';
import 'daily_claim_buttons.dart';

class GetCoinsButtons extends StatefulWidget {
  const GetCoinsButtons({super.key});

  @override
  State<GetCoinsButtons> createState() => _GetCoinsButtonsState();
}

class _GetCoinsButtonsState extends State<GetCoinsButtons>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final DailyClaimRepository _claimRepository = ClaimModule.claimRepository();

  final UserRepository _userRepository = UserModule.userRepository();

  final NewsRepository _newsRepository = NewsModule.newsRepository();

  bool _isLoading = true;
  bool _isAvailable = true;
  bool _isNewsAvailable = false;
  int _nextClaim = 0;

  late DateTime _nextPrizeTime;
  late Duration _timeLeft;
  Timer? _timer;

  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isNewsAvailable = _newsRepository.isNewsAvailable();
    });

    _subscription = _userRepository.user.listen((value) {
      _nextClaim = value.tomorrowCoins();
      _nextPrizeTime = value.claimTimestamp!.add(const Duration(hours: 24));
      _timeLeft = _nextPrizeTime.difference(DateTime.now());
      if (_timer == null) {
        _startTimer();
      } else {
        if (_timeLeft.isNegative) {
          _timer?.cancel();
          setState(() {
            _isAvailable = _timeLeft.isNegative;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  void _updateUser() {
    _userRepository.fetchUserByUid(
        id: Supabase.instance.client.auth.currentUser!.id,
        onError: (onError) {
          ToastHelper.showSnackBar(
              text: 'Failed to update profile', context: context);
        },
        onSuccess: (user) {});
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft = _nextPrizeTime.difference(DateTime.now());
        if (_timeLeft.isNegative) {
          _timer?.cancel();
          _timer = null;
        }
        _isAvailable = _timeLeft.isNegative;
        _isLoading = false;
      });
    });
  }

  Future<void> _getCoins({required int coins}) async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 0), () {
      final stream = _claimRepository.claim(
          Supabase.instance.client.auth.currentUser!.id, coins);
      stream.listen((value) {
        if (value.isNotEmpty) {
          ToastHelper.showSnackBar(text: value, context: context);
          stream.close();
          _updateUser();
          analytics.logDailyClaim();
          telegram.hapticFeedback();
        }
      }, onError: (e) {
        ToastHelper.showSnackBar(text: e.toString(), context: context);
        setState(() {
          _isLoading = false;
          _isAvailable = true;
        });
        stream.close();
        analytics.logDailyClaim(error: e.toString());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
            child: GradientWithState(
                isActive: _isAvailable && !_isLoading,
                activeGradient: ColorsTheme.gradientDefault,
                inactiveGradient: const LinearGradient(colors: [
                  ColorsTheme.subTitleComColor,
                  ColorsTheme.subTitleComColor
                ]),
                borderRadius: BorderRadius.circular(8),
                child: _isAvailable
                    ? _isNewsAvailable
                        ? NewsButton(
                            isLoading: _isLoading,
                            onPressed: () async {
                              telegram
                                  .openTelegramLink(_newsRepository.getLink());
                              Future.delayed(const Duration(seconds: 1), () {
                                setState(() {
                                  _isNewsAvailable = false;
                                });
                              });
                            })
                        : ClaimButton(
                            onPressed: () {
                              _getCoins(coins: 1);
                            },
                            isLoading: _isLoading,
                          )
                    : ClaimTimerButton(
                        timeLeft: _timeLeft,
                        isLoading: _isLoading,
                      ))),
        const SizedBox(width: 24),
        Expanded(
            child: NextClaimButton(
                onPressed: () {}, isLoading: false, nextClaim: _nextClaim)),
      ],
    );
  }
}
