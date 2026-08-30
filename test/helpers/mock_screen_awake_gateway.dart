import 'package:tappin/domain/services/screen_awake_gateway.dart';

/// Screen Awakeの有効化・解除回数を保持するMock Gateway。
class MockScreenAwakeGateway implements ScreenAwakeGateway {
  int enableCount = 0;
  int disableCount = 0;

  @override
  Future<void> disable() async => disableCount++;

  @override
  Future<void> enable() async => enableCount++;
}
