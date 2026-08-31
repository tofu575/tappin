import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/models/pin/memo.dart';
import 'package:tappin/domain/models/pin/pin.dart';
import 'package:tappin/domain/models/pin/pin_review_status.dart';
import 'package:tappin/presentation/providers/interactor_provider.dart';

final addressProvider = FutureProvider.autoDispose.family<String, Coordinate>((
  ref,
  coordinate,
) {
  return ref.read(interactorProvider).fetchAddress(coordinate);
});

final pinsProvider = AsyncNotifierProvider<PinsNotifier, List<Pin>>(
  PinsNotifier.new,
);

class PinsNotifier extends AsyncNotifier<List<Pin>> {
  @override
  Future<List<Pin>> build() {
    return ref.read(interactorProvider).fetchPins();
  }

  Future<void> deletePin(int id) async {
    final pins = state.value;
    if (pins == null) return;
    state = AsyncData(pins.where((pin) => pin.id != id).toList());
    try {
      await ref.read(interactorProvider).deletePin(id);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> updateMemo(int id, Memo memo) async {
    await ref.read(interactorProvider).updateMemo(id, memo);
    ref.invalidateSelf();
  }

  /// 指定したPinの確認状態を保存し、一覧を再読込する。
  Future<void> updateReviewStatus(int id, PinReviewStatus status) async {
    await ref.read(interactorProvider).updatePinReviewStatus(id, status);
    ref.invalidateSelf();
  }
}
