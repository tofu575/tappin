import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tappin/presentation/providers/provider.dart';

class ListPage extends ConsumerWidget {
  const ListPage({super.key});

  Future<void> _openGoogleMaps(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openStreetView(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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
            itemBuilder: (context, index) {
              final pin = pins[index];
              final lat = pin.latitude.value;
              final lng = pin.longitude.value;
              final dateStr =
                  '${pin.createdAt.value.year}/${pin.createdAt.value.month.toString().padLeft(2, '0')}/${pin.createdAt.value.day.toString().padLeft(2, '0')} '
                  '${pin.createdAt.value.hour.toString().padLeft(2, '0')}:${pin.createdAt.value.minute.toString().padLeft(2, '0')}';
              return ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(dateStr),
                subtitle: Text(
                  '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.map),
                      tooltip: 'Google Maps',
                      onPressed: () => _openGoogleMaps(lat, lng),
                    ),
                    IconButton(
                      icon: const Icon(Icons.streetview),
                      tooltip: 'ストリートビュー',
                      onPressed: () => _openStreetView(lat, lng),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: '削除',
                      onPressed: () async {
                        if (pin.id != null) {
                          await ref
                              .read(pinsProvider.notifier)
                              .deletePin(pin.id!);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
