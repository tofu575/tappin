import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/pin_di.dart';

final pinsProvider = AsyncNotifierProvider<PinsNotifier, List<Pin>>(
  PinsNotifier.new,
);

class PinsNotifier extends AsyncNotifier<List<Pin>> {
  @override
  Future<List<Pin>> build() async {
    final useCase = await ref.watch(pinUseCaseProvider.future);
    return useCase.fetchPins();
  }

  Future<void> savePin(Pin pin) async {
    final useCase = await ref.read(pinUseCaseProvider.future);
    await useCase.savePin(pin);
    ref.invalidateSelf();
  }

  Future<void> deletePin(int id) async {
    final useCase = await ref.read(pinUseCaseProvider.future);
    await useCase.deletePin(id);
    ref.invalidateSelf();
  }
}
