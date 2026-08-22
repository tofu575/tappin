import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tappin/domain/services/location_service.dart';
import 'package:tappin/domain/usecases/use_case.dart';
import 'package:tappin/presentation/pages/home_page.dart';
import 'package:tappin/presentation/providers/provider.dart';

import '../../helpers/mock_geocoding_service.dart';
import '../../helpers/mock_location_service.dart';
import '../../helpers/mock_overlay_service.dart';
import '../../helpers/mock_repository.dart';

Widget _buildPage({
  MockRipository? repo,
  LocationService? locationService,
  MockOverlayService? overlayService,
}) {
  return ProviderScope(
    overrides: [
      useCaseProvider.overrideWithValue(UseCase(repo ?? MockRipository())),
      locationServiceProvider.overrideWithValue(
        locationService ?? MockLocationService.success(testCoordinate),
      ),
      geocodingServiceProvider.overrideWithValue(MockGeocodingService()),
      overlayServiceProvider.overrideWithValue(
        overlayService ?? MockOverlayService(),
      ),
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
    await tester.pumpWidget(
      _buildPage(locationService: MockLocationService.error('GPS unavailable')),
    );
    await tester.pump();

    await tester.tap(find.text('記録'));
    await tester.pumpAndSettle();

    expect(find.textContaining('エラーが発生しました'), findsOneWidget);
  });

  testWidgets('AppBarに地図・一覧ボタンが表示される', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    expect(find.byIcon(Icons.map), findsOneWidget);
    expect(find.byIcon(Icons.list), findsOneWidget);
  });
}
