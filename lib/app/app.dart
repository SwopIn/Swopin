import 'package:flutter/material.dart';
import 'package:swopin/theme/colors.dart';
import '../routes/router.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swopin App',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: ColorsTheme.primary,
      ),
      routes: routes,
    );
  }
}
