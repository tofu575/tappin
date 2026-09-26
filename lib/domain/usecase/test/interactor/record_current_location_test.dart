import 'package:test/test.dart';
import 'package:usecase/usecase.dart';

import '../support/test_gateway.dart';

/// 現在地記録Interactorの保存と多重実行防止を検証する。
void main() {
  test('現在地を保存した後に成功ハプティクスを呼ぶ', () async {
    final gateway = TestGateway();
    final interactor = _buildInteractor(gateway);

    final pin = await interactor.recordCurrentLocation();

    expect(pin, isNotNull);
    expect(gateway.savedPins, hasLength(1));
    expect(gateway.recordSuccessCount, 1);
  });

  test('保存失敗時は成功ハプティクスを呼ばない', () async {
    final gateway = TestGateway(saveError: Exception('save failed'));
    final interactor = _buildInteractor(gateway);

    await expectLater(interactor.recordCurrentLocation(), throwsException);
    expect(gateway.recordSuccessCount, 0);
  });

  test('500ms以内の連続記録を保存前に抑止する', () async {
    final gateway = TestGateway();
    final interactor = _buildInteractor(gateway);

    final first = await interactor.recordCurrentLocation();
    final suppressed = await interactor.recordCurrentLocation();
    gateway.currentTime = gateway.currentTime.add(
      const Duration(milliseconds: 500),
    );
    final next = await interactor.recordCurrentLocation();

    expect(first, isNotNull);
    expect(suppressed, isNull);
    expect(next, isNotNull);
    expect(gateway.savedPins, hasLength(2));
  });
}

/// 本番と同じ必須Gatewayを注入してInteractorを構築する。
Interactor _buildInteractor(TestGateway gateway) => Interactor(
  repository: gateway,
  locationGateway: gateway,
  geocodingGateway: gateway,
  clockGateway: gateway,
  hapticGateway: gateway,
  externalMapGateway: gateway,
  onboardingGateway: gateway,
);
