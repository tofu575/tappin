import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/services/external_map_destination.dart';
import 'package:tappin/presentation/providers/interactor_provider.dart';

const _externalMapErrorMessage = '地図アプリを開けませんでした';

/// [coordinate]を外部地図またはStreet Viewで開く操作を表示する。
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.map),
          tooltip: 'Google Maps',
          onPressed: () => open(ExternalMapDestination.map),
        ),
        IconButton(
          icon: const Icon(Icons.streetview),
          tooltip: 'ストリートビュー',
          onPressed: () => open(ExternalMapDestination.streetView),
        ),
      ],
    );
  }
}
