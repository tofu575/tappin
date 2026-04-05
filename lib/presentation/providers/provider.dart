import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/models/pin/memo.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/services/geocoding_service.dart';
import 'package:tappin/domain/services/location_service.dart';
import 'package:tappin/domain/services/overlay_service.dart';
import 'package:tappin/domain/usecases/use_case.dart';

final useCaseProvider = Provider<UseCase>(
  (ref) => throw UnimplementedError('useCaseProvider must be overridden'),
);

final locationServiceProvider = Provider<LocationService>(
  (ref) => throw UnimplementedError('locationServiceProvider must be overridden'),
);

final geocodingServiceProvider = Provider<GeocodingService>(
  (ref) => throw UnimplementedError('geocodingServiceProvider must be overridden'),
);

final overlayServiceProvider = Provider<OverlayService>(
  (ref) => throw UnimplementedError('overlayServiceProvider must be overridden'),
);

final addressProvider = FutureProvider.autoDispose.family<String, Coordinate>(
  (ref, coordinate) {
    return ref.watch(geocodingServiceProvider).fetchAddress(coordinate);
  },
);

final pinsProvider = AsyncNotifierProvider<PinsNotifier, List<Pin>>(
  PinsNotifier.new,
);

class PinsNotifier extends AsyncNotifier<List<Pin>> {
  @override
  Future<List<Pin>> build() {
    return ref.watch(useCaseProvider).fetchPins();
  }

  Future<void> savePin(Pin pin) async {
    await ref.read(useCaseProvider).savePin(pin);
    ref.invalidateSelf();
  }

  Future<void> deletePin(int id) async {
    await ref.read(useCaseProvider).deletePin(id);
    ref.invalidateSelf();
  }

  Future<void> updateMemo(int id, Memo memo) async {
    await ref.read(useCaseProvider).updateMemo(id, memo);
    ref.invalidateSelf();
  }
}
