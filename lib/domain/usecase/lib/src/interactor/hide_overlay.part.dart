part of 'interactor.dart';

/// 端末上のネイティブOverlayを非表示にする。
Future<void> _hideOverlay(Interactor interactor) {
  return interactor._overlayGateway.hideOverlay();
}
