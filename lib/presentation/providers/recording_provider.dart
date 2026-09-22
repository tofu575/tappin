import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:model/model.dart';
import 'package:tappin/presentation/providers/interactor_provider.dart';
import 'package:tappin/presentation/providers/provider.dart';

final recordingProvider = AsyncNotifierProvider<RecordingNotifier, Pin?>(
  RecordingNotifier.new,
);

/// 現在地記録の非同期状態と多重実行防止を画面間で共有するNotifier。
class RecordingNotifier extends AsyncNotifier<Pin?> {
  /// 記録前の状態を生成する。
  @override
  Future<Pin?> build() async => null;

  /// DIされた共通UseCaseで現在地を1回記録し、保存一覧を再読込する。
  Future<Pin?> recordCurrentLocation() async {
    if (state.isLoading) return null;

    state = const AsyncLoading();
    try {
      final pin = await ref.read(interactorProvider).recordCurrentLocation();
      if (pin == null) {
        state = const AsyncData(null);
        return null;
      }
      state = AsyncData(pin);
      ref.invalidate(pinsProvider);
      return pin;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
