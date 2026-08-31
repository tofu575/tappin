import 'package:flutter/material.dart';

import 'package:tappin/presentation/theme/tap_pin_colors_context.dart';
import 'package:tappin/presentation/widgets/tap_pin_mark_state.dart';

/// 画面を跨いで同じブランド画鋲を状態付きで表示する。
class TapPinMark extends StatelessWidget {
  const TapPinMark({
    super.key,
    this.state = TapPinMarkState.idle,
    this.size = 72,
    this.fillProgress = 1,
  });

  final TapPinMarkState state;
  final double size;
  final double fillProgress;

  @override
  Widget build(BuildContext context) {
    final colors = context.tapPinColors;
    final disabled = state == TapPinMarkState.disabled;
    final active =
        state == TapPinMarkState.recording || state == TapPinMarkState.success;
    final fill = fillProgress.clamp(0.0, 1.0);
    final outlineColor = disabled
        ? colors.dividerInk
        : active
            ? colors.pinRed
            : colors.ink;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.push_pin_outlined, size: size, color: outlineColor),
          if (!disabled && fill > 0)
            ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: fill,
                child: Icon(
                  Icons.push_pin_rounded,
                  size: size,
                  color: colors.pinRed,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
