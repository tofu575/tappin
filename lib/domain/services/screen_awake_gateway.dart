/// Quick Mode中の画面スリープ防止状態を端末へ反映する外部境界。
abstract interface class ScreenAwakeGateway {
  /// 画面の自動スリープを防止する。
  Future<void> enable();

  /// 画面の自動スリープ防止を解除する。
  Future<void> disable();
}
