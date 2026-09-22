part of 'interactor.dart';

/// 初回操作前に位置情報Gatewayを準備する。
Future<void> _warmUpLocation(Interactor interactor) {
  return interactor._locationGateway.warmUp();
}
