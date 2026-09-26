import 'package:flutter/material.dart';

import 'package:tappin/presentation/assets/tap_pin_visual_assets.dart';
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
    final disabled = state == TapPinMarkState.disabled;
    final active =
        state == TapPinMarkState.recording || state == TapPinMarkState.success;
    final fill = fillProgress.clamp(0.0, 1.0);
    final pin = TapPinVisualAssets.brandPin(size: size);

    if (disabled) return Opacity(opacity: 0.35, child: pin);
    if (!active || fill >= 1) return pin;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: 0.2, child: TapPinVisualAssets.brandPin(size: size)),
          if (fill > 0)
            ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: fill,
                child: TapPinVisualAssets.brandPin(size: size),
              ),
            ),
        ],
      ),
    );
  }
}
