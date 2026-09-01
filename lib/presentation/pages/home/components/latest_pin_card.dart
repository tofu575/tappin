import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:model/model.dart';
import 'package:tappin/presentation/providers/provider.dart';
import 'package:tappin/presentation/localization/app_localizations_context.dart';
import 'package:tappin/presentation/theme/tap_pin_colors_context.dart';

/// Homeで直前に預けた場所を短く表示する。
class LatestPinCard extends ConsumerWidget {
  const LatestPinCard({super.key, required this.pin});

  final Pin pin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordinate = Coordinate(
      latitude: pin.latitude,
      longitude: pin.longitude,
    );
    final address = ref
        .watch(addressProvider(coordinate))
        .when(
          loading: () => context.l10n.checkingPlace,
          error: (_, _) => context.l10n.coordinateRecorded,
          data: (value) => value,
        );
    final colors = context.tapPinColors;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.pinRedSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.pinRed.withValues(alpha: 0.32)),
      ),
      child: Row(
        children: [
          Icon(Icons.push_pin_rounded, color: colors.pinRed, size: 25),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.justPinned,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(address, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
