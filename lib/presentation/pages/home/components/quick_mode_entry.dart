import 'package:flutter/material.dart';

import 'package:tappin/presentation/theme/tap_pin_colors_context.dart';

const _quickModeTitle = 'Quick Mode';

/// [onTap]でQuick Modeの開始確認を開く、Home下端から覗く入口。
class QuickModeEntry extends StatelessWidget {
  const QuickModeEntry({super.key, required this.onTap});

  final VoidCallback onTap;

  /// Themeのsurface色を使った、画面幅いっぱいのタップ領域を表示する。
  @override
  Widget build(BuildContext context) {
    final colors = context.tapPinColors;
    return SafeArea(
      top: false,
      child: GestureDetector(
        key: const Key('quick-mode-entry'),
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < -250) onTap();
        },
        child: Material(
          color: colors.quickModeSurface,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
                children: [
                  Icon(Icons.route_rounded, color: colors.quickModeInk),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      _quickModeTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
