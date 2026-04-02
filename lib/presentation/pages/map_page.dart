import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
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
const _osmUrlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
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

class _MapView extends StatelessWidget {
  const _MapView({required this.pins});

  final List<Pin> pins;

  LatLng get _initialCenter {
    if (pins.isEmpty) return _defaultCenter;
    final latest = pins.first;
    return LatLng(latest.latitude.value, latest.longitude.value);
  }

  double get _initialZoom => pins.isEmpty ? _defaultZoom : _pinZoom;

  @override
  Widget build(BuildContext context) {
    final markers = pins
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

    return FlutterMap(
      options: MapOptions(
        initialCenter: _initialCenter,
        initialZoom: _initialZoom,
        minZoom: _minZoom,
      ),
      children: [
        TileLayer(
          urlTemplate: _osmUrlTemplate,
          userAgentPackageName: _userAgentPackageName,
        ),
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 80,
            markers: markers,
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
    );
  }

  void _showPinDetail(BuildContext context, Pin pin) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _PinDetailSheet(pin: pin),
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
