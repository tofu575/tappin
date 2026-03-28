import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tappin/app.dart';
import 'package:tappin/domain/usecases/pin_usecase.dart';
import 'package:tappin/gateway/location/geolocator_location_service.dart';
import 'package:tappin/gateway/storage/pin_local_storage.dart';
import 'package:tappin/gateway/storage/pin_repository_impl.dart';
import 'package:tappin/presentation/providers/pin_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = await PinSQLiteStorage.open();
  final repository = PinRepositoryImpl(storage);

  runApp(
    ProviderScope(
      overrides: [
        pinUseCaseProvider.overrideWithValue(PinUseCase(repository)),
        locationServiceProvider.overrideWithValue(GeolocatorLocationService()),
      ],
      child: const App(),
    ),
  );
}
