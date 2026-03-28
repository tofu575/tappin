import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:tappin/features/pin/domain/models/pin/pin.dart';
import 'package:tappin/features/pin/domain/models/pin/latitude.dart';
import 'package:tappin/features/pin/domain/models/pin/longitude.dart';
import 'package:tappin/features/pin/domain/models/core/my_datetime.dart';
import 'package:tappin/features/pin/presentation/providers/pin_provider.dart';
import 'package:tappin/features/pin/presentation/widgets/record_button.dart';
import 'package:tappin/features/pin/presentation/pages/pin_list_page.dart';

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
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('位置情報の許可が必要です')),
            );
          }
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final pin = Pin(
        latitude: Latitude(position.latitude),
        longitude: Longitude(position.longitude),
        createdAt: MyDatetime(DateTime.now()),
      );

      await ref.read(pinsProvider.notifier).savePin(pin);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('現在地を記録しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
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
