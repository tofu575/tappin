import 'dart:math';

/// Quick Modeセッション中に一貫して表示する移動キャラクター。
enum QuickModeCharacter {
  car,
  bus,
  bicycle,
  walking;

  /// セッション開始時にキャラクターを1種類だけ選ぶ。
  static QuickModeCharacter selectRandom() {
    return values[Random().nextInt(values.length)];
  }
}
