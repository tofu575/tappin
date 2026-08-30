import 'package:flutter_test/flutter_test.dart';

import 'package:tappin/domain/models/pin/pin.dart';

import '../../helpers/build_test_interactor.dart';
import '../../helpers/mock_clock_gateway.dart';
import '../../helpers/mock_haptic_gateway.dart';
import '../../helpers/mock_location_service.dart';
import '../../helpers/mock_repository.dart';

/// 保存失敗を発生させ、成功後の処理が呼ばれないことを検証するRepository。
class _SaveFailureRepository extends MockRipository {
  @override
  Future<int> savePin(Pin pin) => throw Exception('save failed');
}

/// 現在地記録Interactorの処理順序と多重実行防止を検証する。
void main() {
  test('現在地を保存した後に成功ハプティクスを呼ぶ', () async {
    final repository = MockRipository();
    final locationGateway = MockLocationService.success(testCoordinate);
    final hapticGateway = MockHapticGateway();
    final interactor = buildTestInteractor(
      repository: repository,
      locationGateway: locationGateway,
      hapticGateway: hapticGateway,
    );

    final pin = await interactor.recordCurrentLocation();

    expect(pin, isNotNull);
    expect(locationGateway.fetchCurrentLocationCount, 1);
    expect(repository.savedPins, hasLength(1));
    expect(hapticGateway.recordSuccessCount, 1);
  });

  test('保存失敗時は成功ハプティクスを呼ばない', () async {
    final hapticGateway = MockHapticGateway();
    final interactor = buildTestInteractor(
      repository: _SaveFailureRepository(),
      hapticGateway: hapticGateway,
    );

    await expectLater(
      interactor.recordCurrentLocation(),
      throwsA(isA<Exception>()),
    );
    expect(hapticGateway.recordSuccessCount, 0);
  });

  test('500ms以内の連続記録を保存前に抑止する', () async {
    final repository = MockRipository();
    final clockGateway = MockClockGateway();
    final interactor = buildTestInteractor(
      repository: repository,
      clockGateway: clockGateway,
    );

    final first = await interactor.recordCurrentLocation();
    final suppressed = await interactor.recordCurrentLocation();
    clockGateway.advance(const Duration(milliseconds: 500));
    final next = await interactor.recordCurrentLocation();

    expect(first, isNotNull);
    expect(suppressed, isNull);
    expect(next, isNotNull);
    expect(repository.savedPins, hasLength(2));
  });
}
