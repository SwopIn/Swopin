import 'package:flutter/material.dart';
import 'package:swopin/theme/colors.dart';

import '../features/tech_error_screen/tech_error_screen.dart';

class ErrorApp extends StatelessWidget {
  final String? error;

  const ErrorApp({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swopin App',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: ColorsTheme.primary,
      ),
      home: TechErrorScreen(error: error),
    );
  }
}
