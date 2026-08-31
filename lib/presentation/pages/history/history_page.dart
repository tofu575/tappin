import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tappin/domain/models/pin/pin_review_status.dart';
import 'package:tappin/presentation/pages/history/components/history_pin_card.dart';
import 'package:tappin/presentation/pages/pin_detail/pin_detail_page.dart';
import 'package:tappin/presentation/providers/provider.dart';

/// あとで確認するPinと確認済みのアーカイブを状態別に表示する。
class HistoryPage extends HookConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStatus = useState<PinReviewStatus?>(null);
    final pinsAsync = ref.watch(pinsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('記録をふりかえる')),
      body: pinsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('記録を読み込めませんでした\n$error')),
        data: (pins) {
          if (pins.isEmpty) return _noPinsState(context);
          final unreviewed = pins
              .where((pin) => pin.reviewStatus == PinReviewStatus.unreviewed)
              .toList();
          final reviewed = pins
              .where((pin) => pin.reviewStatus == PinReviewStatus.reviewed)
              .toList();
          final currentStatus =
              selectedStatus.value ??
              (unreviewed.isNotEmpty
                  ? PinReviewStatus.unreviewed
                  : PinReviewStatus.reviewed);
          final visiblePins = currentStatus == PinReviewStatus.unreviewed
              ? unreviewed
              : reviewed;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                child: Text(
                  '気になった場所を、ひとつずつ確かめよう。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<PinReviewStatus>(
                  key: const Key('history-status-filter'),
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: PinReviewStatus.unreviewed,
                      label: Text('👀 未確認  ${unreviewed.length}'),
                    ),
                    ButtonSegment(
                      value: PinReviewStatus.reviewed,
                      label: Text('✓ 確認済み  ${reviewed.length}'),
                    ),
                  ],
                  selected: {currentStatus},
                  onSelectionChanged: (selection) {
                    selectedStatus.value = selection.first;
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: visiblePins.isEmpty
                    ? _emptyState(context, currentStatus)
                    : ListView.builder(
                        key: ValueKey(currentStatus),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: visiblePins.length,
                        itemBuilder: (context, index) {
                          final pin = visiblePins[index];
                          return HistoryPinCard(
                            pin: pin,
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => PinDetailPage(pin: pin),
                                ),
                              );
                              ref.invalidate(pinsProvider);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 記録そのものがまだない場合の空表示を返す。
Widget _noPinsState(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📍', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(
            'まだ記録がありません',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'ホームから、気になった場所を預けてみましょう。',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}

/// 選択中の確認状態に応じた穏やかな空表示を返す。
Widget _emptyState(BuildContext context, PinReviewStatus status) {
  final isUnreviewed = status == PinReviewStatus.unreviewed;
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isUnreviewed ? '🌿' : '📚',
            style: const TextStyle(fontSize: 52),
          ),
          const SizedBox(height: 16),
          Text(
            isUnreviewed ? 'いま確認する記録はありません' : '確認済みの記録はまだありません',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            isUnreviewed ? '気になった場所は、ホームから気軽に預けられます。' : '確認を終えた記録がここに残ります。',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}
