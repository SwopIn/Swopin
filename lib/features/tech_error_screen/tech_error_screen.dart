import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:swopin/utils/analytics_service.dart';

class TechErrorScreen extends StatelessWidget {
  final String? error;

  const TechErrorScreen({super.key, this.error});

  void logErrorScreenOpen({required String error}) {
    analytics.logErrorScreenOpen(error: error);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logErrorScreenOpen(error: error ?? 'empty error message');
    });
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: SvgPicture.asset(
              'assets/svg/group_144.svg',
              fit: BoxFit.fill,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SvgPicture.asset(
              'assets/svg/group_146.svg',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          const TopToBottomGradientText(
            text: 'Ooops',
            fontSize: 48.0,
            colors: [Color(0xFFFEFEFE), Color(0xFFFFB9B9)],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              error ??
                  'Something went wrong. You can only log in from your Telegram account',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, color: Color(0xFFFFB9B9)),
            ),
          ),
          Expanded(
            child: SvgPicture.asset(
              'assets/svg/group_145.svg',
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }
}

class TopToBottomGradientText extends StatelessWidget {
  final String text;
  final double fontSize;
  final List<Color> colors;

  const TopToBottomGradientText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        textAlign: TextAlign.center,
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.white,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
