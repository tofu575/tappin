import 'package:usecase/usecase.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// wakelock_plusを使って端末の画面スリープ防止状態を切り替えるGateway。
class WakelockScreenAwakeGateway implements ScreenAwakeGateway {
  const WakelockScreenAwakeGateway();

  @override
  Future<void> disable() => WakelockPlus.disable();

  @override
  Future<void> enable() => WakelockPlus.enable();
}
