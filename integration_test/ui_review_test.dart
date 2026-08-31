import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:tappin/app.dart';
import 'package:tappin/domain/models/core/my_datetime.dart';
import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/models/location/latitude.dart';
import 'package:tappin/domain/models/location/longitude.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/presentation/pages/quick_mode/quick_mode_page.dart';
import 'package:tappin/presentation/providers/interactor_provider.dart';
import 'package:tappin/presentation/providers/screen_awake_provider.dart';

import '../test/helpers/build_test_interactor.dart';
import '../test/helpers/mock_clock_gateway.dart';
import '../test/helpers/mock_location_service.dart';
import '../test/helpers/mock_repository.dart';
import '../test/helpers/mock_screen_awake_gateway.dart';
import 'helpers/ui_review_fixture.dart';
import 'helpers/ui_review_geocoding_service.dart';

/// 新しい記録・確認ワークフローの主要状態を実操作して撮影する。
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsApp.debugAllowBannerOverride = false;

  testWidgets('主要画面のスクリーンショットを生成する', (tester) async {
    await binding.convertFlutterSurfaceToImage();

    await tester.pumpWidget(_buildReviewApp(showOnboarding: true));
    await tester.pumpAndSettle();
    await _takeUiScreenshot(binding, tester, '01_onboarding');

    await tester.pumpWidget(_buildReviewApp(showOnboarding: false));
    await tester.pumpAndSettle();
    await _takeUiScreenshot(binding, tester, '02_home_unreviewed');

    await tester.pumpWidget(
      _buildReviewApp(showOnboarding: false, pins: const []),
    );
    await tester.pumpAndSettle();
    await _takeUiScreenshot(binding, tester, '03_home_empty');

    await tester.pumpWidget(_buildReviewApp(showOnboarding: false));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('history-index-tab')));
    await tester.pumpAndSettle();
    await _takeUiScreenshot(binding, tester, '04_history_unreviewed');

    await tester.tap(find.textContaining('✓ 確認済み'));
    await tester.pumpAndSettle();
    await _takeUiScreenshot(binding, tester, '05_history_reviewed');

    await tester.tap(find.textContaining('👀 未確認'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('history-pin-1')));
    await tester.pumpAndSettle();
    await _takeUiScreenshot(binding, tester, '06_pin_detail');

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quick-mode-entry')));
    await tester.pumpAndSettle();
    await _takeUiScreenshot(binding, tester, '07_quick_mode_guide');

    await tester.tap(find.byKey(const Key('start-quick-mode')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(QuickModePage), findsOneWidget);
    await _takeUiScreenshot(binding, tester, '08_quick_mode');

    await tester.tap(find.byKey(const Key('quick-record-area')));
    await tester.pump(const Duration(milliseconds: 350));
    await _takeUiScreenshot(binding, tester, '09_quick_mode_recorded');
  });
}

/// 固定Pinと端末GatewayのMockを注入したレビュー用Appを返す。
Widget _buildReviewApp({required bool showOnboarding, List<Pin>? pins}) {
  final repository = MockRipository(stubbedPins: pins ?? buildUiReviewPins());
  final interactor = buildTestInteractor(
    repository: repository,
    locationGateway: MockLocationService.success(
      const Coordinate(
        latitude: Latitude(35.681236),
        longitude: Longitude(139.767125),
      ),
    ),
    geocodingGateway: UiReviewGeocodingService(),
    clockGateway: MockClockGateway(
      current: MyDatetime(DateTime(2026, 8, 31, 8, 45)),
    ),
  );
  return ProviderScope(
    key: UniqueKey(),
    overrides: [
      interactorProvider.overrideWithValue(interactor),
      screenAwakeProvider.overrideWithValue(MockScreenAwakeGateway()),
    ],
    child: App(showOnboarding: showOnboarding),
  );
}

/// 描画を1フレーム進め、端末上のFlutter surfaceを[name]で撮影する。
Future<void> _takeUiScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  await tester.pump(const Duration(milliseconds: 100));
  final png = await binding.takeScreenshot(name);
  expect(png, isNotEmpty);
}
