import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/services/external_map_destination.dart';

/// 座標を端末の外部地図アプリで開く境界。
abstract interface class ExternalMapGateway {
  /// [coordinate]を[destination]の表示形式で開く。
  Future<void> open({
    required Coordinate coordinate,
    required ExternalMapDestination destination,
  });
}
