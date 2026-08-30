import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/presentation/pages/drive_mode/drive_mode_page.dart';
import 'package:tappin/presentation/pages/drive_mode/drive_mode_transition_page.dart';
import 'package:tappin/presentation/pages/drive_mode/drive_transition_direction.dart';
import 'package:tappin/presentation/pages/home/components/drive_mode_entry.dart';
import 'package:tappin/presentation/pages/list_page.dart';
import 'package:tappin/presentation/pages/map_page.dart';
import 'package:tappin/presentation/providers/interactor_provider.dart';
import 'package:tappin/presentation/providers/provider.dart';
import 'package:tappin/presentation/providers/recording_provider.dart';
import 'package:tappin/presentation/widgets/record_action.dart';
import 'package:tappin/presentation/widgets/record_button.dart';
import 'package:tappin/presentation/widgets/record_feedback.dart';
import 'package:tappin/presentation/widgets/record_feedback_controller.dart';

const _overlayActivateErrorPrefix = 'オーバーレイエラー: ';
const _driveModeTitle = 'Drive mode';
const _driveModeDescription = 'Drive modeでは、画面全体が記録ボタンになります。';

/// 通常の記録操作とDrive modeへの入口を表示するHome画面。
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverlayActive = useState(false);
    final latestPin = useState<Pin?>(null);
    final feedbackController = useMemoized(RecordFeedbackController.new);

    useEffect(() {
      unawaited(ref.read(interactorProvider).warmUpLocation());
      return null;
    }, const []);

    Future<void> showOverlay() async {
      try {
        await ref.read(interactorProvider).showOverlay();
        if (context.mounted) isOverlayActive.value = true;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$_overlayActivateErrorPrefix$e')),
          );
        }
      }
    }

    useOnAppLifecycleStateChange((_, current) {
      if (current == AppLifecycleState.resumed) {
        ref.invalidate(pinsProvider);
        if (isOverlayActive.value) showOverlay();
      }
    });

    Future<void> toggleOverlay() async {
      if (isOverlayActive.value) {
        await ref.read(interactorProvider).hideOverlay();
        isOverlayActive.value = false;
      } else {
        await showOverlay();
      }
    }

    Future<void> openDriveMode() async {
      final shouldStart = await showModalBottomSheet<bool>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.directions_car_rounded,
                  size: 48,
                  color: Theme.of(sheetContext).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  _driveModeTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(sheetContext).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(_driveModeDescription, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('start-drive-mode'),
                  onPressed: () => Navigator.pop(sheetContext, true),
                  child: const Text('開始する'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext, false),
                  child: const Text('キャンセル'),
                ),
              ],
            ),
          ),
        ),
      );
      if (shouldStart != true || !context.mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => DriveModeTransitionPage(
            direction: DriveTransitionDirection.entering,
            onCompleted: (transitionContext) {
              Navigator.of(transitionContext).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const DriveModePage()),
              );
            },
          ),
        ),
      );
    }

    Future<void> recordCurrentLocation() async {
      await performRecordAction(
        context: context,
        ref: ref,
        feedbackController: feedbackController,
        onSuccess: (pin) => latestPin.value = pin,
      );
    }

    final isRecording = ref.watch(recordingProvider).isLoading;
    final Pin? currentLatestPin = latestPin.value;
    final Widget? latestPinCard;
    if (currentLatestPin == null) {
      latestPinCard = null;
    } else {
      latestPinCard = _LatestPinCard(pin: currentLatestPin);
    }

    return RecordFeedback(
      controller: feedbackController,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TapPin'),
          actions: [
            IconButton(
              icon: Icon(
                Icons.picture_in_picture,
                color: isOverlayActive.value
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              onPressed: toggleOverlay,
            ),
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapPage()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ListPage()),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: RecordButton(
                  onPressed: recordCurrentLocation,
                  isLoading: isRecording,
                ),
              ),
            ),
            ?latestPinCard,
            DriveModeEntry(onTap: openDriveMode),
          ],
        ),
      ),
    );
  }
}

/// 直近に記録した位置と時刻を表示するカード。
class _LatestPinCard extends ConsumerWidget {
  const _LatestPinCard({required this.pin});

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
      loading: () => '読み込み中...',
      error: (e, _) =>
          '${coordinate.latitude.value.toStringAsFixed(6)}, ${coordinate.longitude.value.toStringAsFixed(6)}',
      data: (address) => address,
    );

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on,
                color: colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    addressText,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.check_circle, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
