part of 'interactor.dart';

/// 位置情報Gatewayを介して端末設定を開く。
Future<void> _openLocationSettings(Interactor interactor) {
  return interactor._locationGateway.openSettings();
}
