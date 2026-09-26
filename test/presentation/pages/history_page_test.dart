import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:model/model.dart';
import 'package:tappin/presentation/pages/history/history_page.dart';
import 'package:tappin/presentation/pages/pin_detail/pin_detail_page.dart';
import 'package:tappin/presentation/providers/interactor_provider.dart';
import 'package:tappin/presentation/widgets/tap_pin_mark.dart';

import '../../helpers/build_test_interactor.dart';
import '../../helpers/mock_repository.dart';

/// 本番と同じProvider境界で履歴画面を構築する。
Widget _buildPage({List<Pin> pins = const [], MockRipository? repository}) {
  final repo = repository ?? MockRipository(stubbedPins: pins);
  return ProviderScope(
    overrides: [
      interactorProvider.overrideWithValue(
        buildTestInteractor(repository: repo),
      ),
    ],
    child: const MaterialApp(home: HistoryPage()),
  );
}

/// 履歴の状態別表示と詳細へのワークフローを検証する。
void main() {
  testWidgets('記録がない場合は親しみやすい空表示を出す', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pumpAndSettle();

    expect(find.text('まだ記録がありません'), findsOneWidget);
    expect(find.byType(TapPinMark), findsOneWidget);
  });

  testWidgets('未確認カードに日時・場所・メモ状態・次の行動をまとめる', (tester) async {
    await tester.pumpWidget(
      _buildPage(pins: [buildTestPin(memo: Memo('赤い看板の店'))]),
    );
    await tester.pumpAndSettle();

    expect(find.text('あとで確認'), findsOneWidget);
    expect(find.text('1/15 10:30'), findsOneWidget);
    expect(find.text('東京都渋谷区道玄坂'), findsOneWidget);
    expect(find.text('赤い看板の店'), findsOneWidget);
    expect(find.text('場所を確認する  →'), findsOneWidget);
    expect(find.byIcon(Icons.map), findsNothing);
    expect(find.byIcon(Icons.edit_note), findsNothing);
  });

  testWidgets('メモがないカードは現在の状態を明示する', (tester) async {
    await tester.pumpWidget(_buildPage(pins: [buildTestPin()]));
    await tester.pumpAndSettle();

    expect(find.text('メモなし'), findsOneWidget);
  });

  testWidgets('確認済みへ切り替えると落ち着いたアーカイブを表示する', (tester) async {
    await tester.pumpWidget(
      _buildPage(
        pins: [
          buildTestPin(
            reviewStatus: PinReviewStatus.reviewed,
            memo: Memo('確認した場所'),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('確認済み'), findsWidgets);
    expect(find.text('確認した場所'), findsOneWidget);
    expect(find.text('場所を確認する  →'), findsNothing);
  });

  testWidgets('カード全体をタップすると記録詳細へ遷移する', (tester) async {
    await tester.pumpWidget(_buildPage(pins: [buildTestPin()]));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('history-pin-1')));
    await tester.pumpAndSettle();

    expect(find.byType(PinDetailPage), findsOneWidget);
    expect(find.text('Google Mapsで確認'), findsOneWidget);
    expect(find.text('確認済みにする'), findsOneWidget);
  });

  testWidgets('詳細で確認済みにするを押すと明示的な確認状態を保存する', (tester) async {
    final repository = MockRipository(stubbedPins: [buildTestPin(id: 42)]);
    await tester.pumpWidget(_buildPage(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('history-pin-42')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('mark-pin-reviewed')));
    await tester.pumpAndSettle();

    expect(repository.updatedReviewStatuses[42], PinReviewStatus.reviewed);
    expect(find.text('確認済み'), findsWidgets);
  });

  testWidgets('メモ編集は一覧ではなく詳細から行う', (tester) async {
    final repository = MockRipository(stubbedPins: [buildTestPin(id: 7)]);
    await tester.pumpWidget(_buildPage(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('history-pin-7')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('edit-pin-memo')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'あとで分かったこと');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(repository.updatedMemos[7]?.value, 'あとで分かったこと');
  });
}
