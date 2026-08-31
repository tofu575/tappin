import 'package:flutter/material.dart';

import 'package:tappin/presentation/pages/home_page.dart';
import 'package:tappin/presentation/pages/onboarding_page.dart';
import 'package:tappin/presentation/theme/tap_pin_theme.dart';

class App extends StatelessWidget {
  const App({super.key, required this.showOnboarding});

  final bool showOnboarding;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TapPin',
      theme: buildTapPinTheme(),
      home: showOnboarding ? const OnboardingPage() : const HomePage(),
    );
  }
}
