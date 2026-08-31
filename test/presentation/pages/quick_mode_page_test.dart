import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tappin/presentation/pages/quick_mode/components/quick_mode_character_lane.dart';
import 'package:tappin/presentation/pages/quick_mode/components/recording_pin_indicator.dart';
import 'package:tappin/presentation/pages/quick_mode/quick_mode_character.dart';
import 'package:tappin/presentation/pages/quick_mode/quick_mode_page.dart';
import 'package:tappin/presentation/pages/quick_mode/quick_mode_transition_page.dart';
import 'package:tappin/presentation/pages/quick_mode/quick_mode_transition_direction.dart';
import 'package:tappin/presentation/pages/home_page.dart';
import 'package:tappin/presentation/providers/interactor_provider.dart';
import 'package:tappin/presentation/providers/screen_awake_provider.dart';

import '../../helpers/build_test_interactor.dart';
import '../../helpers/mock_haptic_gateway.dart';
import '../../helpers/mock_repository.dart';
import '../../helpers/mock_screen_awake_gateway.dart';

/// [repo]へ保存するQuick Mode画面を本番と同じProvider境界で構築する。
Widget _buildQuickModePage(
  MockRipository repo, {
  MockHapticGateway? hapticGateway,
  MockScreenAwakeGateway? screenAwakeGateway,
}) {
  return ProviderScope(
    overrides: [
      interactorProvider.overrideWithValue(
        buildTestInteractor(repository: repo, hapticGateway: hapticGateway),
      ),
      screenAwakeProvider.overrideWithValue(
        screenAwakeGateway ?? MockScreenAwakeGateway(),
      ),
    ],
    child: const MaterialApp(
      home: QuickModePage(character: QuickModeCharacter.bicycle),
    ),
  );
}

/// [repo]へ保存するHome画面を、終了遷移の戻り先として構築する。
Widget _buildHomePage(
  MockRipository repo, {
  MockScreenAwakeGateway? screenAwakeGateway,
}) {
  return ProviderScope(
    overrides: [
      interactorProvider.overrideWithValue(
        buildTestInteractor(repository: repo),
      ),
      screenAwakeProvider.overrideWithValue(
        screenAwakeGateway ?? MockScreenAwakeGateway(),
      ),
    ],
    child: const MaterialApp(home: HomePage()),
  );
}

/// Quick Modeの全画面記録と安全な長押し終了を検証する。
void main() {
  testWidgets('画面の異なる位置をタップすると1タップにつき1回記録する', (tester) async {
    for (final position in const [Offset(30, 120), Offset(760, 300)]) {
      final repo = MockRipository();
      final hapticGateway = MockHapticGateway();
      await tester.pumpWidget(
        _buildQuickModePage(repo, hapticGateway: hapticGateway),
      );
      await tester.pump();

      await tester.tapAt(position);
      await tester.pump(const Duration(milliseconds: 100));
      expect(repo.savedPins, hasLength(1));
      expect(hapticGateway.recordSuccessCount, 1);

      final flash = tester.widget<FadeTransition>(
        find.byWidgetPredicate(
          (widget) =>
              widget is FadeTransition &&
              widget.child?.key == const Key('record-feedback-flash'),
        ),
      );
      expect(flash.opacity.value, greaterThan(0));

      await tester.pump(const Duration(milliseconds: 400));

      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('記録中はピンが下から満たされ、車の常時アニメーションが存在する', (tester) async {
    final repo = MockRipository();
    await tester.pumpWidget(_buildQuickModePage(repo));
    await tester.pump();

    expect(find.byType(RecordingPinIndicator), findsOneWidget);
    expect(find.byType(QuickModeCharacterLane), findsOneWidget);
    expect(find.text('🚲'), findsOneWidget);

    await tester.tapAt(const Offset(400, 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final indicator = tester.widget<RecordingPinIndicator>(
      find.byType(RecordingPinIndicator),
    );
    expect(indicator.progress.value, inExclusiveRange(0, 1));

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    expect(indicator.progress.value, 0);
  });

  testWidgets('表示中だけScreen Awakeを有効にし、バックグラウンドと破棄時に解除する', (tester) async {
    final screenAwakeGateway = MockScreenAwakeGateway();
    await tester.pumpWidget(
      _buildQuickModePage(
        MockRipository(),
        screenAwakeGateway: screenAwakeGateway,
      ),
    );
    await tester.pump();

    expect(screenAwakeGateway.enableCount, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(screenAwakeGateway.disableCount, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(screenAwakeGateway.enableCount, 2);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(screenAwakeGateway.disableCount, 2);
  });

  testWidgets('開始・終了で共通の車トランジションWidgetを表示する', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: QuickModeTransitionPage(
          direction: QuickModeTransitionDirection.entering,
          character: QuickModeCharacter.bicycle,
          onCompleted: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('quick-mode-transition-character')),
      findsOneWidget,
    );
    expect(find.text('Quick Mode'), findsOneWidget);
  });

  testWidgets('長押し途中で離すと終了せず記録も発生しない', (tester) async {
    final repo = MockRipository();
    await tester.pumpWidget(_buildQuickModePage(repo));
    await tester.pump();

    final gesture = await tester.startGesture(const Offset(400, 300));
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.byKey(const Key('drive-exit-progress')), findsOneWidget);

    await gesture.up();
    await tester.pump();

    expect(find.byType(QuickModePage), findsOneWidget);
    expect(find.byKey(const Key('drive-exit-progress')), findsNothing);
    expect(repo.savedPins, isEmpty);
  });

  testWidgets('規定時間長押しすると逆方向の演出を経てHomeへ戻る', (tester) async {
    final repo = MockRipository();
    await tester.pumpWidget(_buildHomePage(repo));
    await tester.pump();

    await tester.tap(find.byKey(const Key('quick-mode-entry')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('start-quick-mode')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final gesture = await tester.startGesture(const Offset(400, 300));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    expect(find.byType(QuickModeTransitionPage), findsOneWidget);
    expect(find.text('ホームへ戻ります'), findsOneWidget);
    expect(repo.savedPins, isEmpty);

    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(QuickModePage), findsNothing);
    expect(repo.savedPins, isEmpty);
  });
}
