/// 端末の触覚フィードバックを提供する外部境界。
abstract interface class HapticGateway {
  /// 記録成功を示す短い触覚フィードバックを開始する。
  void playRecordSuccess();
}
