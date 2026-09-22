import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:model/model.dart';
import 'package:usecase/usecase.dart';
import 'package:tappin/presentation/providers/interactor_provider.dart';
import 'package:tappin/presentation/localization/app_localizations_context.dart';

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
        ).showSnackBar(SnackBar(content: Text(context.l10n.externalMapError)));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          key: const Key('open-google-maps'),
          icon: const Icon(Icons.open_in_new_rounded),
          label: Text(context.l10n.googleMapsAction),
          onPressed: () => open(ExternalMapDestination.map),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const Key('open-street-view'),
          icon: const Icon(Icons.explore_outlined),
          label: Text(context.l10n.streetViewAction),
          onPressed: () => open(ExternalMapDestination.streetView),
        ),
      ],
    );
  }
}
