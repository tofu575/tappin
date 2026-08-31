import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tappin/presentation/pages/home_page.dart';
import 'package:tappin/presentation/localization/app_localizations_context.dart';
import 'package:tappin/presentation/assets/onboarding_visual.dart';
import 'package:tappin/presentation/assets/tap_pin_visual_assets.dart';
import 'package:tappin/presentation/providers/interactor_provider.dart';
import 'package:tappin/presentation/theme/tap_pin_colors_context.dart';
import 'package:tappin/presentation/widgets/paper_background.dart';

class _OnboardingStep {
  const _OnboardingStep({
    required this.visual,
    required this.title,
    required this.description,
  });

  final OnboardingVisual visual;
  final String title;
  final String description;
}

const _onboardingStepCount = 4;

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await ref.read(interactorProvider).completeOnboarding();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final steps = [
      _OnboardingStep(
        visual: OnboardingVisual.pin,
        title: l10n.onboardingWelcomeTitle,
        description: l10n.onboardingWelcomeDescription,
      ),
      _OnboardingStep(
        visual: OnboardingVisual.review,
        title: l10n.onboardingReviewTitle,
        description: l10n.onboardingReviewDescription,
      ),
      _OnboardingStep(
        visual: OnboardingVisual.quickMode,
        title: l10n.onboardingQuickModeTitle,
        description: l10n.onboardingQuickModeDescription,
      ),
      _OnboardingStep(
        visual: OnboardingVisual.privacy,
        title: l10n.onboardingPrivacyTitle,
        description: l10n.onboardingPrivacyDescription,
      ),
    ];
    final isLastPage = _currentPage == _onboardingStepCount - 1;

    return Scaffold(
      body: PaperBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onboardingStepCount,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) =>
                      _OnboardingStepView(step: steps[index]),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingStepCount,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed:
                            isLastPage ? _completeOnboarding : _goToNextPage,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isLastPage ? l10n.start : l10n.next,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingStepView extends StatelessWidget {
  const _OnboardingStepView({required this.step});

  final _OnboardingStep step;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = context.tapPinColors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colors.paperElevated,
              shape: BoxShape.circle,
              border: Border.all(color: colors.dividerInk),
              boxShadow: [
                BoxShadow(
                  color: colors.ink.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: TapPinVisualAssets.onboarding(
                context,
                step.visual,
                size: 58,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            step.title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            step.description,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
