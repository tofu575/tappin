import 'package:flutter/material.dart';

/// Home右端から覗き、履歴と穏やかな未確認件数を示すインデックスタブ。
class HistoryIndexTab extends StatelessWidget {
  const HistoryIndexTab({
    super.key,
    required this.unreviewedCount,
    required this.onTap,
  });

  final int unreviewedCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      key: const Key('history-index-tab'),
      color: unreviewedCount > 0
          ? colorScheme.tertiaryContainer
          : colorScheme.surfaceContainerHigh,
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 92,
          height: 58,
          child: Center(
            child: Text(
              unreviewedCount > 0 ? '未確認 $unreviewedCount' : '履歴',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: unreviewedCount > 0
                    ? colorScheme.onTertiaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
