import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:usecase/usecase.dart';
import 'package:model/model.dart';
import 'package:tappin/presentation/pages/about/about_page.dart';
import 'package:tappin/presentation/pages/quick_mode/quick_mode_page.dart';
import 'package:tappin/presentation/pages/quick_mode/quick_mode_transition_page.dart';
import 'package:tappin/presentation/pages/home_page.dart';
import 'package:tappin/presentation/providers/interactor_provider.dart';
import 'package:tappin/presentation/providers/screen_awake_provider.dart';

import '../../helpers/build_test_interactor.dart';
import '../../helpers/mock_geocoding_service.dart';
import '../../helpers/mock_haptic_gateway.dart';
import '../../helpers/mock_location_service.dart';
import '../../helpers/mock_repository.dart';
import '../../helpers/mock_screen_awake_gateway.dart';

Widget _buildPage({
  MockRipository? repo,
  LocationService? locationService,
  MockHapticGateway? hapticGateway,
}) {
  return ProviderScope(
    overrides: [
      interactorProvider.overrideWithValue(
        buildTestInteractor(
          repository: repo,
          locationGateway: locationService,
          geocodingGateway: MockGeocodingService(),
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

  testWidgets('Tappinについて画面からWebページへの導線を確認できる', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    await tester.tap(find.byKey(const Key('about-tappin-button')));
    await tester.pumpAndSettle();

    expect(find.byType(AboutPage), findsOneWidget);
    expect(find.text('公式サイト'), findsOneWidget);
    expect(find.text('プライバシーポリシー'), findsOneWidget);
    expect(find.text('利用規約'), findsOneWidget);
    expect(find.byKey(const Key('official-website-link')), findsOneWidget);
    expect(find.byKey(const Key('privacy-policy-link')), findsOneWidget);
    expect(find.byKey(const Key('terms-of-service-link')), findsOneWidget);
  });

  testWidgets('未確認が0件なら右端のインデックスを履歴と表示する', (tester) async {
    await tester.pumpWidget(_buildPage(repo: MockRipository()));
    await tester.pumpAndSettle();

    expect(find.text('履歴'), findsOneWidget);
  });

  testWidgets('右端のインデックスへ未確認件数を穏やかに表示する', (tester) async {
    await tester.pumpWidget(
      _buildPage(
        repo: MockRipository(
          stubbedPins: [
            buildTestPin(id: 1),
            buildTestPin(id: 2),
            buildTestPin(id: 3, reviewStatus: PinReviewStatus.reviewed),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('未確認 2'), findsOneWidget);
  });

  testWidgets('Quick Modeの入口から開始確認を開ける', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    await tester.tap(find.byKey(const Key('quick-mode-entry')));
    await tester.pumpAndSettle();

    expect(find.textContaining('画面全体をタップして'), findsOneWidget);
    expect(find.textContaining('運転者は操作しない'), findsOneWidget);
    expect(
      find.image(const AssetImage('assets/images/movement_car.png')),
      findsOneWidget,
    );
    expect(find.text('Quick Modeをはじめる'), findsOneWidget);
    expect(find.text('キャンセル'), findsOneWidget);
  });

  testWidgets('Quick Modeの入口は下から引き出す方向を示す', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
  });

  testWidgets('Quick Modeの入口を上スワイプして開始確認を開ける', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    await tester.fling(
      find.byKey(const Key('quick-mode-entry')),
      const Offset(0, -200),
      1000,
    );
    await tester.pumpAndSettle();

    expect(find.text('Quick Modeをはじめる'), findsOneWidget);
  });

  testWidgets('Quick Mode開始確認をキャンセルするとHomeに留まる', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    await tester.tap(find.byKey(const Key('quick-mode-entry')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(QuickModePage), findsNothing);
  });

  testWidgets('Quick Modeを開始すると移動キャラクターの演出後に遷移する', (tester) async {
    await tester.pumpWidget(_buildPage());
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

    expect(find.byType(QuickModePage), findsOneWidget);
    expect(find.byType(QuickModeTransitionPage), findsNothing);
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
    final initialFlash = tester.widget<FadeTransition>(
      find.byWidgetPredicate(
        (widget) =>
            widget is FadeTransition &&
            widget.child?.key == const Key('record-feedback-flash'),
      ),
    );
    expect(initialFlash.opacity.value, 0);

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

    expect(find.text('記録しました'), findsOneWidget);
  });

  testWidgets('位置情報の権限が一時的に拒否された場合、スナックバーが表示される', (tester) async {
    await tester.pumpWidget(
      _buildPage(locationService: MockLocationService.denied()),
    );
    await tester.pump();

    await tester.tap(find.text('記録'));
    await tester.pumpAndSettle();

    expect(find.text('位置情報が許可されていません'), findsOneWidget);
  });

  testWidgets('位置情報の権限が永久に拒否された場合、設定ダイアログが表示される', (tester) async {
    await tester.pumpWidget(
      _buildPage(locationService: MockLocationService.permanentlyDenied()),
    );
    await tester.pump();

    await tester.tap(find.text('記録'));
    await tester.pumpAndSettle();

    expect(find.text('位置情報の許可が必要です'), findsOneWidget);
    expect(find.text('設定から位置情報へのアクセスを許可してください。'), findsOneWidget);
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

    expect(find.textContaining('記録できませんでした'), findsOneWidget);
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

  testWidgets('主要導線にMapとOverlayを置かず履歴タブを表示する', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    expect(find.byIcon(Icons.map), findsNothing);
    expect(find.byIcon(Icons.picture_in_picture), findsNothing);
    expect(find.byKey(const Key('history-index-tab')), findsOneWidget);
  });
}
