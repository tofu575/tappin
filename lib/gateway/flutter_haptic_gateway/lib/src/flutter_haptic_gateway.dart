import 'dart:async';

import 'package:flutter/services.dart';

import 'package:usecase/usecase.dart';

/// Flutterの端末APIで記録成功ハプティクスを開始するGateway。
class FlutterHapticGateway implements HapticGateway {
  const FlutterHapticGateway();

  @override
  void playRecordSuccess() {
    unawaited(HapticFeedback.mediumImpact());
  }

  @override
  void playRecordFailure() {
    unawaited(HapticFeedback.vibrate());
  }
}
