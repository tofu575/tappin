import 'package:flutter/material.dart';

import 'package:tappin/presentation/assets/onboarding_visual.dart';
import 'package:tappin/presentation/pages/quick_mode/quick_mode_character.dart';
import 'package:tappin/presentation/theme/tap_pin_colors_context.dart';
import 'package:tappin/presentation/widgets/tap_pin_mark.dart';

/// 未完成のブランド素材をPlaceholderから本番Assetへ交換する唯一の窓口。
class TapPinVisualAssets {
  const TapPinVisualAssets._();

  /// ブランド画鋲の現在のPlaceholderを返す。
  static Widget brandPin({double size = 72}) => TapPinMark(size: size);

  /// 移動キャラクター識別子を現在のEmoji Placeholderへ変換する。
  static Widget movementCharacter(
    QuickModeCharacter character, {
    double size = 30,
    Key? key,
  }) {
    final emoji = _movementEmoji(character);
    return Text(emoji, key: key, style: TextStyle(fontSize: size));
  }

  /// オンボーディング識別子を統一されたIconまたはブランド画鋲へ変換する。
  static Widget onboarding(
    BuildContext context,
    OnboardingVisual visual, {
    double size = 58,
  }) {
    if (visual == OnboardingVisual.pin) return brandPin(size: size);
    final icon = _onboardingIcon(visual);
    return Icon(icon, size: size, color: context.tapPinColors.ink);
  }

  /// 移動識別子へ対応する暫定EmojiだけをAsset境界内で返す。
  static String _movementEmoji(QuickModeCharacter character) {
    switch (character) {
      case QuickModeCharacter.car:
        return '🚗';
      case QuickModeCharacter.bus:
        return '🚌';
      case QuickModeCharacter.train:
        return '🚃';
      case QuickModeCharacter.bicycle:
        return '🚲';
      case QuickModeCharacter.walking:
        return '🚶';
    }
  }

  /// 案内識別子へ対応する暫定Material IconをAsset境界内で返す。
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
}
