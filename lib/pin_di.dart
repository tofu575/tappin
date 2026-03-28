import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tappin/gateway/location/geolocator_location_service.dart';
import 'package:tappin/gateway/storage/pin_local_storage.dart';
import 'package:tappin/gateway/storage/pin_repository_impl.dart';
import 'package:tappin/domain/repositories/pin_repository.dart';
import 'package:tappin/domain/services/location_service.dart';
import 'package:tappin/domain/usecases/pin_usecase.dart';

final pinRepositoryProvider = FutureProvider<PinRepository>((ref) async {
  final storage = await PinSQLiteStorage.open();
  return PinRepositoryImpl(storage);
});

final pinUseCaseProvider = FutureProvider<PinUseCase>((ref) async {
  final repository = await ref.watch(pinRepositoryProvider.future);
  return PinUseCase(repository);
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return GeolocatorLocationService();
});
