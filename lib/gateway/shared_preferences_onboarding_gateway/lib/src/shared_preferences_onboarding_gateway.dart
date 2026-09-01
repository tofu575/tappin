import 'package:shared_preferences/shared_preferences.dart';

import 'package:usecase/usecase.dart';

const _onboardingKey = 'onboarding_v1';

/// SharedPreferencesへOnboarding完了状態を保存するGateway。
class SharedPreferencesOnboardingGateway implements OnboardingGateway {
  const SharedPreferencesOnboardingGateway._(this._preferences);

  /// 端末のSharedPreferencesを読み込み、Gatewayを生成する。
  static Future<SharedPreferencesOnboardingGateway> create() async {
    final preferences = await SharedPreferences.getInstance();
    return SharedPreferencesOnboardingGateway._(preferences);
  }

  final SharedPreferences _preferences;

  @override
  bool hasCompleted() => _preferences.getBool(_onboardingKey) ?? false;

  @override
  Future<void> complete() => _preferences.setBool(_onboardingKey, true);
}
