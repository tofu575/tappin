import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/services/external_map_destination.dart';
import 'package:tappin/presentation/providers/interactor_provider.dart';

const _externalMapErrorMessage = '地図アプリを開けませんでした';

/// [coordinate]を外部の地図アプリで調べる目的が分かる導線を表示する。
class MapLaunchButtons extends ConsumerWidget {
  const MapLaunchButtons({super.key, required this.coordinate});

  final Coordinate coordinate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> open(ExternalMapDestination destination) async {
      try {
        await ref
            .read(interactorProvider)
            .openExternalMap(coordinate, destination);
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(_externalMapErrorMessage)));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          key: const Key('open-google-maps'),
          icon: const Icon(Icons.open_in_new_rounded),
          label: const Text('Google Mapsで場所を確認'),
          onPressed: () => open(ExternalMapDestination.map),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const Key('open-street-view'),
          icon: const Icon(Icons.explore_outlined),
          label: const Text('ストリートビューで周辺を見る'),
          onPressed: () => open(ExternalMapDestination.streetView),
        ),
      ],
    );
  }
}
