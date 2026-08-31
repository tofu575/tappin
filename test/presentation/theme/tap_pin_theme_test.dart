import 'package:flutter_test/flutter_test.dart';

import 'package:tappin/presentation/theme/tap_pin_theme.dart';

/// アプリ共通Themeがゴシック系フォントを全Textへ適用することを検証する。
void main() {
  test('本文とAppBar見出しへ共通のゴシック系フォントを設定する', () {
    final theme = buildTapPinTheme();

    expect(theme.textTheme.bodyMedium?.fontFamily, 'sans-serif');
    expect(theme.textTheme.bodyMedium?.fontFamilyFallback,
        contains('Noto Sans JP'));
    expect(theme.appBarTheme.titleTextStyle?.fontFamily, 'sans-serif');
    expect(
      theme.appBarTheme.titleTextStyle?.fontFamilyFallback,
      contains('Hiragino Sans'),
    );
  });
}
