import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/models/pin/memo.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/models/pin/pin_review_status.dart';
import 'package:tappin/presentation/localization/app_localizations_context.dart';
import 'package:tappin/presentation/providers/provider.dart';
import 'package:tappin/presentation/widgets/map_launch_buttons.dart';
import 'package:tappin/presentation/widgets/memo_edit_dialog.dart';
import 'package:tappin/presentation/theme/tap_pin_colors_context.dart';
import 'package:tappin/presentation/widgets/paper_background.dart';

/// 1件の記録について場所を調べ、メモと確認状態を更新する画面。
class PinDetailPage extends HookConsumerWidget {
  const PinDetailPage({super.key, required this.pin});

  final Pin pin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPin = useState(pin);
    final isUpdating = useState(false);
    final value = currentPin.value;
    final coordinate = Coordinate(
      latitude: value.latitude,
      longitude: value.longitude,
    );
    final colorScheme = Theme.of(context).colorScheme;
    final colors = context.tapPinColors;
    final textTheme = Theme.of(context).textTheme;
    final address = ref.watch(addressProvider(coordinate)).when(
          loading: () => context.l10n.checkingAddress,
          error: (_, _) => _coordinateText(coordinate),
          data: (result) => result,
        );
    final isUnreviewed = value.reviewStatus == PinReviewStatus.unreviewed;
    final memo = value.memo?.value ?? '';

    Future<void> editMemo() async {
      final result = await showDialog<String>(
        context: context,
        builder: (_) => MemoEditDialog(initialText: memo),
      );
      if (result == null || value.id == null) return;
      final nextMemo = Memo(result);
      await ref.read(pinsProvider.notifier).updateMemo(value.id!, nextMemo);
      currentPin.value = _copyPin(value, memo: nextMemo);
    }

    Future<void> toggleReviewStatus() async {
      final id = value.id;
      if (id == null || isUpdating.value) return;
      isUpdating.value = true;
      final nextStatus =
          isUnreviewed ? PinReviewStatus.reviewed : PinReviewStatus.unreviewed;
      try {
        await ref
            .read(pinsProvider.notifier)
            .updateReviewStatus(id, nextStatus);
        currentPin.value = _copyPin(value, reviewStatus: nextStatus);
      } finally {
        isUpdating.value = false;
      }
    }

    Future<void> deletePin() async {
      final id = value.id;
      if (id == null) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(context.l10n.deletePinTitle),
          content: Text(context.l10n.deletePinDescription),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                context.l10n.delete,
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
      await ref.read(pinsProvider.notifier).deletePin(id);
      if (context.mounted) Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.pinDetailTitle),
        actions: [
          IconButton(
            key: const Key('delete-pin'),
            tooltip: context.l10n.deletePinTooltip,
            onPressed: deletePin,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: PaperBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color:
                    isUnreviewed ? colors.stickyNote : colors.reviewedSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.dividerInk),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUnreviewed
                        ? context.l10n.reviewLaterRecord
                        : context.l10n.reviewed,
                    style: textTheme.labelLarge?.copyWith(
                      color: isUnreviewed
                          ? colors.ink
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.place_outlined, color: colors.ink),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(address, style: textTheme.titleMedium)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _dateText(context, value.createdAt.value),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _coordinateText(coordinate),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.researchPlaceTitle,
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.externalMapDescription,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            MapLaunchButtons(coordinate: coordinate),
            const SizedBox(height: 28),
            Row(
              children: [
                Text(
                  context.l10n.findingsTitle,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  key: const Key('edit-pin-memo'),
                  onPressed: editMemo,
                  child: Text(
                    memo.isEmpty ? context.l10n.addMemo : context.l10n.edit,
                  ),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.paperElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.dividerInk),
              ),
              child: Text(
                memo.isEmpty ? context.l10n.noMemoYet : memo,
                style: textTheme.bodyLarge?.copyWith(
                  color: memo.isEmpty
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (isUnreviewed)
              FilledButton.icon(
                key: const Key('mark-pin-reviewed'),
                onPressed: isUpdating.value ? null : toggleReviewStatus,
                icon: const Icon(Icons.check_rounded),
                label: Text(context.l10n.markReviewed),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              )
            else
              TextButton(
                key: const Key('mark-pin-unreviewed'),
                onPressed: isUpdating.value ? null : toggleReviewStatus,
                child: Text(context.l10n.markUnreviewed),
              ),
          ],
        ),
      ),
    );
  }
}

/// 詳細画面向けに記録日時を整形する。
String _dateText(BuildContext context, DateTime value) =>
    context.l10n.pinRecordedAt(
      value.year.toString(),
      value.month.toString().padLeft(2, '0'),
      value.day.toString().padLeft(2, '0'),
      value.hour.toString().padLeft(2, '0'),
      value.minute.toString().padLeft(2, '0'),
    );

/// 緯度経度を端末表示用の短い文字列へ整形する。
String _coordinateText(Coordinate coordinate) =>
    '${coordinate.latitude.value.toStringAsFixed(6)}, '
    '${coordinate.longitude.value.toStringAsFixed(6)}';

/// 詳細画面のローカル表示用にPinを複製する。
Pin _copyPin(Pin pin, {Memo? memo, PinReviewStatus? reviewStatus}) => Pin(
      id: pin.id,
      latitude: pin.latitude,
      longitude: pin.longitude,
      createdAt: pin.createdAt,
      memo: memo ?? pin.memo,
      reviewStatus: reviewStatus ?? pin.reviewStatus,
    );
