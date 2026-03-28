import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/services/location_service.dart';
import 'package:tappin/domain/usecases/pin_usecase.dart';

final pinUseCaseProvider = Provider<PinUseCase>(
  (ref) => throw UnimplementedError('pinUseCaseProvider must be overridden'),
);

final locationServiceProvider = Provider<LocationService>(
  (ref) => throw UnimplementedError('locationServiceProvider must be overridden'),
);

final pinsProvider = AsyncNotifierProvider<PinsNotifier, List<Pin>>(
  PinsNotifier.new,
);

class PinsNotifier extends AsyncNotifier<List<Pin>> {
  @override
  Future<List<Pin>> build() {
    return ref.watch(pinUseCaseProvider).fetchPins();
  }

  Future<void> savePin(Pin pin) async {
    await ref.read(pinUseCaseProvider).savePin(pin);
    ref.invalidateSelf();
  }

  Future<void> deletePin(int id) async {
    await ref.read(pinUseCaseProvider).deletePin(id);
    ref.invalidateSelf();
  }
}
