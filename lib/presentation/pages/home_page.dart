import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/models/pin/pin_review_status.dart';
import 'package:tappin/presentation/pages/history/history_page.dart';
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

/// 通常記録を主役に、履歴とQuick Modeを画面端へ配置するHome画面。
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestPin = useState<Pin?>(null);
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
                  const Text(
                    '🚲  🚶  🚌',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 34),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Quick Mode',
                    textAlign: TextAlign.center,
                    style: Theme.of(sheetContext).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '画面のどこをタップしても、\n気になった場所をすぐ記録できます。',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const Key('start-quick-mode'),
                    onPressed: () => Navigator.pop(sheetContext, true),
                    child: const Text('Quick Modeをはじめる'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(sheetContext, false),
                    child: const Text('キャンセル'),
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
        body: SafeArea(
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
                            'TapPin',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '気になった場所を、ここに預けよう。',
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
            ],
          ),
        ),
      ),
    );
  }
}
