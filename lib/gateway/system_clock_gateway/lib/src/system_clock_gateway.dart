import 'package:model/model.dart';
import 'package:usecase/usecase.dart';

/// システム時計から現在時刻を取得するGateway。
class SystemClockGateway implements ClockGateway {
  const SystemClockGateway();

  @override
  MyDatetime now() => MyDatetime(DateTime.now());
}
