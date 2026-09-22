import 'package:flutter/material.dart';

import 'package:tappin/presentation/theme/tap_pin_colors.dart';

/// 現在のThemeからTapPin固有の色を取得する。
extension TapPinColorsContext on BuildContext {
  TapPinColors get tapPinColors =>
      Theme.of(this).extension<TapPinColors>() ?? tapPinLightColors;
}
