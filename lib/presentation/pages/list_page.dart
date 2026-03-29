import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/presentation/providers/provider.dart';

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

  Future<void> _openGoogleMaps(Coordinate coordinate) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${coordinate.latitude.value},${coordinate.longitude.value}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openStreetView(Coordinate coordinate) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=${coordinate.latitude.value},${coordinate.longitude.value}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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
    final subtitleText = addressAsync.when(
      loading: () => '${coordinate.latitude.value.toStringAsFixed(6)}, ${coordinate.longitude.value.toStringAsFixed(6)}',
      error: (e, _) => '${coordinate.latitude.value.toStringAsFixed(6)}, ${coordinate.longitude.value.toStringAsFixed(6)}',
      data: (address) => address,
    );

    return ListTile(
      leading: const Icon(Icons.location_on),
      title: Text(dateStr),
      subtitle: Text(subtitleText),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'Google Maps',
            onPressed: () => _openGoogleMaps(coordinate),
          ),
          IconButton(
            icon: const Icon(Icons.streetview),
            tooltip: 'ストリートビュー',
            onPressed: () => _openStreetView(coordinate),
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
