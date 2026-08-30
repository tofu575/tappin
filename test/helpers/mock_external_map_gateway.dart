import 'package:tappin/domain/models/location/coordinate.dart';
import 'package:tappin/domain/services/external_map_destination.dart';
import 'package:tappin/domain/services/external_map_gateway.dart';

/// 外部アプリを起動せず要求だけを受け取るMock Gateway。
class MockExternalMapGateway implements ExternalMapGateway {
  @override
  Future<void> open({
    required Coordinate coordinate,
    required ExternalMapDestination destination,
  }) async {}
}
