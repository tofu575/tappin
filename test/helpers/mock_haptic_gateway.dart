import 'package:tappin/domain/services/haptic_gateway.dart';

/// 記録成功ハプティクスの呼び出し回数を保持するMock Gateway。
class MockHapticGateway implements HapticGateway {
  int recordSuccessCount = 0;

  @override
  void playRecordSuccess() => recordSuccessCount++;
}
