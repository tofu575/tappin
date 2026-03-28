import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tappin/domain/models/core/my_datetime.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/services/location_service.dart';
import 'package:tappin/pin_di.dart';
import 'package:tappin/presentation/pages/pin_list_page.dart';
import 'package:tappin/presentation/providers/pin_provider.dart';
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
                MaterialPageRoute(builder: (_) => const PinListPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: RecordButton(
          onPressed: _recordCurrentLocation,
          isLoading: _isRecording,
        ),
      ),
    );
  }
}
