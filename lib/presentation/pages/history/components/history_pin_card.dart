import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/models/pin/pin_review_status.dart';
import 'package:tappin/presentation/providers/provider.dart';

/// 履歴一覧でPinの確認状態・場所・メモと次の行動をまとめて表示する。
class HistoryPinCard extends ConsumerWidget {
  const HistoryPinCard({super.key, required this.pin, required this.onTap});

  final Pin pin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isUnreviewed = pin.reviewStatus == PinReviewStatus.unreviewed;
    final coordinate = Coordinate(
      latitude: pin.latitude,
      longitude: pin.longitude,
    );
    final address = ref
        .watch(addressProvider(coordinate))
        .when(
          loading: () => _coordinateText(coordinate),
          error: (_, _) => _coordinateText(coordinate),
          data: (value) => value,
        );
    final memo = pin.memo?.value ?? '';

    return Card(
      key: ValueKey('history-pin-${pin.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isUnreviewed ? 2 : 0,
      color: isUnreviewed
          ? colorScheme.primaryContainer.withValues(alpha: 0.46)
          : colorScheme.surfaceContainerLow,
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
                  Text(
                    isUnreviewed ? '👀 あとで見る' : '✓ 確認済み',
                    style: textTheme.labelLarge?.copyWith(
                      color: isUnreviewed
                          ? colorScheme.primary
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
                  const Text('📍', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: isUnreviewed
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('📝', style: TextStyle(fontSize: 17)),
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
                      color: colorScheme.primary,
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
String _dateText(DateTime value) =>
    '${value.month}/${value.day} '
    '${value.hour.toString().padLeft(2, '0')}:'
    '${value.minute.toString().padLeft(2, '0')}';

/// 住所取得前でも場所を識別できる座標文字列を返す。
String _coordinateText(Coordinate coordinate) =>
    '${coordinate.latitude.value.toStringAsFixed(5)}, '
    '${coordinate.longitude.value.toStringAsFixed(5)}';
