part of 'interactor.dart';

/// Gatewayに保存されたOnboarding完了状態を取得する。
bool _hasCompletedOnboarding(Interactor interactor) {
  return interactor._onboardingGateway.hasCompleted();
}
