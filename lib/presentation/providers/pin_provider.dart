import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tappin/core/usecase/usecase.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/pin_di.dart';

final pinsProvider = AsyncNotifierProvider<PinsNotifier, List<Pin>>(
  PinsNotifier.new,
);

class PinsNotifier extends AsyncNotifier<List<Pin>> {
  @override
  Future<List<Pin>> build() async {
    final useCase = await ref.watch(getPinsUseCaseProvider.future);
    return useCase(const NoParams());
  }

  Future<void> savePin(Pin pin) async {
    final useCase = await ref.read(savePinUseCaseProvider.future);
    await useCase(pin);
    ref.invalidateSelf();
  }

  Future<void> deletePin(int id) async {
    final useCase = await ref.read(deletePinUseCaseProvider.future);
    await useCase(id);
    ref.invalidateSelf();
  }
}
