import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tappin/domain/services/location_service.dart';
import 'package:tappin/presentation/pages/drive_mode/drive_mode_page.dart';
import 'package:tappin/presentation/pages/drive_mode/drive_mode_transition_page.dart';
import 'package:tappin/presentation/pages/home_page.dart';
import 'package:tappin/presentation/providers/interactor_provider.dart';
import 'package:tappin/presentation/providers/screen_awake_provider.dart';

import '../../helpers/build_test_interactor.dart';
import '../../helpers/mock_geocoding_service.dart';
import '../../helpers/mock_haptic_gateway.dart';
import '../../helpers/mock_location_service.dart';
import '../../helpers/mock_overlay_service.dart';
import '../../helpers/mock_repository.dart';
import '../../helpers/mock_screen_awake_gateway.dart';

Widget _buildPage({
  MockRipository? repo,
  LocationService? locationService,
  MockOverlayService? overlayService,
  MockHapticGateway? hapticGateway,
}) {
  return ProviderScope(
    overrides: [
      interactorProvider.overrideWithValue(
        buildTestInteractor(
          repository: repo,
          locationGateway: locationService,
          geocodingGateway: MockGeocodingService(),
          overlayGateway: overlayService,
          hapticGateway: hapticGateway,
        ),
      ),
      screenAwakeProvider.overrideWithValue(MockScreenAwakeGateway()),
    ],
    child: const MaterialApp(home: HomePage()),
  );
}

void main() {
  testWidgets('画面表示時に位置情報を先行取得する', (tester) async {
    final locationService = MockLocationService.success(testCoordinate);

    await tester.pumpWidget(_buildPage(locationService: locationService));
    await tester.pump();

    expect(locationService.warmUpCount, 1);
  });

  testWidgets('記録ボタンが表示される', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    expect(find.text('記録'), findsOneWidget);
  });

  testWidgets('Drive modeの入口から開始確認を開ける', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    await tester.tap(find.byKey(const Key('drive-mode-entry')));
    await tester.pumpAndSettle();

    expect(find.textContaining('画面全体が記録ボタンになります。'), findsOneWidget);
    expect(find.text('開始する'), findsOneWidget);
    expect(find.text('キャンセル'), findsOneWidget);
  });

  testWidgets('Drive modeの入口を上スワイプして開始確認を開ける', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    await tester.fling(
      find.byKey(const Key('drive-mode-entry')),
      const Offset(0, -200),
      1000,
    );
    await tester.pumpAndSettle();

    expect(find.text('開始する'), findsOneWidget);
  });

  testWidgets('Drive mode開始確認をキャンセルするとHomeに留まる', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    await tester.tap(find.byKey(const Key('drive-mode-entry')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(DriveModePage), findsNothing);
  });

  testWidgets('Drive modeを開始すると車の演出後に専用画面へ遷移する', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    await tester.tap(find.byKey(const Key('drive-mode-entry')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('start-drive-mode')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(DriveModePage), findsOneWidget);
    expect(find.byType(DriveModeTransitionPage), findsNothing);
    expect(find.text('画面のどこでもタップで記録'), findsOneWidget);
  });

  testWidgets('初期状態では最新ピンカードが表示されない', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    expect(find.byType(Card), findsNothing);
  });

  testWidgets('記録ボタンをタップすると現在地が保存され成功メッセージが表示される', (tester) async {
    final repo = MockRipository();

    await tester.pumpWidget(_buildPage(repo: repo));
    await tester.pump();

    await tester.tap(find.text('記録'));
    await tester.pumpAndSettle();

    expect(find.text('現在地を記録しました'), findsOneWidget);
    expect(repo.savedPins, hasLength(1));
  });

  testWidgets('通常記録でも共通のハプティクスと画面フラッシュを使用する', (tester) async {
    final hapticGateway = MockHapticGateway();

    await tester.pumpWidget(_buildPage(hapticGateway: hapticGateway));
    await tester.pump();
    await tester.tap(find.text('記録'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(hapticGateway.recordSuccessCount, 1);
    final flash = tester.widget<FadeTransition>(
      find.byWidgetPredicate(
        (widget) =>
            widget is FadeTransition &&
            widget.child?.key == const Key('record-feedback-flash'),
      ),
    );
    expect(flash.opacity.value, greaterThan(0));
  });

  testWidgets('記録成功後に最新ピンカードが表示される', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    await tester.tap(find.text('記録'));
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsOneWidget);
  });

  testWidgets('位置情報の権限が一時的に拒否された場合、スナックバーが表示される', (tester) async {
    await tester.pumpWidget(
      _buildPage(locationService: MockLocationService.denied()),
    );
    await tester.pump();

    await tester.tap(find.text('記録'));
    await tester.pumpAndSettle();

    expect(find.text('位置情報が許可されませんでした'), findsOneWidget);
  });

  testWidgets('位置情報の権限が永久に拒否された場合、設定ダイアログが表示される', (tester) async {
    await tester.pumpWidget(
      _buildPage(locationService: MockLocationService.permanentlyDenied()),
    );
    await tester.pump();

    await tester.tap(find.text('記録'));
    await tester.pumpAndSettle();

    expect(find.text('位置情報の許可が必要です'), findsOneWidget);
    expect(find.text('設定から位置情報へのアクセスを許可してください'), findsOneWidget);
  });

  testWidgets('予期しないエラーが発生した場合、エラーメッセージが表示される', (tester) async {
    final hapticGateway = MockHapticGateway();
    await tester.pumpWidget(
      _buildPage(
        locationService: MockLocationService.error('GPS unavailable'),
        hapticGateway: hapticGateway,
      ),
    );
    await tester.pump();

    await tester.tap(find.text('記録'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('エラーが発生しました'), findsOneWidget);
    expect(hapticGateway.recordSuccessCount, 0);
    expect(hapticGateway.recordFailureCount, 1);
    final failureFlash = tester.widget<ColoredBox>(
      find.byKey(const Key('record-feedback-flash')),
    );
    expect(
      failureFlash.color,
      Theme.of(tester.element(find.byType(HomePage))).colorScheme.error,
    );
  });

  testWidgets('AppBarに地図・一覧ボタンが表示される', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    expect(find.byIcon(Icons.map), findsOneWidget);
    expect(find.byIcon(Icons.list), findsOneWidget);
  });
}
