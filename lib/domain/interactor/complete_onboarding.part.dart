part of 'interactor.dart';

/// GatewayへOnboarding完了状態を保存する。
Future<void> _completeOnboarding(Interactor interactor) {
  return interactor._onboardingGateway.complete();
}
