import 'package:flutter/foundation.dart';

/// RecordFeedbackの成功フラッシュを起動する。
class RecordFeedbackController {
  VoidCallback? _showFlash;

  /// 成功フラッシュを即時表示する。
  void showSuccess() {
    _showFlash?.call();
  }

  /// [showFlash]を現在表示中のRecordFeedbackへ接続する。
  void attach(VoidCallback showFlash) {
    _showFlash = showFlash;
  }

  /// 破棄されるRecordFeedbackとの接続だけを解除する。
  void detach(VoidCallback showFlash) {
    if (_showFlash == showFlash) _showFlash = null;
  }
}
