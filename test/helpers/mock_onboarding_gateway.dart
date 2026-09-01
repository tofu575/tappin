import 'package:usecase/usecase.dart';

/// Onboarding完了状態をメモリ上に保持するMock Gateway。
class MockOnboardingGateway implements OnboardingGateway {
  bool completed = false;

  @override
  bool hasCompleted() => completed;

  @override
  Future<void> complete() async => completed = true;
}
