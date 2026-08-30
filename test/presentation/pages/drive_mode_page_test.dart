import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tappin/presentation/pages/drive_mode/drive_mode_page.dart';
import 'package:tappin/presentation/pages/drive_mode/drive_mode_transition_page.dart';
import 'package:tappin/presentation/pages/drive_mode/drive_transition_direction.dart';
import 'package:tappin/presentation/pages/home_page.dart';
import 'package:tappin/presentation/providers/interactor_provider.dart';

import '../../helpers/build_test_interactor.dart';
import '../../helpers/mock_haptic_gateway.dart';
import '../../helpers/mock_repository.dart';

/// [repo]へ保存するDrive mode画面を本番と同じProvider境界で構築する。
Widget _buildDrivePage(
  MockRipository repo, {
  MockHapticGateway? hapticGateway,
}) {
  return ProviderScope(
    overrides: [
      interactorProvider.overrideWithValue(
        buildTestInteractor(repository: repo, hapticGateway: hapticGateway),
      ),
    ],
    child: const MaterialApp(home: DriveModePage()),
  );
}

/// [repo]へ保存するHome画面を、終了遷移の戻り先として構築する。
Widget _buildHomePage(MockRipository repo) {
  return ProviderScope(
    overrides: [
      interactorProvider.overrideWithValue(
        buildTestInteractor(repository: repo),
      ),
    ],
    child: const MaterialApp(home: HomePage()),
  );
}

/// Drive modeの全画面記録と安全な長押し終了を検証する。
void main() {
  testWidgets('画面の異なる位置をタップすると1タップにつき1回記録する', (tester) async {
    for (final position in const [Offset(30, 120), Offset(760, 300)]) {
      final repo = MockRipository();
      final hapticGateway = MockHapticGateway();
      await tester.pumpWidget(
        _buildDrivePage(repo, hapticGateway: hapticGateway),
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

      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('開始・終了で共通の車トランジションWidgetを表示する', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DriveModeTransitionPage(
          direction: DriveTransitionDirection.entering,
          onCompleted: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('drive-transition-car')), findsOneWidget);
    expect(find.text('Drive mode'), findsOneWidget);
  });

  testWidgets('長押し途中で離すと終了せず記録も発生しない', (tester) async {
    final repo = MockRipository();
    await tester.pumpWidget(_buildDrivePage(repo));
    await tester.pump();

    final gesture = await tester.startGesture(const Offset(400, 300));
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.byKey(const Key('drive-exit-progress')), findsOneWidget);

    await gesture.up();
    await tester.pump();

    expect(find.byType(DriveModePage), findsOneWidget);
    expect(find.byKey(const Key('drive-exit-progress')), findsNothing);
    expect(repo.savedPins, isEmpty);
  });

  testWidgets('規定時間長押しすると逆方向の演出を経てHomeへ戻る', (tester) async {
    final repo = MockRipository();
    await tester.pumpWidget(_buildHomePage(repo));
    await tester.pump();

    await tester.tap(find.byKey(const Key('drive-mode-entry')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('start-drive-mode')));
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(const Offset(400, 300));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    expect(find.byType(DriveModeTransitionPage), findsOneWidget);
    expect(find.text('通常モードへ戻ります'), findsOneWidget);
    expect(repo.savedPins, isEmpty);

    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(DriveModePage), findsNothing);
    expect(repo.savedPins, isEmpty);
  });
}
