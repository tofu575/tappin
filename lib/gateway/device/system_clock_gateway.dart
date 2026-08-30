import 'package:tappin/domain/models/core/my_datetime.dart';
import 'package:tappin/domain/services/clock_gateway.dart';

/// システム時計から現在時刻を取得するGateway。
class SystemClockGateway implements ClockGateway {
  const SystemClockGateway();

  @override
  MyDatetime now() => MyDatetime(DateTime.now());
}
