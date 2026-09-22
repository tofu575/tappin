import 'package:flutter/material.dart';

import 'package:tappin/presentation/theme/tap_pin_colors.dart';

const _gothicFontFamily = 'sans-serif';
const _gothicFontFallback = <String>[
  'Noto Sans JP',
  'Hiragino Sans',
  'Yu Gothic',
  'Meiryo',
];

/// 画鋲と現代的なフィールドノートを表すアプリThemeを構築する。
ThemeData buildTapPinTheme() {
  const colors = tapPinLightColors;
  final scheme = ColorScheme.light(
    primary: colors.ink,
    onPrimary: Color(0xFFFFFDF8),
    primaryContainer: colors.pinRedSoft,
    onPrimaryContainer: colors.ink,
    secondary: Color(0xFF526B64),
    onSecondary: Color(0xFFFFFDF8),
    secondaryContainer: colors.quickModeSurface,
    onSecondaryContainer: colors.quickModeInk,
    tertiary: Color(0xFF856F28),
    onTertiary: Color(0xFFFFFDF8),
    tertiaryContainer: colors.stickyNote,
    onTertiaryContainer: colors.ink,
    error: Color(0xFFA53A35),
    onError: Color(0xFFFFFFFF),
    surface: colors.paper,
    onSurface: colors.ink,
    onSurfaceVariant: Color(0xFF657076),
    outline: Color(0xFF777D7E),
    outlineVariant: colors.dividerInk,
  );

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.paper,
    useMaterial3: true,
    fontFamily: _gothicFontFamily,
    fontFamilyFallback: _gothicFontFallback,
    extensions: const [colors],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: colors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: colors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        fontFamily: _gothicFontFamily,
        fontFamilyFallback: _gothicFontFallback,
      ),
    ),
    cardTheme: CardThemeData(
      color: colors.paperElevated,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.dividerInk, width: 0.8),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.ink,
        foregroundColor: colors.paperElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.ink,
        side: BorderSide(color: colors.dividerInk),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    dividerTheme: DividerThemeData(color: colors.dividerInk),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.paperElevated,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
