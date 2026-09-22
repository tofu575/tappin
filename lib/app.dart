import 'package:flutter/material.dart';

import 'package:tappin/presentation/pages/home_page.dart';
import 'package:tappin/presentation/pages/onboarding_page.dart';
import 'package:tappin/presentation/theme/tap_pin_theme.dart';
import 'package:tappin/l10n/app_localizations.dart';

class App extends StatelessWidget {
  const App({super.key, required this.showOnboarding});

  final bool showOnboarding;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: buildTapPinTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: showOnboarding ? const OnboardingPage() : const HomePage(),
    );
  }
}
