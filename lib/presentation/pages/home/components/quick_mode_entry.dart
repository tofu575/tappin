import 'package:flutter/material.dart';

import 'package:tappin/presentation/theme/tap_pin_colors_context.dart';
import 'package:tappin/presentation/localization/app_localizations_context.dart';

/// [onTap]でQuick Modeの開始確認を開く、Home下端から覗く入口。
class QuickModeEntry extends StatelessWidget {
  const QuickModeEntry({super.key, required this.onTap});

  final VoidCallback onTap;

  /// Themeのsurface色を使った、画面幅いっぱいのタップ領域を表示する。
  @override
  Widget build(BuildContext context) {
    final colors = context.tapPinColors;
    return Material(
      color: colors.quickModeSurface,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        side: BorderSide(color: colors.dividerInk),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: GestureDetector(
          key: const Key('quick-mode-entry'),
          behavior: HitTestBehavior.opaque,
          onVerticalDragEnd: (details) {
            if ((details.primaryVelocity ?? 0) < -250) onTap();
          },
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.quickModeInk.withValues(alpha: 0.36),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.route_rounded, color: colors.quickModeInk),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          context.l10n.quickMode,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_up_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
