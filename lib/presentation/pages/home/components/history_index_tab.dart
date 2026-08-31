import 'package:flutter/material.dart';

import 'package:tappin/presentation/theme/tap_pin_colors_context.dart';
import 'package:tappin/presentation/localization/app_localizations_context.dart';

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
    final colors = context.tapPinColors;
    return Material(
      key: const Key('history-index-tab'),
      color: unreviewedCount > 0 ? colors.stickyNote : colors.paperElevated,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(7)),
        side: BorderSide(color: colors.dividerInk),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 86,
          height: 64,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bookmarks_outlined,
                  size: 18,
                  color: colors.ink,
                ),
                const SizedBox(height: 3),
                Text(
                  unreviewedCount > 0
                      ? context.l10n.unreviewedCountCompact(unreviewedCount)
                      : context.l10n.history,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
