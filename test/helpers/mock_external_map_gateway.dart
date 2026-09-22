import 'package:model/model.dart';
import 'package:usecase/usecase.dart';

/// 外部アプリを起動せず要求だけを受け取るMock Gateway。
class MockExternalMapGateway implements ExternalMapGateway {
  @override
  Future<void> open({
    required Coordinate coordinate,
    required ExternalMapDestination destination,
  }) async {}
}
