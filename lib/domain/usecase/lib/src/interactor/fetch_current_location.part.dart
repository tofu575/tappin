part of 'interactor.dart';

/// 位置情報Gatewayから現在地を取得する。
Future<Coordinate> _fetchCurrentLocation(Interactor interactor) {
  return interactor._locationGateway.fetchCurrentLocation();
}
