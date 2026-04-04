import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/models/pin/memo.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/services/location_service.dart';
import 'package:tappin/presentation/providers/provider.dart';
import 'package:tappin/presentation/widgets/map_launch_buttons.dart';
import 'package:tappin/presentation/widgets/memo_edit_dialog.dart';

const _defaultCenter = LatLng(35.6, 139.7);
const _defaultZoom = 15.0;
const _minZoom = 3.0;
const _pinZoom = 17.5;
const _tileUrlTemplate =
    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';
const _tileSubdomains = ['a', 'b', 'c', 'd'];
const _userAgentPackageName = 'com.example.tappin';

class MapPage extends ConsumerWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinsAsync = ref.watch(pinsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('マップ')),
      body: pinsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (pins) => _MapView(pins: pins),
      ),
    );
  }
}

class _MapView extends HookConsumerWidget {
  const _MapView({required this.pins});

  final List<Pin> pins;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapController = useMemoized(MapController.new);
    final currentLocation = useState<LatLng?>(null);
    final isFetchingLocation = useState(false);

    final initialCenter = pins.isEmpty
        ? _defaultCenter
        : LatLng(pins.first.latitude.value, pins.first.longitude.value);
    final initialZoom = pins.isEmpty ? _defaultZoom : _pinZoom;

    Future<void> moveToCurrentLocation() async {
      if (isFetchingLocation.value) return;
      isFetchingLocation.value = true;
      try {
        final coordinate =
            await ref.read(locationServiceProvider).fetchCurrentLocation();
        final location =
            LatLng(coordinate.latitude.value, coordinate.longitude.value);
        if (context.mounted) currentLocation.value = location;
        mapController.moveAndRotate(location, _pinZoom, 0);
      } on LocationPermissionPermanentlyDeniedException {
        if (context.mounted) {
          showDialog<void>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('位置情報の許可が必要です'),
              content: const Text('設定から位置情報へのアクセスを許可してください'),
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
                  child: const Text('設定を開く'),
                ),
              ],
            ),
          );
        }
      } on LocationPermissionDeniedException {
        // OS ダイアログで既に拒否済み
      } catch (_) {
        // 位置情報取得失敗時はそのまま継続
      } finally {
        if (context.mounted) isFetchingLocation.value = false;
      }
    }

    void showPinDetail(Pin pin) {
      showModalBottomSheet(
        context: context,
        builder: (_) => _PinDetailSheet(pin: pin),
      );
    }

    final pinMarkers = pins
        .map(
          (pin) => Marker(
            point: LatLng(pin.latitude.value, pin.longitude.value),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => showPinDetail(pin),
              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
          ),
        )
        .toList();

    final currentLoc = currentLocation.value;
    final currentLocationMarkers = currentLoc == null
        ? <Marker>[]
        : [
            Marker(
              point: currentLoc,
              width: 20,
              height: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
              ),
            ),
          ];

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: initialZoom,
            minZoom: _minZoom,
          ),
          children: [
            TileLayer(
              urlTemplate: _tileUrlTemplate,
              subdomains: _tileSubdomains,
              userAgentPackageName: _userAgentPackageName,
              retinaMode: RetinaMode.isHighDensity(context),
              tileProvider: FMTCStore('mapTiles').getTileProvider(),
            ),
            MarkerLayer(markers: currentLocationMarkers),
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                maxClusterRadius: 80,
                markers: pinMarkers,
                builder: (context, markers) => Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${markers.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'myLocation',
            onPressed: moveToCurrentLocation,
            child: isFetchingLocation.value
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}

class _PinDetailSheet extends HookConsumerWidget {
  const _PinDetailSheet({required this.pin});

  final Pin pin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memo = useState<Memo?>(pin.memo);

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

    Future<void> openMemoEditor() async {
      final result = await showDialog<String>(
        context: context,
        builder: (_) => MemoEditDialog(
          initialText: memo.value?.value ?? '$dateStr $addressText',
        ),
      );
      if (result != null && pin.id != null && context.mounted) {
        memo.value = Memo(result);
        ref.read(pinsProvider.notifier).updateMemo(pin.id!, Memo(result));
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(dateStr),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(addressText),
          ),
          ListTile(
            leading: const Icon(Icons.notes),
            title: memo.value != null
                ? Text(memo.value!.value)
                : const Text('(メモなし)', style: TextStyle(color: Colors.grey)),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'メモを編集',
              onPressed: openMemoEditor,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: MapLaunchButtons(coordinate: coordinate),
          ),
        ],
      ),
    );
  }
}
