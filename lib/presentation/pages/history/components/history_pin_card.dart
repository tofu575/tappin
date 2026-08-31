import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/models/pin/pin_review_status.dart';
import 'package:tappin/presentation/providers/provider.dart';
import 'package:tappin/presentation/theme/tap_pin_colors_context.dart';

/// 履歴一覧でPinの確認状態・場所・メモと次の行動をまとめて表示する。
class HistoryPinCard extends ConsumerWidget {
  const HistoryPinCard({super.key, required this.pin, required this.onTap});

  final Pin pin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = context.tapPinColors;
    final textTheme = Theme.of(context).textTheme;
    final isUnreviewed = pin.reviewStatus == PinReviewStatus.unreviewed;
    final coordinate = Coordinate(
      latitude: pin.latitude,
      longitude: pin.longitude,
    );
    final address = ref.watch(addressProvider(coordinate)).when(
          loading: () => _coordinateText(coordinate),
          error: (_, _) => _coordinateText(coordinate),
          data: (value) => value,
        );
    final memo = pin.memo?.value ?? '';

    return Card(
      key: ValueKey('history-pin-${pin.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isUnreviewed ? 1 : 0,
      color: isUnreviewed
          ? colors.stickyNote.withValues(alpha: 0.74)
          : colors.reviewedSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: colors.dividerInk, width: 0.8),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isUnreviewed
                        ? Icons.bookmark_outline_rounded
                        : Icons.check_rounded,
                    size: 18,
                    color: isUnreviewed
                        ? colors.ink
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isUnreviewed ? 'あとで見る' : '確認済み',
                    style: textTheme.labelLarge?.copyWith(
                      color: isUnreviewed
                          ? colors.ink
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _dateText(pin.createdAt.value),
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.place_outlined, size: 19, color: colors.ink),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            isUnreviewed ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.notes_rounded,
                    size: 19,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      memo.isEmpty ? 'メモなし' : memo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              if (isUnreviewed) ...[
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '場所を確認する  →',
                    style: textTheme.labelLarge?.copyWith(
                      color: colors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 履歴カード向けに日時を短く整形する。
String _dateText(DateTime value) => '${value.month}/${value.day} '
    '${value.hour.toString().padLeft(2, '0')}:'
    '${value.minute.toString().padLeft(2, '0')}';

/// 住所取得前でも場所を識別できる座標文字列を返す。
String _coordinateText(Coordinate coordinate) =>
    '${coordinate.latitude.value.toStringAsFixed(5)}, '
    '${coordinate.longitude.value.toStringAsFixed(5)}';
