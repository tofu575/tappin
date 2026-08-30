import 'package:flutter/material.dart';

const _driveModeTitle = 'Drive mode';

/// [onTap]でDrive modeの開始確認を開く、Home下部の入口。
class DriveModeEntry extends StatelessWidget {
  const DriveModeEntry({super.key, required this.onTap});

  final VoidCallback onTap;

  /// Themeのsurface色を使った、画面幅いっぱいのタップ領域を表示する。
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: GestureDetector(
        key: const Key('drive-mode-entry'),
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < -250) onTap();
        },
        child: Material(
          color: colorScheme.surfaceContainer,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_car_rounded,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      _driveModeTitle,
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
