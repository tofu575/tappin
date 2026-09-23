import 'package:flutter/material.dart';

import 'package:tappin/presentation/assets/onboarding_visual.dart';
import 'package:tappin/presentation/pages/quick_mode/quick_mode_character.dart';
import 'package:tappin/presentation/theme/tap_pin_colors_context.dart';

/// ブランド表示で使う画像Assetを統一的に返す。
class TapPinVisualAssets {
  const TapPinVisualAssets._();

  static const _pinAssetPath = 'assets/images/pin.png';

  /// ブランド画鋲の画像を返す。
  static Widget brandPin({double size = 72}) => _pinImage(size: size);

  /// 移動キャラクター識別子に対応する画像を返す。
  static Widget movementCharacter(
    QuickModeCharacter character, {
    double size = 30,
    Key? key,
  }) => Image.asset(
    _movementAssetPath(character),
    key: key,
    width: size,
    height: size,
    fit: BoxFit.contain,
  );

  /// オンボーディング識別子を案内Iconまたは画鋲画像へ変換する。
  static Widget onboarding(
    BuildContext context,
    OnboardingVisual visual, {
    double size = 58,
  }) {
    if (visual == OnboardingVisual.pin) return brandPin(size: size);
    final icon = _onboardingIcon(visual);
    return Icon(icon, size: size, color: context.tapPinColors.ink);
  }

  /// 移動識別子へ対応するAssetパスを返す。
  static String _movementAssetPath(QuickModeCharacter character) {
    switch (character) {
      case QuickModeCharacter.car:
        return 'assets/images/movement_car.png';
      case QuickModeCharacter.bus:
        return 'assets/images/movement_bus.png';
      case QuickModeCharacter.bicycle:
        return 'assets/images/movement_bicycle.png';
      case QuickModeCharacter.walking:
        return 'assets/images/movement_walking.png';
    }
  }

  /// 案内識別子へ対応するMaterial Iconを返す。
  static IconData _onboardingIcon(OnboardingVisual visual) {
    switch (visual) {
      case OnboardingVisual.pin:
        return Icons.push_pin_rounded;
      case OnboardingVisual.review:
        return Icons.auto_stories_outlined;
      case OnboardingVisual.quickMode:
        return Icons.route_rounded;
      case OnboardingVisual.privacy:
        return Icons.lock_outline_rounded;
    }
  }

  /// 指定サイズで共通の画鋲Assetを読み込む。
  static Widget _pinImage({required double size, Key? key}) => Image.asset(
    _pinAssetPath,
    key: key,
    width: size,
    height: size,
    fit: BoxFit.contain,
  );
}
