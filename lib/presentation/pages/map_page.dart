import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/presentation/providers/provider.dart';
import 'package:tappin/presentation/widgets/map_launch_buttons.dart';

// 日本の中心付近
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

class _MapView extends ConsumerStatefulWidget {
  const _MapView({required this.pins});

  final List<Pin> pins;

  @override
  ConsumerState<_MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<_MapView> {
  final _mapController = MapController();
  LatLng? _currentLocation;
  bool _isFetchingLocation = false;

  LatLng get _initialCenter {
    if (widget.pins.isEmpty) return _defaultCenter;
    final latest = widget.pins.first;
    return LatLng(latest.latitude.value, latest.longitude.value);
  }

  double get _initialZoom => widget.pins.isEmpty ? _defaultZoom : _pinZoom;

  Future<void> _moveToCurrentLocation() async {
    if (_isFetchingLocation) return;
    setState(() => _isFetchingLocation = true);
    try {
      final coordinate =
          await ref.read(locationServiceProvider).fetchCurrentLocation();
      final location =
          LatLng(coordinate.latitude.value, coordinate.longitude.value);
      if (mounted) setState(() => _currentLocation = location);
      _mapController.moveAndRotate(location, _pinZoom, 0);
    } catch (_) {
      // 位置情報取得失敗時はそのまま継続
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  void _showPinDetail(BuildContext context, Pin pin) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _PinDetailSheet(pin: pin),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinMarkers = widget.pins
        .map(
          (pin) => Marker(
            point: LatLng(pin.latitude.value, pin.longitude.value),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showPinDetail(context, pin),
              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
          ),
        )
        .toList();

    final currentLocation = _currentLocation;
    final currentLocationMarkers = currentLocation == null
        ? <Marker>[]
        : [
            Marker(
              point: currentLocation,
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
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _initialCenter,
            initialZoom: _initialZoom,
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
            onPressed: _moveToCurrentLocation,
            child: _isFetchingLocation
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

class _PinDetailSheet extends ConsumerWidget {
  const _PinDetailSheet({required this.pin});

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
          Align(
            alignment: Alignment.centerRight,
            child: MapLaunchButtons(coordinate: coordinate),
          ),
        ],
      ),
    );
  }
}
