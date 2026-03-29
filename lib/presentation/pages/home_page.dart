import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tappin/domain/models/core/my_datetime.dart';
import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/services/location_service.dart';
import 'package:tappin/presentation/pages/list_page.dart';
import 'package:tappin/presentation/providers/provider.dart';
import 'package:tappin/presentation/widgets/record_button.dart';

const _permissionDeniedMessage = '位置情報の許可が必要です';
const _recordSuccessMessage = '現在地を記録しました';
const _recordErrorPrefix = 'エラーが発生しました: ';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isRecording = false;
  Pin? _latestPin;

  Future<void> _recordCurrentLocation() async {
    setState(() => _isRecording = true);
    try {
      final coordinate = await ref
          .read(locationServiceProvider)
          .fetchCurrentLocation();

      final pin = Pin(
        latitude: coordinate.latitude,
        longitude: coordinate.longitude,
        createdAt: MyDatetime(DateTime.now()),
      );

      await ref.read(pinsProvider.notifier).savePin(pin);

      if (mounted) {
        setState(() => _latestPin = pin);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(_recordSuccessMessage)),
        );
      }
    } on LocationPermissionDeniedException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(_permissionDeniedMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$_recordErrorPrefix$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRecording = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TapPin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ListPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: RecordButton(
                onPressed: _recordCurrentLocation,
                isLoading: _isRecording,
              ),
            ),
          ),
          if (_latestPin != null) _LatestPinCard(pin: _latestPin!),
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

    return Card(
      margin: const EdgeInsets.all(16),
      child: ListTile(
        leading: const Icon(Icons.location_on),
        title: Text(addressText),
        subtitle: Text(dateStr),
      ),
    );
  }
}
