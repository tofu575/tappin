import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/usecases/pin_usecase.dart';
import 'package:tappin/presentation/pages/pin_list_page.dart';
import 'package:tappin/presentation/providers/pin_provider.dart';

import '../../helpers/mock_pin_repository.dart';

Widget _buildPage({List<Pin> pins = const []}) {
  return ProviderScope(
    overrides: [
      pinUseCaseProvider.overrideWithValue(
        PinUseCase(MockPinRepository(stubbedPins: pins)),
      ),
    ],
    child: const MaterialApp(home: PinListPage()),
  );
}

void main() {
  testWidgets('Pinが0件のとき「記録がありません」と表示される', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pumpAndSettle();

    expect(find.text('記録がありません'), findsOneWidget);
  });

  testWidgets('Pinがある場合、日付と座標が表示される', (tester) async {
    await tester.pumpWidget(_buildPage(pins: [buildTestPin()]));
    await tester.pumpAndSettle();

    expect(find.text('2024/01/15 10:30'), findsOneWidget);
    expect(find.text('35.681200, 139.767100'), findsOneWidget);
  });

  testWidgets('複数のPinがある場合、件数分だけリストアイテムが表示される', (tester) async {
    final pins = [buildTestPin(id: 1), buildTestPin(id: 2), buildTestPin(id: 3)];
    await tester.pumpWidget(_buildPage(pins: pins));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.location_on), findsNWidgets(3));
  });

  testWidgets('削除ボタンをタップすると deletePin が呼ばれる', (tester) async {
    final repo = MockPinRepository(stubbedPins: [buildTestPin(id: 42)]);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        pinUseCaseProvider.overrideWithValue(PinUseCase(repo)),
      ],
      child: const MaterialApp(home: PinListPage()),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(repo.deletedIds, contains(42));
  });
}
