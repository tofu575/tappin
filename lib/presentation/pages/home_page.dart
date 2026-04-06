import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tappin/domain/models/core/my_datetime.dart';
import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/services/location_service.dart';
import 'package:tappin/presentation/pages/list_page.dart';
import 'package:tappin/presentation/pages/map_page.dart';
import 'package:tappin/presentation/providers/provider.dart';
import 'package:tappin/presentation/widgets/record_button.dart';

const _overlayActivateErrorPrefix = 'オーバーレイエラー: ';
const _permissionDeniedMessage = '位置情報が許可されませんでした';
const _permissionPermanentlyDeniedTitle = '位置情報の許可が必要です';
const _permissionPermanentlyDeniedBody = '設定から位置情報へのアクセスを許可してください';
const _permissionOpenSettings = '設定を開く';
const _recordSuccessMessage = '現在地を記録しました';
const _recordErrorPrefix = 'エラーが発生しました: ';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRecording = useState(false);
    final isOverlayActive = useState(false);
    final lastRecordTime = useRef<DateTime?>(null);
    final latestPin = useState<Pin?>(null);
    Future<void> showOverlay() async {
      try {
        await ref.read(overlayServiceProvider).showOverlay();
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
        await ref.read(overlayServiceProvider).hideOverlay();
        isOverlayActive.value = false;
      } else {
        await showOverlay();
      }
    }

    void showPermanentlyDeniedDialog() {
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text(_permissionPermanentlyDeniedTitle),
          content: const Text(_permissionPermanentlyDeniedBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(locationServiceProvider).openSettings();
              },
              child: const Text(_permissionOpenSettings),
            ),
          ],
        ),
      );
    }

    Future<void> recordCurrentLocation() async {
      if (isRecording.value) return;
      final now = DateTime.now();
      if (lastRecordTime.value != null &&
          now.difference(lastRecordTime.value!) < const Duration(milliseconds: 500)) return;
      lastRecordTime.value = now;
      isRecording.value = true;
      try {
        final coordinate = await ref.read(locationServiceProvider).fetchCurrentLocation();
        final pin = Pin(
          latitude: coordinate.latitude,
          longitude: coordinate.longitude,
          createdAt: MyDatetime(DateTime.now()),
        );
        await ref.read(pinsProvider.notifier).savePin(pin);
        if (context.mounted) {
          latestPin.value = pin;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(_recordSuccessMessage)),
          );
        }
      } on LocationPermissionPermanentlyDeniedException {
        if (context.mounted) showPermanentlyDeniedDialog();
      } on LocationPermissionDeniedException {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(_permissionDeniedMessage)),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$_recordErrorPrefix$e')),
          );
        }
      } finally {
        isRecording.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('TapPin'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.picture_in_picture,
              color: isOverlayActive.value ? Theme.of(context).colorScheme.primary : null,
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
                isLoading: isRecording.value,
              ),
            ),
          ),
          if (latestPin.value != null) _LatestPinCard(pin: latestPin.value!),
        ],
      ),
    );
  }
}

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
                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
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
