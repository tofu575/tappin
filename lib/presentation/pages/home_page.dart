import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:model/model.dart';
import 'package:tappin/presentation/assets/tap_pin_visual_assets.dart';
import 'package:tappin/presentation/pages/about/about_page.dart';
import 'package:tappin/presentation/pages/history/history_page.dart';
import 'package:tappin/presentation/localization/app_localizations_context.dart';
import 'package:tappin/presentation/pages/home/components/history_index_tab.dart';
import 'package:tappin/presentation/pages/home/components/latest_pin_card.dart';
import 'package:tappin/presentation/pages/home/components/quick_mode_entry.dart';
import 'package:tappin/presentation/pages/quick_mode/quick_mode_character.dart';
import 'package:tappin/presentation/pages/quick_mode/quick_mode_page.dart';
import 'package:tappin/presentation/pages/quick_mode/quick_mode_transition_page.dart';
import 'package:tappin/presentation/pages/quick_mode/quick_mode_transition_direction.dart';
import 'package:tappin/presentation/providers/interactor_provider.dart';
import 'package:tappin/presentation/providers/provider.dart';
import 'package:tappin/presentation/providers/recording_provider.dart';
import 'package:tappin/presentation/widgets/record_action.dart';
import 'package:tappin/presentation/widgets/record_button.dart';
import 'package:tappin/presentation/widgets/record_feedback.dart';
import 'package:tappin/presentation/widgets/record_feedback_controller.dart';
import 'package:tappin/presentation/widgets/paper_background.dart';

/// 通常記録を主役に、履歴とQuick Modeを画面端へ配置するHome画面。
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestPin = useState<Pin?>(null);
    final l10n = context.l10n;
    final feedbackController = useMemoized(RecordFeedbackController.new);
    final pins = ref.watch(pinsProvider).value ?? const <Pin>[];
    final unreviewedCount = pins
        .where((pin) => pin.reviewStatus == PinReviewStatus.unreviewed)
        .length;

    useEffect(() {
      unawaited(ref.read(interactorProvider).warmUpLocation());
      return null;
    }, const []);

    useOnAppLifecycleStateChange((_, current) {
      if (current == AppLifecycleState.resumed) ref.invalidate(pinsProvider);
    });

    Future<void> openQuickMode() async {
      final shouldStart = await showModalBottomSheet<bool>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TapPinVisualAssets.movementCharacter(
                        QuickModeCharacter.walking,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      TapPinVisualAssets.movementCharacter(
                        QuickModeCharacter.car,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      TapPinVisualAssets.movementCharacter(
                        QuickModeCharacter.bus,
                        size: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.quickMode,
                    textAlign: TextAlign.center,
                    style: Theme.of(sheetContext).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.quickModeGuide, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const Key('start-quick-mode'),
                    onPressed: () => Navigator.pop(sheetContext, true),
                    child: Text(l10n.startQuickMode),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(sheetContext, false),
                    child: Text(l10n.cancel),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      if (shouldStart != true || !context.mounted) return;

      final character = QuickModeCharacter.selectRandom();
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => QuickModeTransitionPage(
            direction: QuickModeTransitionDirection.entering,
            character: character,
            onCompleted: (transitionContext) {
              Navigator.of(transitionContext).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => QuickModePage(character: character),
                ),
              );
            },
          ),
        ),
      );
      ref.invalidate(pinsProvider);
    }

    Future<void> recordCurrentLocation() async {
      await performRecordAction(
        context: context,
        ref: ref,
        feedbackController: feedbackController,
        onSuccess: (pin) => latestPin.value = pin,
      );
    }

    return RecordFeedback(
      controller: feedbackController,
      child: Scaffold(
        body: PaperBackground(
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 18, 92, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.appTitle,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.homeTagline,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: RecordButton(
                          onPressed: recordCurrentLocation,
                          isLoading: ref.watch(recordingProvider).isLoading,
                        ),
                      ),
                    ),
                    if (latestPin.value != null)
                      LatestPinCard(pin: latestPin.value!),
                    QuickModeEntry(onTap: openQuickMode),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 92,
                  child: HistoryIndexTab(
                    unreviewedCount: unreviewedCount,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const HistoryPage(),
                        ),
                      );
                      ref.invalidate(pinsProvider);
                    },
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 6,
                  child: IconButton(
                    key: const Key('about-tappin-button'),
                    tooltip: l10n.aboutTappin,
                    icon: const Icon(Icons.info_outline_rounded),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AboutPage(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
