import 'package:flutter/material.dart';
import 'package:peng_houth_cycle/app/view/main_shell.dart';
import 'package:peng_houth_cycle/core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peng Houth Cycle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainShell(),
    );
  }
}
