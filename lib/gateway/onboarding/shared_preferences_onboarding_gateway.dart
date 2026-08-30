import 'package:shared_preferences/shared_preferences.dart';

import 'package:tappin/domain/services/onboarding_gateway.dart';

const _onboardingKey = 'onboarding_v1';

/// SharedPreferencesへOnboarding完了状態を保存するGateway。
class SharedPreferencesOnboardingGateway implements OnboardingGateway {
  const SharedPreferencesOnboardingGateway(this._preferences);

  final SharedPreferences _preferences;

  @override
  bool hasCompleted() => _preferences.getBool(_onboardingKey) ?? false;

  @override
  Future<void> complete() => _preferences.setBool(_onboardingKey, true);
}
