import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tappin/domain/services/location_service.dart';
import 'package:tappin/domain/usecases/use_case.dart';
import 'package:tappin/presentation/pages/home_page.dart';
import 'package:tappin/presentation/providers/provider.dart';

import '../../helpers/mock_geocoding_service.dart';
import '../../helpers/mock_home_widget_service.dart';
import '../../helpers/mock_location_service.dart';
import '../../helpers/mock_repository.dart';

Widget _buildPage({
  MockPinRepository? repo,
  LocationService? locationService,
}) {
  final repository = repo ?? MockPinRepository();
  return ProviderScope(
    overrides: [
      useCaseProvider.overrideWithValue(UseCase(repository)),
      locationServiceProvider.overrideWithValue(
        locationService ?? MockLocationService.success(testCoordinate),
      ),
      geocodingServiceProvider.overrideWithValue(MockGeocodingService()),
      homeWidgetServiceProvider.overrideWithValue(MockHomeWidgetService()),
    ],
    child: const MaterialApp(home: HomePage()),
  );
}

void main() {
  testWidgets('記録ボタンが表示される', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pump();

    expect(find.text('記録'), findsOneWidget);
  });

  testWidgets('記録ボタンをタップすると現在地が保存され成功メッセージが表示される', (tester) async {
    final repo = MockPinRepository();

    await tester.pumpWidget(_buildPage(repo: repo));
    await tester.pump();

    expect(find.byType(Card), findsNothing);

    await tester.tap(find.text('記録'));
    await tester.pumpAndSettle();

    expect(find.text('現在地を記録しました'), findsOneWidget);
    expect(repo.savedPins, hasLength(1));
    expect(find.byType(Card), findsOneWidget);
  });

  testWidgets('位置情報の権限が拒否された場合、許可を求めるメッセージが表示される', (tester) async {
    await tester.pumpWidget(_buildPage(
      locationService: MockLocationService.denied(),
    ));
    await tester.pump();

    await tester.tap(find.text('記録'));
    await tester.pumpAndSettle();

    expect(find.text('位置情報の許可が必要です'), findsOneWidget);
  });

  testWidgets('予期しないエラーが発生した場合、エラーメッセージが表示される', (tester) async {
    await tester.pumpWidget(_buildPage(
      locationService: MockLocationService.error('GPS unavailable'),
    ));
    await tester.pump();

    await tester.tap(find.text('記録'));
    await tester.pumpAndSettle();

    expect(find.textContaining('エラーが発生しました'), findsOneWidget);
  });
}
