part of 'interactor.dart';

/// Gatewayから保存済みPinを取得する。
Future<List<Pin>> _fetchPins(Interactor interactor) {
  return interactor._repository.getPins();
}
