part of 'interactor.dart';

/// [coordinate]を[destination]に対応する外部地図で開く。
Future<void> _openExternalMap(
  Interactor interactor,
  Coordinate coordinate,
  ExternalMapDestination destination,
) {
  return interactor._externalMapGateway.open(
    coordinate: coordinate,
    destination: destination,
  );
}
