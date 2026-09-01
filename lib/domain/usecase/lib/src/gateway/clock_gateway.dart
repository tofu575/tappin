import 'package:model/model.dart';

/// 現在時刻をDomain型で提供する外部境界。
abstract interface class ClockGateway {
  /// 現在時刻を返す。
  MyDatetime now();
}
