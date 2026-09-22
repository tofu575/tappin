import 'package:flutter/material.dart';

const tapPinLightColors = TapPinColors(
  paper: Color(0xFFFAF7EF),
  paperElevated: Color(0xFFFFFDF8),
  ink: Color(0xFF20313A),
  pinRed: Color(0xFFC84B3F),
  pinRedSoft: Color(0xFFF4D5CE),
  stickyNote: Color(0xFFF4E6AD),
  reviewedSurface: Color(0xFFEDE9DE),
  quickModeSurface: Color(0xFFDCE5E3),
  quickModeInk: Color(0xFF183D43),
  dividerInk: Color(0xFFB7B5AA),
);

/// TapPin固有の紙・インク・画鋲・付箋の色をThemeへ提供する。
@immutable
class TapPinColors extends ThemeExtension<TapPinColors> {
  const TapPinColors({
    required this.paper,
    required this.paperElevated,
    required this.ink,
    required this.pinRed,
    required this.pinRedSoft,
    required this.stickyNote,
    required this.reviewedSurface,
    required this.quickModeSurface,
    required this.quickModeInk,
    required this.dividerInk,
  });

  final Color paper;
  final Color paperElevated;
  final Color ink;
  final Color pinRed;
  final Color pinRedSoft;
  final Color stickyNote;
  final Color reviewedSurface;
  final Color quickModeSurface;
  final Color quickModeInk;
  final Color dividerInk;

  @override
  TapPinColors copyWith({
    Color? paper,
    Color? paperElevated,
    Color? ink,
    Color? pinRed,
    Color? pinRedSoft,
    Color? stickyNote,
    Color? reviewedSurface,
    Color? quickModeSurface,
    Color? quickModeInk,
    Color? dividerInk,
  }) =>
      TapPinColors(
        paper: paper ?? this.paper,
        paperElevated: paperElevated ?? this.paperElevated,
        ink: ink ?? this.ink,
        pinRed: pinRed ?? this.pinRed,
        pinRedSoft: pinRedSoft ?? this.pinRedSoft,
        stickyNote: stickyNote ?? this.stickyNote,
        reviewedSurface: reviewedSurface ?? this.reviewedSurface,
        quickModeSurface: quickModeSurface ?? this.quickModeSurface,
        quickModeInk: quickModeInk ?? this.quickModeInk,
        dividerInk: dividerInk ?? this.dividerInk,
      );

  @override
  TapPinColors lerp(covariant TapPinColors? other, double t) {
    if (other == null) return this;
    return TapPinColors(
      paper: Color.lerp(paper, other.paper, t)!,
      paperElevated: Color.lerp(paperElevated, other.paperElevated, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      pinRed: Color.lerp(pinRed, other.pinRed, t)!,
      pinRedSoft: Color.lerp(pinRedSoft, other.pinRedSoft, t)!,
      stickyNote: Color.lerp(stickyNote, other.stickyNote, t)!,
      reviewedSurface: Color.lerp(
        reviewedSurface,
        other.reviewedSurface,
        t,
      )!,
      quickModeSurface: Color.lerp(
        quickModeSurface,
        other.quickModeSurface,
        t,
      )!,
      quickModeInk: Color.lerp(quickModeInk, other.quickModeInk, t)!,
      dividerInk: Color.lerp(dividerInk, other.dividerInk, t)!,
    );
  }
}
