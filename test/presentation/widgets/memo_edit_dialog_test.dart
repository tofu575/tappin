import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tappin/presentation/widgets/memo_edit_dialog.dart';

Widget _buildLauncher({
  required String initialText,
  void Function(String?)? onResult,
}) {
  return MaterialApp(
    home: Builder(
      builder: (context) => TextButton(
        onPressed: () async {
          final result = await showDialog<String>(
            context: context,
            builder: (_) => MemoEditDialog(initialText: initialText),
          );
          onResult?.call(result);
        },
        child: const Text('open'),
      ),
    ),
  );
}

void main() {
  testWidgets('ダイアログタイトル「メモを編集」が表示される', (tester) async {
    await tester.pumpWidget(_buildLauncher(initialText: ''));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('メモを編集'), findsOneWidget);
  });

  testWidgets('初期テキストが TextField に設定される', (tester) async {
    await tester.pumpWidget(_buildLauncher(initialText: '初期テキスト'));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, '初期テキスト'), findsOneWidget);
  });

  testWidgets('保存ボタンをタップすると初期テキストが返る', (tester) async {
    String? result;
    await tester.pumpWidget(_buildLauncher(
      initialText: '保存テキスト',
      onResult: (v) => result = v,
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(result, '保存テキスト');
  });

  testWidgets('テキストを変更して保存すると変更後のテキストが返る', (tester) async {
    String? result;
    await tester.pumpWidget(_buildLauncher(
      initialText: '',
      onResult: (v) => result = v,
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '新しいメモ');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(result, '新しいメモ');
  });

  testWidgets('キャンセルをタップするとダイアログが閉じる', (tester) async {
    await tester.pumpWidget(_buildLauncher(initialText: 'テキスト'));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();

    expect(find.text('メモを編集'), findsNothing);
  });

  testWidgets('キャンセルをタップすると null が返る', (tester) async {
    String? result = 'unchanged';
    await tester.pumpWidget(_buildLauncher(
      initialText: 'テキスト',
      onResult: (v) => result = v,
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}
