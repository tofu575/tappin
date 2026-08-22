import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tappin/domain/models/pin/memo.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/usecases/use_case.dart';
import 'package:tappin/presentation/pages/list_page.dart';
import 'package:tappin/presentation/providers/provider.dart';

import '../../helpers/mock_geocoding_service.dart';
import '../../helpers/mock_repository.dart';

Widget _buildPage({
  List<Pin> pins = const [],
  MockGeocodingService? geocodingService,
  MockRipository? repo,
}) {
  final repository = repo ?? MockRipository(stubbedPins: pins);
  return ProviderScope(
    overrides: [
      useCaseProvider.overrideWithValue(UseCase(repository)),
      geocodingServiceProvider.overrideWithValue(
        geocodingService ?? MockGeocodingService(),
      ),
    ],
    child: const MaterialApp(home: ListPage()),
  );
}

void main() {
  testWidgets('Pinが0件のとき「記録がありません」と表示される', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pumpAndSettle();

    expect(find.text('まだ記録がありません'), findsOneWidget);
  });

  testWidgets('Pinがある場合、日付と住所が表示される', (tester) async {
    await tester.pumpWidget(_buildPage(pins: [buildTestPin()]));
    await tester.pumpAndSettle();

    expect(find.text('2024/01/15 10:30'), findsOneWidget);
    expect(find.text('東京都渋谷区道玄坂'), findsOneWidget);
  });

  testWidgets('Pinがある場合、左スワイプで削除できる案内が表示される', (tester) async {
    await tester.pumpWidget(_buildPage(pins: [buildTestPin()]));
    await tester.pumpAndSettle();

    expect(find.text('記録を左にスワイプすると削除できます'), findsOneWidget);
    expect(find.byIcon(Icons.swipe_left), findsOneWidget);
  });

  testWidgets('複数のPinがある場合、件数分だけリストアイテムが表示される', (tester) async {
    final pins = [
      buildTestPin(id: 1),
      buildTestPin(id: 2),
      buildTestPin(id: 3),
    ];
    await tester.pumpWidget(_buildPage(pins: pins));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.location_on), findsNWidgets(3));
  });

  testWidgets('左スワイプ後に削除を確定すると deletePin が呼ばれる', (tester) async {
    final repo = MockRipository(stubbedPins: [buildTestPin(id: 42)]);
    await tester.pumpWidget(_buildPage(repo: repo));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('削除'));
    await tester.pumpAndSettle();

    expect(repo.deletedIds, contains(42));
  });

  testWidgets('メモがある場合、メモのテキストが表示される', (tester) async {
    final pin = buildTestPin(id: 1, memo: Memo('ドライブメモ'));
    await tester.pumpWidget(_buildPage(pins: [pin]));
    await tester.pumpAndSettle();

    expect(find.text('ドライブメモ'), findsOneWidget);
  });

  testWidgets('メモがない場合、メモのテキストは表示されない', (tester) async {
    await tester.pumpWidget(_buildPage(pins: [buildTestPin()]));
    await tester.pumpAndSettle();

    // 住所は表示されるがメモは無い
    expect(find.text('東京都渋谷区道玄坂'), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
  });

  testWidgets('メモ編集ボタンをタップするとダイアログが表示される', (tester) async {
    await tester.pumpWidget(_buildPage(pins: [buildTestPin(id: 1)]));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_note));
    await tester.pumpAndSettle();

    expect(find.text('メモを編集'), findsOneWidget);
  });

  testWidgets('メモ編集ダイアログで保存すると updateMemo が呼ばれる', (tester) async {
    final repo = MockRipository(stubbedPins: [buildTestPin(id: 1)]);
    await tester.pumpWidget(_buildPage(repo: repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_note));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '新しいメモ');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(repo.updatedMemos[1]?.value, '新しいメモ');
  });

  testWidgets('メモ編集ダイアログでキャンセルすると updateMemo は呼ばれない', (tester) async {
    final repo = MockRipository(stubbedPins: [buildTestPin(id: 1)]);
    await tester.pumpWidget(_buildPage(repo: repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_note));
    await tester.pumpAndSettle();

    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();

    expect(repo.updatedMemos, isEmpty);
  });
}
