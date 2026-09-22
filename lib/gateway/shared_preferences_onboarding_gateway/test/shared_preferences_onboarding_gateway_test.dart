import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_onboarding_gateway/shared_preferences_onboarding_gateway.dart';

/// Onboarding完了状態の初期化と保存を検証する。
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('未保存なら未完了を返し、完了後は完了済みを返す', () async {
    final gateway = await SharedPreferencesOnboardingGateway.create();

    expect(gateway.hasCompleted(), isFalse);

    await gateway.complete();

    expect(gateway.hasCompleted(), isTrue);
  });
}
