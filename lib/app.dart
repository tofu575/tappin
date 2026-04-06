import 'package:flutter/material.dart';

import 'package:tappin/presentation/pages/home_page.dart';
import 'package:tappin/presentation/pages/onboarding_page.dart';

class App extends StatelessWidget {
  const App({super.key, required this.showOnboarding});

  final bool showOnboarding;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TapPin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: showOnboarding ? const OnboardingPage() : const HomePage(),
    );
  }
}
