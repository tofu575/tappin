part of 'interactor.dart';

/// [coordinate]に対応する住所をGatewayから取得する。
Future<String> _fetchAddress(Interactor interactor, Coordinate coordinate) {
  return interactor._geocodingGateway.fetchAddress(coordinate);
}
