import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/models/pin/memo.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/presentation/providers/provider.dart';
import 'package:tappin/presentation/widgets/map_launch_buttons.dart';
import 'package:tappin/presentation/widgets/memo_edit_dialog.dart';

class ListPage extends ConsumerWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinsAsync = ref.watch(pinsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('記録一覧')),
      body: pinsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (pins) {
          if (pins.isEmpty) {
            return const Center(child: Text('記録がありません'));
          }
          return ListView.builder(
            itemCount: pins.length,
            itemBuilder: (context, index) => _PinListItem(pin: pins[index]),
          );
        },
      ),
    );
  }
}

class _PinListItem extends ConsumerWidget {
  const _PinListItem({required this.pin});

  final Pin pin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordinate = Coordinate(
      latitude: pin.latitude,
      longitude: pin.longitude,
    );
    final dateStr =
        '${pin.createdAt.value.year}/${pin.createdAt.value.month.toString().padLeft(2, '0')}/${pin.createdAt.value.day.toString().padLeft(2, '0')} '
        '${pin.createdAt.value.hour.toString().padLeft(2, '0')}:${pin.createdAt.value.minute.toString().padLeft(2, '0')}';

    final addressAsync = ref.watch(addressProvider(coordinate));
    final addressText = addressAsync.when(
      loading: () => '${coordinate.latitude.value.toStringAsFixed(6)}, ${coordinate.longitude.value.toStringAsFixed(6)}',
      error: (e, _) => '${coordinate.latitude.value.toStringAsFixed(6)}, ${coordinate.longitude.value.toStringAsFixed(6)}',
      data: (address) => address,
    );

    return ListTile(
      leading: const Icon(Icons.location_on),
      title: Text(dateStr),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(addressText),
          if (pin.memo != null)
            Text(
              pin.memo!.value,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MapLaunchButtons(coordinate: coordinate),
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'メモを編集',
            onPressed: () async {
              final result = await showDialog<String>(
                context: context,
                builder: (_) => MemoEditDialog(
                  initialText: pin.memo?.value ?? '$dateStr $addressText',
                ),
              );
              if (result != null && pin.id != null) {
                ref.read(pinsProvider.notifier).updateMemo(pin.id!, Memo(result));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: '削除',
            onPressed: () async {
              if (pin.id != null) {
                await ref.read(pinsProvider.notifier).deletePin(pin.id!);
              }
            },
          ),
        ],
      ),
    );
  }
}
