import 'package:model/model.dart';
import 'package:usecase/usecase.dart';

/// テスト時点の現在時刻を返すClock Gateway。
class MockClockGateway implements ClockGateway {
  MockClockGateway({MyDatetime? current})
    : current = current ?? MyDatetime(DateTime(2026));

  MyDatetime current;

  @override
  MyDatetime now() => current;

  /// テスト上の現在時刻を[duration]だけ進める。
  void advance(Duration duration) {
    current = MyDatetime(current.value.add(duration));
  }
}
