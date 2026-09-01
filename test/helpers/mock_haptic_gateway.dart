import 'package:usecase/usecase.dart';

/// 記録成功・失敗ハプティクスの呼び出し回数を保持するMock Gateway。
class MockHapticGateway implements HapticGateway {
  int recordSuccessCount = 0;
  int recordFailureCount = 0;

  @override
  void playRecordFailure() => recordFailureCount++;

  @override
  void playRecordSuccess() => recordSuccessCount++;
}
