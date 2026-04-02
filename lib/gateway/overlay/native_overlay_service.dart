import 'package:flutter/services.dart';

import 'package:tappin/domain/services/overlay_service.dart';

const _methodOverlayShow = 'overlay/show';
const _methodOverlayHide = 'overlay/hide';
const _errorOverlayPermissionRequired = 'OVERLAY_PERMISSION_REQUIRED';

class NativeOverlayService implements OverlayService {
  final MethodChannel _channel;

  NativeOverlayService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('com.example.tappin/native');

  @override
  Future<void> showOverlay() async {
    try {
      await _channel.invokeMethod(_methodOverlayShow);
    } on PlatformException catch (e) {
      if (e.code == _errorOverlayPermissionRequired) {
        return;
      }
      rethrow;
    }
  }

  @override
  Future<void> hideOverlay() async {
    await _channel.invokeMethod(_methodOverlayHide);
  }
}
