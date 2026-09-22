import 'package:flutter/material.dart';

import 'package:tappin/presentation/theme/tap_pin_colors_context.dart';

/// 紙色と控えめな罫線を全画面へ一括適用できる背景Widget。
class PaperBackground extends StatelessWidget {
  const PaperBackground(
      {super.key, required this.child, this.showRules = true});

  final Widget child;
  final bool showRules;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.tapPinColors.paper,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showRules)
            IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) => Stack(
                  children: [
                    for (var top = 44.0; top < constraints.maxHeight; top += 36)
                      Positioned(
                        top: top,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          height: 0.6,
                          child: ColoredBox(
                            color: context.tapPinColors.dividerInk.withValues(
                              alpha: 0.18,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}
