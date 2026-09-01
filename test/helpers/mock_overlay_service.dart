import 'package:usecase/usecase.dart';

class MockOverlayService implements OverlayService {
  bool showCalled = false;
  bool hideCalled = false;

  @override
  Future<void> showOverlay() async {
    showCalled = true;
  }

  @override
  Future<void> hideOverlay() async {
    hideCalled = true;
  }
}
