import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swopin/data/referals/referals_repository.dart';
import 'package:swopin/data/user/user_repository.dart';
import 'package:swopin/dependency/referrals_module.dart';
import 'package:swopin/utils/toast_helper.dart';

import '../../../data/telegram/telegram_app.dart';
import '../../../dependency/user_module.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';
import '../../../utils/analytics_service.dart';
import '../../../utils/numbers_converter.dart';
import '../../common/widgets/top_bar.dart';

class ReferralsChartScreen extends StatefulWidget {
  const ReferralsChartScreen({super.key});

  @override
  State<ReferralsChartScreen> createState() => _ReferralsChartScreenState();
}

class _ReferralsChartScreenState extends State<ReferralsChartScreen> {
  final ReferralsRepository _repository = ReferralsModule.referralsRepository();

  StreamSubscription? _subscription;

  List<Referral> _topPlayers = [];

  bool _isLoading = true;

  int myRefCount = 0;

  @override
  void initState() {
    super.initState();
    analytics.logChartScreenOpen();
    _subscription = _repository.fetchTopPlayers(count: 10).listen((value) {
      setState(() {
        _topPlayers = value;
        _isLoading = false;
      });
    }, onError: (e) {
      ToastHelper.showSnackBar(text: 'Something went wrong', context: context);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
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
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const CustomTopBarWithBack(title: 'Top referrals'),
              const SizedBox(height: 24),
              _isLoading
                  ? const Expanded(
                      child: Center(
                      child: CircularProgressIndicator(
                        color: ColorsTheme.secondary,
                      ),
                    ))
                  : Expanded(
                      child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: ColorsTheme.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: _topPlayers.length,
                        shrinkWrap: true,
                        separatorBuilder: (context, index) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 0),
                            child:
                                Divider(height: 1, color: ColorsTheme.primary),
                          );
                        },
                        itemBuilder: (context, index) {
                          return ReferralRow(
                            referral: _topPlayers[index],
                            position: index + 1,
                          );
                        },
                      ),
                    )),
              const SizedBox(height: 16),
            ]),
      ),
    );
  }
}

class ReferralRow extends StatelessWidget {
  final Referral referral;
  final int position;

  bool get isMe => referral.id == telegram.userId!;

  const ReferralRow(
      {super.key, required this.referral, required this.position});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        color:
            isMe ? ColorsTheme.value.withOpacity(0.5) : ColorsTheme.background,
        height: 56,
        child: ListTile(
          onTap: null,
          enabled: true,
          leading: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: position == 1
                      ? ColorsTheme.goldColor
                      : position == 2
                          ? ColorsTheme.silverColor
                          : position == 3
                              ? ColorsTheme.bronzeColor
                              : ColorsTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                height: 42,
                width: 42,
                child: Text(
                  position < 11 ? '$position' : '...',
                  style: position < 4
                      ? TextStyles.topUserPosAccent
                      : TextStyles.topUserPos,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
          trailing: Text(
            '${formatNumber(referral.refCount)} refs',
            style: TextStyles.topUserRefs,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          title: Text(
            isMe ? 'You' : referral.name,
            style: TextStyles.topUserId,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ));
  }
}
