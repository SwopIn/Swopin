import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../theme/button_style.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_styles.dart';

class ClaimButton extends StatelessWidget {
  const ClaimButton(
      {super.key, required this.onPressed, required this.isLoading});

  final Function() onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ButtonsTheme.claimButtonStyle,
          child: isLoading
              ? const CircularProgressIndicator(color: ColorsTheme.background)
              : const Text('Claim', style: TextStyles.textInLightButton)),
    );
  }
}

class ClaimTimerButton extends StatelessWidget {
  const ClaimTimerButton(
      {super.key, required this.timeLeft, required this.isLoading});

  final Duration timeLeft;
  final bool isLoading;

  String _convertTime() {
    return '${timeLeft.inHours.toString().padLeft(2, '0')}:${timeLeft.inMinutes.remainder(60).toString().padLeft(2, '0')}:${timeLeft.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ElevatedButton(
          onPressed: null,
          style: ButtonsTheme.claimButtonStyle,
          child: isLoading
              ? const CircularProgressIndicator(color: ColorsTheme.background)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Spacer(
                      flex: 1,
                    ),
                    const Text(
                      'Claim',
                      textAlign: TextAlign.center,
                      style: TextStyles.claimTimerTitle,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time_rounded,
                            color: ColorsTheme.primary),
                        const SizedBox(width: 8),
                        Text(_convertTime(), style: TextStyles.claimTimerValue)
                      ],
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                  ],
                )),
    );
  }
}

class NewsButton extends StatelessWidget {
  const NewsButton(
      {super.key, required this.onPressed, required this.isLoading});

  final Function() onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ButtonsTheme.claimButtonStyle,
          child: isLoading
              ? const CircularProgressIndicator(color: ColorsTheme.background)
              : const Text('News', style: TextStyles.textInLightButton)),
    );
  }
}

class NextClaimButton extends StatelessWidget {
  const NextClaimButton(
      {super.key,
      required this.onPressed,
      required this.isLoading,
      required this.nextClaim});

  final Function() onPressed;
  final bool isLoading;
  final int nextClaim;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ElevatedButton(
          onPressed: null,
          style: ButtonsTheme.nextButtonStyle,
          child: isLoading
              ? const CircularProgressIndicator(color: ColorsTheme.secondary)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Spacer(
                      flex: 1,
                    ),
                    const Text('Next claim',
                        style: TextStyles.myStatsRefSysTitle),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SvgPicture.asset(
                            'assets/svg/coin.svg',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(nextClaim.toString(),
                              style: TextStyles.tomorrowClaim),
                        ]),
                    const Spacer(
                      flex: 1,
                    )
                  ],
                )),
    );
  }
}
