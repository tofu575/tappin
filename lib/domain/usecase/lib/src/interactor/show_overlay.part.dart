part of 'interactor.dart';

/// 端末上へネイティブOverlayを表示する。
Future<void> _showOverlay(Interactor interactor) {
  return interactor._overlayGateway.showOverlay();
}
