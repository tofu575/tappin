/// Onboarding完了状態を端末へ保存する境界。
abstract interface class OnboardingGateway {
  /// Onboardingが完了済みか返す。
  bool hasCompleted();

  /// Onboardingを完了済みとして保存する。
  Future<void> complete();
}
